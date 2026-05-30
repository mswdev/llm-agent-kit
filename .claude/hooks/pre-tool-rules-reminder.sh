#!/usr/bin/env bash
# PreToolUse hook — fires before Claude writes/edits a frontend file.
# Re-injects the accessibility rules as a reminder at the exact moment
# they are needed, compensating for long-session context drift.
#
# Anthropic docs confirm CLAUDE.md rules drift out of attention in long sessions.
# A pre-write reminder re-surfaces critical rules when they are most relevant.
#
# Setup:
#   1. Make executable: chmod +x .claude/hooks/pre-tool-rules-reminder.sh
#   2. Set RULES_FILE below to the path of your accessibility.md.
#   3. Register in .claude/settings.json (see example at end of this file).

set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
RULES_FILE="${A11Y_RULES_FILE:-$PROJECT_ROOT/.claude/rules/accessibility.md}"

# Glob patterns (relative to PROJECT_ROOT) that should trigger the reminder.
FRONTEND_GLOBS=(
  "src/**/*.tsx"
  "src/**/*.jsx"
)
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
  for glob in "${FRONTEND_GLOBS[@]}"; do
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

# Only inject if the rules file exists
if [[ ! -f "$RULES_FILE" ]]; then
  exit 0
fi

# Strip YAML frontmatter and comments for a clean context injection
RULES_CONTENT=$(
  awk '
    /^---$/ { if (NR==1) { in_front=1; next } else if (in_front) { in_front=0; next } }
    in_front { next }
    /^<!--/ { in_comment=1 }
    in_comment { if (/-->/) in_comment=0; next }
    { print }
  ' "$RULES_FILE"
)

jq -n \
  --arg file "$(basename "$FILE_PATH")" \
  --arg rules "$RULES_CONTENT" \
  '{
    additionalContext: "ACCESSIBILITY REMINDER (writing \($file)):\n\($rules)"
  }'

exit 0

# ─── settings.json registration ───────────────────────────────────────────────
# Add the following to your .claude/settings.json (alongside the PostToolUse hook):
#
# {
#   "hooks": {
#     "PreToolUse": [
#       {
#         "matcher": "Write|Edit",
#         "hooks": [
#           {
#             "type": "command",
#             "command": ".claude/hooks/pre-tool-rules-reminder.sh",
#             "timeout": 5,
#             "statusMessage": "Loading accessibility rules..."
#           }
#         ]
#       }
#     ],
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
