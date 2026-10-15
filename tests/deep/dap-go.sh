#!/usr/bin/env bash
# Deep e2e, dap-go: go debugging with delve.
# Run alone: ./tests/deep/dap-go.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup dap-go
deep_boot service/main.go

# ---------------------------------------------------------------- go
open_file service/main.go
open_file service/math.go
goto_line 11
keys Space b c "number == 3" Enter
open_file service/main.go
keys Space d c
wait_screen "the config menu lists the go configs" "Test package" 20
keys 2 Enter
wait_lexpr "go session stops on the conditional breakpoint" "$(session_stopped)" 60
wait_lexpr "it stopped on the loop line in math.go" "$(frame_line 11)" 10
keys Space d k
wait_lexpr "step into works in go" "$(frame_name double)" 20
keys Space d t
wait_lexpr "the go session terminates" "$(no_session)" 25
keys Space b r
open_file service/math_test.go
goto_line 6
keys Space b b
keys Space d c
wait_screen "the config menu is up for the go test run" "Test package" 20
keys 3 Enter
wait_lexpr "go test package stops inside TestDouble" "$(session_stopped)" 60
keys Space d t
wait_lexpr "the go test session terminates" "$(no_session)" 25
keys Space b r

# ---------------------------------------------------------------- launch file
open_file service/cmd/hello/main.go
goto_line 8
keys Space b b
keys Space d c
wait_screen "the config menu is up for launch file" "Launch file" 20
keys 1 Enter
wait_lexpr "go Launch file stops in the single-file program" "$(session_stopped)" 60
wait_lexpr "it stopped on the loop body" "$(frame_line 8)" 10
keys Space d t
wait_lexpr "the launch file session terminates" "$(no_session)" 25
keys Space b r

# ---------------------------------------------------------------- attach to process
# the picker first asks for part of the process name, then lists only the
# matches; the one this suite started is picked by its number on screen
waiter="$MONO/service/cmd/wait/deep-wait"
(cd "$MONO/service" && go build -gcflags=all="-N -l" -o "$waiter" ./cmd/wait >/dev/null 2>&1)
"$waiter" >/dev/null 2>&1 &
waiter_pid=$!
open_file service/cmd/wait/main.go
goto_line 9
keys Space b b
keys Space d c
wait_screen "the config menu is up for attach" "Attach to process" 20
keys 4 Enter
wait_screen "attach asks for part of the process name" "Process name contains" 15
keys "deep-wait" Enter
picked=""
for _ in $(seq 1 30); do
  # the binary itself, not a shell whose command line mentions deep-wait
  picked=$(screen | grep -E "^ *[0-9]+: id=[0-9]+ name=[^ ]*/deep-wait$" | head -1 | grep -oE '^ *[0-9]+' | tr -d ' ')
  [ -n "$picked" ] && break
  sleep 0.5
done
if [ -n "$picked" ] && ! screen | grep -q -- "-- More --"; then
  ok "the filtered picker fits on one screen and lists the waiting go program"
  keys "$picked" Enter
  wait_lexpr "go attach stops inside the running loop" "$(session_stopped)" 60
  wait_lexpr "it stopped in tick()" "$(frame_name tick)" 10
  keys Space d d
  wait_lexpr "the attach session disconnects" "$(no_session)" 25
else
  bad "the filtered picker fits on one screen and lists the waiting go program" "$(screen | tail -3 | tr '\n' ' ')"
  keys Escape
fi
kill "$waiter_pid" 2>/dev/null
rm -f "$waiter"
keys Space b r

deep_finish
