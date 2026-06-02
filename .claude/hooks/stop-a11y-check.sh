#!/usr/bin/env bash
# Stop hook — blocks the agent from ENDING its turn while frontend files it
# changed still have accessibility violations (per the project linter's a11y
# rules). Pairs with post-tool-a11y-check.sh: that one nudges after each edit,
# this one refuses to let the agent declare "done" with unresolved a11y issues.
#
# Output contract (Stop event): top-level {"decision":"block","reason":...} blocks
# the stop and feeds the reason back to the model; exit 0 allows the stop.
#
# Setup:
#   1. chmod +x .claude/hooks/stop-a11y-check.sh
#   2. Register in .claude/settings.json under "Stop" (see example at end).
#   3. The jq below targets Biome's JSON schema; for ESLint set A11Y_LINT_CMD and
#      adjust the jq (ESLint uses .filePath/.messages[].ruleId/.line).
set -uo pipefail

LINT_CMD="${A11Y_LINT_CMD:-npx biome check --reporter=json}"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
INPUT=$(cat)

# Loop guard: if this stop was already triggered by a previous Stop-hook block,
# do not block again — nudge once, never spin.
if [[ "$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)" == "true" ]]; then
  exit 0
fi

cd "$PROJECT_ROOT" || exit 0

# Frontend files changed this session: tracked modifications + new untracked,
# .tsx/.jsx. Narrow with an extra `grep` (e.g. '/src/') if you only gate part of
# the tree.
CHANGED=$(
  {
    git diff --name-only HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | grep -E '\.(tsx|jsx)$' | sort -u || true
)
[[ -z "$CHANGED" ]] && exit 0

# shellcheck disable=SC2086 # intentional word-split: pass each file as an arg
LINT_OUTPUT=$($LINT_CMD $CHANGED 2>/dev/null || true)
A11Y=$(
  echo "$LINT_OUTPUT" \
  | jq -r '
      [.diagnostics[]? | select(.category | startswith("lint/a11y/"))][]
      | "  • \(.category): \(.message) (\(.location.path):\(.location.start.line // "?"))"
    ' 2>/dev/null \
  || true
)

if [[ -n "$A11Y" ]]; then
  REASON="Do not finish yet — frontend files you changed still have accessibility violations (these also block at commit/CI):\n\n${A11Y}\n\nFix them, then stop."
  jq -n --arg r "$REASON" '{decision: "block", reason: $r}'
fi

exit 0

# ─── settings.json registration ───────────────────────────────────────────────
# {
#   "hooks": {
#     "PostToolUse": [
#       { "matcher": "Write|Edit",
#         "hooks": [ { "type": "command", "command": ".claude/hooks/post-tool-a11y-check.sh", "timeout": 20 } ] }
#     ],
#     "Stop": [
#       { "hooks": [ { "type": "command", "command": ".claude/hooks/stop-a11y-check.sh", "timeout": 30 } ] }
#     ]
#   }
# }
