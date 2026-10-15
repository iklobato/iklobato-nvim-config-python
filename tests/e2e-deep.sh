#!/usr/bin/env bash
# Deep end-to-end suite. Same driver as e2e.sh (real tmux keystrokes, real RPC
# assertions) but over a realistic monorepo, pressing nearly every keymap this
# config defines (see tests/MANUAL.md for the handful it deliberately skips)
# and exercising every debug feature in python, go, typescript and react.
#
# Each area lives in tests/deep/<area>.sh and runs in its own nvim.
# Run: ./tests/e2e-deep.sh            every area
#      ./tests/e2e-deep.sh lsp tools  only those areas
# Exits 0 when every check passes. The monorepo is cached under
# ~/.cache/nvim-e2e-deep, so only the first run pays for npm install and the
# backend venv.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

areas=("$@")
if [ "${#areas[@]}" -eq 0 ]; then
  for script in "$HERE"/deep/*.sh; do
    areas+=("$(basename "$script" .sh)")
  done
fi

# built once up front, so its npm/pip output does not land inside an area
"$HERE/fixtures/monorepo.sh" "${XDG_CACHE_HOME:-$HOME/.cache}/nvim-e2e-deep/monorepo" || exit 1

passed=0
total=0
failed_areas=()
for area in "${areas[@]}"; do
  script="$HERE/deep/$area.sh"
  if [ ! -x "$script" ]; then
    echo "no such area: $area (expected $script)"
    failed_areas+=("$area")
    continue
  fi
  echo "=== $area"
  output="$("$script" 2>&1)"
  status=$?
  printf '%s\n' "$output" | grep -E '^(PASS|FAIL)  |checks passed|stopped answering'
  counts="$(printf '%s\n' "$output" | grep -oE '^[0-9]+/[0-9]+ ' | tail -1)"
  if [ -z "$counts" ]; then
    # an area that died before its summary has no count to add, and must not
    # look like a pass because of that
    echo "FAIL  $area ended without a summary (exit $status)"
    printf '%s\n' "$output" | tail -5
    failed_areas+=("$area")
    continue
  fi
  passed=$((passed + ${counts%/*}))
  total=$((total + ${counts#*/}))
  [ "$status" -eq 0 ] || failed_areas+=("$area")
done

echo
echo "$passed/$total deep checks passed"
if [ "${#failed_areas[@]}" -gt 0 ]; then
  echo "areas with failures: ${failed_areas[*]}"
  exit 1
fi
