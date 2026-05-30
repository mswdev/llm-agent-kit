#!/usr/bin/env bash
# PostToolUse hook — runs after Claude writes/edits a frontend file.
# Fires lint rules for accessibility violations and injects findings back
# into Claude's context so they are fixed in the same turn.
#
# Setup:
#   1. Make executable: chmod +x .claude/hooks/post-tool-a11y-check.sh
#   2. Configure PROJECT_ROOT and FRONTEND_GLOBS below for your project.
#   3. Register in .claude/settings.json (see example at end of this file).

set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# Glob patterns (relative to PROJECT_ROOT) that should trigger an a11y check.
# Adjust to match your project's frontend directories.
FRONTEND_GLOBS=(
  "src/**/*.tsx"
  "src/**/*.jsx"
)
# ──────────────────────────────────────────────────────────────────────────────

# Read hook input from stdin
HOOK_INPUT=$(cat)
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

# Only act on Write and Edit tool calls
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Skip if no file path was provided
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Check whether the file matches any of the frontend globs
is_frontend_file() {
  local file="$1"
  local relative_path="${file#"$PROJECT_ROOT/"}"
  for glob in "${FRONTEND_GLOBS[@]}"; do
    # Use bash globbing via eval to check the pattern
    if compgen -G "$PROJECT_ROOT/$glob" | grep -qxF "$file" 2>/dev/null; then
      return 0
    fi
    # Fallback: simple extension check on the pattern
    local ext="${glob##*.}"
    if [[ "$file" == *".$ext" ]]; then
      return 0
    fi
  done
  return 1
}

if ! is_frontend_file "$FILE_PATH"; then
  exit 0
fi

# ─── Run linter ───────────────────────────────────────────────────────────────
# Adjust this command to match your project's linter.
# Examples:
#   Biome:  npx biome check --reporter=json "$FILE_PATH"
#   ESLint: npx eslint --format json "$FILE_PATH"
LINT_CMD="${A11Y_LINT_CMD:-npx biome check --reporter=json}"

LINT_OUTPUT=$($LINT_CMD "$FILE_PATH" 2>/dev/null || true)

# Extract a11y violations from Biome JSON output.
# Biome a11y rule IDs start with "lint/a11y/".
A11Y_VIOLATIONS=$(
  echo "$LINT_OUTPUT" \
  | jq -r '
      .diagnostics[]?
      | select(.category | startswith("lint/a11y/"))
      | "  • \(.category): \(.description) (line \(.location.span[0] // "?"))"
    ' 2>/dev/null \
  || true
)

VIOLATION_COUNT=$(echo "$A11Y_VIOLATIONS" | grep -c "•" 2>/dev/null || echo "0")

# ─── Output ───────────────────────────────────────────────────────────────────
if [[ "$VIOLATION_COUNT" -gt 0 ]]; then
  jq -n \
    --arg count "$VIOLATION_COUNT" \
    --arg file "$FILE_PATH" \
    --arg violations "$A11Y_VIOLATIONS" \
    '{
      additionalContext: "A11Y LINT: Found \($count) accessibility violation(s) in \($file):\n\($violations)\n\nPlease fix these before continuing."
    }'
fi

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
