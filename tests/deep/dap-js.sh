#!/usr/bin/env bash
# Deep e2e, dap-js: node/typescript and react-in-chrome debugging with js-debug.
# Run alone: ./tests/deep/dap-js.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup dap-js
deep_boot frontend/src/worker.ts

# ---------------------------------------------------------------- typescript
open_file frontend/src/lib/math.ts
goto_line 9
keys Space b c "number == 3" Enter
open_file frontend/src/worker.ts
keys Space d c
wait_screen "the config menu lists the node and chrome configs" "Attach to Chrome" 20
keys 1 Enter
wait_lexpr "typescript session stops on the conditional breakpoint" "$(session_stopped)" 60
wait_lexpr "it stopped on the loop line in math.ts" "$(frame_line 9)" 10
keys Space d k
wait_lexpr "step into works in typescript" "$(frame_name double)" 20
keys Space d t
wait_lexpr "the typescript session terminates" "$(no_session)" 25
keys Space b r

# ---------------------------------------------------------------- react in chrome
(cd "$MONO/frontend" && npm run dev >/dev/null 2>&1) &
for _ in $(seq 1 40); do
  curl -s -m 1 http://localhost:5173/ >/dev/null && break
  sleep 1
done
open_file frontend/src/App.tsx
goto_line 7
keys Space b b
keys Space d c
wait_screen "the config menu offers the chrome launch" "Launch Chrome" 20
keys 4 Enter
wait_screen "it asks for the dev server url with a default" "localhost:5173" 15
keys Enter
wait_lexpr "chrome stops inside the react component" "$(session_stopped)" 90
wait_lexpr "it stopped on the component's total line" "$(frame_line 7)" 10
keys Space d t
wait_lexpr "the react session terminates" "$(no_session)" 25
keys Space b r

deep_finish
