#!/usr/bin/env bash
# PostToolUse hook — runs after Claude writes/edits a frontend file.
# Runs the project linter for accessibility violations and injects findings
# back into Claude's context (via hookSpecificOutput.additionalContext) so
# they are fixed in the same turn.
#
# Setup:
#   1. Make executable: chmod +x .claude/hooks/post-tool-a11y-check.sh
#   2. Set FRONTEND_DIRS / FRONTEND_EXTS below for your project.
#   3. The jq parsing below targets Biome's JSON schema. For ESLint, set
#      A11Y_LINT_CMD and adjust the jq (ESLint uses .messages[].ruleId/.line).
#   4. Register in .claude/settings.json (see example at end of this file).

set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# A file qualifies as frontend when its extension is in FRONTEND_EXTS. Optionally
# restrict to directories by listing path substrings in FRONTEND_DIRS.
# Default is EMPTY (match any directory) so it aligns with accessibility.md's
# `paths: **/*.tsx|jsx` frontmatter and covers App-Router layouts (/app, root
# /components, etc.), not just /src. Set e.g. FRONTEND_DIRS=("/src/") to narrow.
FRONTEND_DIRS=()
FRONTEND_EXTS=(".tsx" ".jsx")
# ──────────────────────────────────────────────────────────────────────────────

HOOK_INPUT=$(cat)
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

is_frontend_file() {
  local file="$1"
  local ext_ok=1 dir_ok=1
  for ext in "${FRONTEND_EXTS[@]}"; do
    [[ "$file" == *"$ext" ]] && ext_ok=0 && break
  done
  # Empty FRONTEND_DIRS = no directory restriction (match any .tsx/.jsx).
  if [[ "${#FRONTEND_DIRS[@]}" -eq 0 ]]; then
    dir_ok=0
  else
    for dir in "${FRONTEND_DIRS[@]}"; do
      [[ "$file" == *"$dir"* ]] && dir_ok=0 && break
    done
  fi
  [[ "$ext_ok" -eq 0 && "$dir_ok" -eq 0 ]]
}

if ! is_frontend_file "$FILE_PATH"; then
  exit 0
fi

# ─── Run linter ───────────────────────────────────────────────────────────────
LINT_CMD="${A11Y_LINT_CMD:-npx biome check --reporter=json}"
LINT_OUTPUT=$(cd "$PROJECT_ROOT" && $LINT_CMD "$FILE_PATH" 2>/dev/null || true)

# Distinguish "linter ran" from "linter failed". A genuine tooling failure (missing
# binary, bad config) yields no parseable JSON — surface that instead of silently
# reporting a false "no violations".
if ! echo "$LINT_OUTPUT" | jq -e 'has("diagnostics")' >/dev/null 2>&1; then
  jq -n --arg file "$(basename "$FILE_PATH")" \
    '{
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: "A11Y LINT could not run on \($file) — the linter returned no parseable output. Verify accessibility manually before continuing."
      }
    }'
  exit 0
fi

# Count a11y violations directly from jq (avoids the grep -c "0\n0" arithmetic trap).
VIOLATION_COUNT=$(
  echo "$LINT_OUTPUT" \
  | jq '[.diagnostics[]? | select(.category | startswith("lint/a11y/"))] | length' 2>/dev/null \
  || echo 0
)

if [[ "${VIOLATION_COUNT:-0}" -le 0 ]]; then
  exit 0
fi

# Biome 2.x diagnostic schema: .category, .message (string), .location.start.line
A11Y_VIOLATIONS=$(
  echo "$LINT_OUTPUT" \
  | jq -r '
      .diagnostics[]?
      | select(.category | startswith("lint/a11y/"))
      | "  • \(.category): \(.message) (line \(.location.start.line // "?"))"
    '
)

jq -n \
  --arg count "$VIOLATION_COUNT" \
  --arg file "$FILE_PATH" \
  --arg violations "$A11Y_VIOLATIONS" \
  '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: "A11Y LINT: Found \($count) accessibility violation(s) in \($file):\n\($violations)\n\nPlease fix these before continuing."
    }
  }'

exit 0

# ─── settings.json registration ───────────────────────────────────────────────
# Add the following to your .claude/settings.json:
#
# {
#   "hooks": {
#     "PostToolUse": [
#       {
#         "matcher": "Write|Edit",
#         "hooks": [
#           {
#             "type": "command",
#             "command": ".claude/hooks/post-tool-a11y-check.sh",
#             "timeout": 20,
#             "statusMessage": "Checking accessibility..."
#           }
#         ]
#       }
#     ]
#   }
# }
