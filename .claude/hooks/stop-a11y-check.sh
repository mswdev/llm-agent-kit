#!/usr/bin/env bash
# Stop hook — blocks the agent from ENDING its turn while frontend files it
# touched still carry accessibility violations. This closes the loop the
# PostToolUse hook only nudges: the agent cannot declare done with unresolved
# a11y issues. Mirror your commit/CI a11y gates here so the agent hits the
# same bar before it stops.
#
# Setup:
#   1. Make executable: chmod +x .claude/hooks/stop-a11y-check.sh
#   2. Set FRONTEND_EXT_PATTERN / FRONTEND_DIR_PATTERN below for your project.
#   3. The jq parsing below targets Biome's JSON schema. For ESLint, set
#      A11Y_LINT_CMD and adjust the jq (ESLint uses .messages[].ruleId/.line).
#   4. Registered in .claude/settings.json (shipped with this kit).
#
# Output contract (Stop event): top-level {"decision":"block","reason":...} blocks
# the stop and feeds the reason back to the model. Exit 0 allows the stop.
set -uo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
INPUT=$(cat)

# Loop guard: if this stop was already triggered by a previous Stop-hook block,
# do not block again — nudge once, never spin.
if [[ "$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)" == "true" ]]; then
  exit 0
fi

cd "$PROJECT_ROOT" || exit 0

# ─── Configuration ────────────────────────────────────────────────────────────
# A changed file qualifies as frontend when it matches FRONTEND_EXT_PATTERN
# (grep -E). Optionally restrict to directories via FRONTEND_DIR_PATTERN — empty
# means no restriction, matching accessibility.md's `paths: **/*.tsx|jsx`.
FRONTEND_EXT_PATTERN='\.(tsx|jsx)$'
FRONTEND_DIR_PATTERN=''   # e.g. '(^|/)(webapp|frontend)/'
# ──────────────────────────────────────────────────────────────────────────────

# Frontend files changed this session: tracked modifications + new untracked.
# A11Y_CHANGED_FILES overrides the git detection for tests (set, even to empty,
# to bypass git).
if [[ -n "${A11Y_CHANGED_FILES+x}" ]]; then
  CHANGED="$A11Y_CHANGED_FILES"
else
  CHANGED=$(
    {
      git diff --name-only HEAD 2>/dev/null
      git ls-files --others --exclude-standard 2>/dev/null
    } | grep -E "$FRONTEND_EXT_PATTERN" | sort -u || true
  )
  if [[ -n "$FRONTEND_DIR_PATTERN" && -n "$CHANGED" ]]; then
    CHANGED=$(echo "$CHANGED" | grep -E "$FRONTEND_DIR_PATTERN" || true)
  fi
fi
[[ -z "$CHANGED" ]] && exit 0

# Run the a11y linter on the changed frontend files (overridable for tests).
LINT_CMD="${A11Y_LINT_CMD:-npx biome check --reporter=json}"
LINT_OUTPUT=$($LINT_CMD ${CHANGED} 2>/dev/null || true)

# Fail CLOSED, not open: if the linter did not emit parseable JSON (crash, bad
# flag, empty output), block rather than silently allowing the stop — the a11y
# check must actually have run. Biome's JSON envelope always has a "diagnostics"
# key on a successful run (even with zero findings), so its absence means failure.
if ! echo "$LINT_OUTPUT" | jq -e 'has("diagnostics")' >/dev/null 2>&1; then
  jq -n --arg r "Do not finish yet — accessibility lint could not run (the linter returned no parseable output). Run the linter manually and retry." \
    '{decision: "block", reason: $r}'
  exit 0
fi

A11Y=$(
  echo "$LINT_OUTPUT" \
  | jq -r '
      [.diagnostics[]? | select(.category | startswith("lint/a11y/"))][]
      | "  • \(.category): \(.message) (\(.location.path):\(.location.start.line // "?"))"
    ' 2>/dev/null \
  || true
)

if [[ -n "$A11Y" ]]; then
  REASON="Do not finish yet — frontend files you edited still have accessibility violations (per .claude/rules/accessibility.md):\n\nA11y violations in changed files:\n${A11Y}\n\nFix them, then stop."
  jq -n --arg r "$REASON" '{decision: "block", reason: $r}'
  exit 0
fi

exit 0
