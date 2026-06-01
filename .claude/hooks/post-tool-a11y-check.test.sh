#!/usr/bin/env bash
# Smoke test for post-tool-a11y-check.sh. Stubs the linter via A11Y_LINT_CMD so
# every decision branch runs deterministically without a linter installed.
#   Run: bash .claude/hooks/post-tool-a11y-check.test.sh
set -uo pipefail

HOOK="$(cd "$(dirname "$0")" && pwd)/post-tool-a11y-check.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0 FAIL=0

# Stub linters (ignore the file arg, emit fixed stdout) for deterministic runs.
printf '#!/usr/bin/env bash\necho '\''{"diagnostics":[{"category":"lint/a11y/useAltText","message":"Provide a text alternative","location":{"start":{"line":3}}}]}'\''\n' >"$TMP/violation"
printf '#!/usr/bin/env bash\necho '\''{"diagnostics":[]}'\''\n' >"$TMP/clean"
printf '#!/usr/bin/env bash\necho "error: linter not found" >&2; exit 127\n' >"$TMP/broken"
chmod +x "$TMP/violation" "$TMP/clean" "$TMP/broken"

p() { jq -nc --arg t "$1" --arg f "$2" '{tool_name:$t, tool_input:{file_path:$f}}'; }

# assert <name> <expect-substring|EMPTY> <payload> [A11Y_LINT_CMD]
assert() {
  local name="$1" expect="$2" payload="$3" cmd="${4:-}" out
  out=$(echo "$payload" | A11Y_LINT_CMD="$cmd" bash "$HOOK" 2>/dev/null || true)
  local ok=0
  if [[ "$expect" == "EMPTY" ]]; then
    [[ -z "$out" ]] && ok=1
  else
    echo "$out" | grep -q "$expect" && ok=1
  fi
  if [[ "$ok" -eq 1 ]]; then
    echo "PASS  $name"
    PASS=$((PASS + 1))
  else
    echo "FAIL  $name"
    echo "   expected: $expect"
    echo "   got: ${out:-<empty>}"
    FAIL=$((FAIL + 1))
  fi
}

# Default FRONTEND_DIRS is empty → any .tsx/.jsx qualifies; backend .ts does not.
assert "non-edit tool no-ops"          EMPTY                "$(p Read  src/X.tsx)"
assert "backend .ts no-ops"            EMPTY                "$(p Write src/s.ts)"
assert "app-router .tsx + violation"   "A11Y LINT: Found 1" "$(p Write app/page.tsx)"         "$TMP/violation"
assert "src .jsx + violation"          "A11Y LINT: Found 1" "$(p Edit  src/components/B.jsx)"  "$TMP/violation"
assert "clean frontend stays silent"   EMPTY                "$(p Write app/page.tsx)"          "$TMP/clean"
assert "linter failure is surfaced"    "could not run"      "$(p Write app/page.tsx)"          "$TMP/broken"

echo "---"
echo "$PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
