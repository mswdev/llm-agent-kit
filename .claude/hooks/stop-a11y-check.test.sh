#!/usr/bin/env bash
# Smoke test for stop-a11y-check.sh. Stubs the linter (A11Y_LINT_CMD) and the
# changed file list (A11Y_CHANGED_FILES) so every decision branch — crucially
# the fail-CLOSED guard when the linter cannot run — is exercised
# deterministically, without a linter or git state.
#   Run: bash .claude/hooks/stop-a11y-check.test.sh
set -uo pipefail

HOOK="$(cd "$(dirname "$0")" && pwd)/stop-a11y-check.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0 FAIL=0

# Linter stubs (ignore args, emit fixed stdout). `clean` mimics Biome's real
# envelope; `broken` mimics a crash (no parseable JSON on stdout).
printf '#!/usr/bin/env bash\necho '\''{"diagnostics":[{"category":"lint/a11y/useAltText","message":"Provide a text alternative","location":{"path":"src/X.tsx","start":{"line":3}}}]}'\''\n' >"$TMP/violation"
printf '#!/usr/bin/env bash\necho '\''{"command":"check","diagnostics":[],"summary":{}}'\''\n' >"$TMP/clean"
printf '#!/usr/bin/env bash\necho "error: linter crashed" >&2; exit 1\n' >"$TMP/broken"
chmod +x "$TMP/violation" "$TMP/clean" "$TMP/broken"

ACTIVE='{"stop_hook_active":true}'
INACTIVE='{"stop_hook_active":false}'
WEB="src/components/X.tsx"

# run <stdin-json> [VAR=val ...] -> hook stdout
run() { local input="$1"; shift; echo "$input" | env "$@" bash "$HOOK" 2>/dev/null || true; }

# check <name> <expect-substring|EMPTY> <actual-output>
check() {
  local name="$1" expect="$2" out="$3" ok=0
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

check "loop guard allows stop"             EMPTY                  "$(run "$ACTIVE"   A11Y_CHANGED_FILES="$WEB" A11Y_LINT_CMD="$TMP/violation")"
check "no changed files allows stop"       EMPTY                  "$(run "$INACTIVE" A11Y_CHANGED_FILES=)"
check "clean lint allows stop"             EMPTY                  "$(run "$INACTIVE" A11Y_CHANGED_FILES="$WEB" A11Y_LINT_CMD="$TMP/clean")"
check "a11y violation blocks"              "A11y violations"      "$(run "$INACTIVE" A11Y_CHANGED_FILES="$WEB" A11Y_LINT_CMD="$TMP/violation")"
check "linter crash blocks (fail-closed)"  "could not run"        "$(run "$INACTIVE" A11Y_CHANGED_FILES="$WEB" A11Y_LINT_CMD="$TMP/broken")"

echo "---"
echo "$PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
