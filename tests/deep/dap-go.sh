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

deep_finish
