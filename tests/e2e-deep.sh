#!/usr/bin/env bash
# Deep e2e runner, one nvim per tests/deep/<area>.sh: ./tests/e2e-deep.sh [area...]
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

areas=("$@")
if [ "${#areas[@]}" -eq 0 ]; then
  for script in "$HERE"/deep/*.sh; do
    areas+=("$(basename "$script" .sh)")
  done
fi

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
    # died before its summary: count it as failed, never as a silent pass
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
