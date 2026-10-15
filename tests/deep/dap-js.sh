#!/usr/bin/env bash
# Deep e2e, dap-js: js-debug for node, typescript, attach and react in chrome.
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup dap-js
deep_boot frontend/src/worker.ts

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

open_file langs/count.js
goto_line 3
keys Space b b
keys Space d c
wait_screen "the config menu is up for a .js file" "Attach to node port" 20
keys 1 Enter
wait_lexpr "node Launch file stops in a plain .js file" "$(session_stopped)" 60
wait_lexpr "it stopped on the loop body" "$(frame_line 3)" 10
# the loop runs three times: drop the breakpoint or continue stops again
keys Space b r
keys Space d c
wait_lexpr "the .js run continues to the end" "$(no_session)" 40

node --inspect=127.0.0.1:9229 "$MONO/langs/wait.js" >/dev/null 2>&1 &
inspect_pid=$!
open_file langs/wait.js
goto_line 3
keys Space b b
keys Space d c
wait_screen "the config menu is up for the port attach" "Attach to node port" 20
keys 3 Enter
wait_lexpr "attach to node port 9229 stops inside the interval" "$(session_stopped)" 60
wait_lexpr "it stopped on the counter line" "$(frame_line 3)" 10
keys Space d d
wait_lexpr "the port attach disconnects" "$(no_session)" 25
kill "$inspect_pid" 2>/dev/null

# pid attach needs node already on --inspect; 9339 (not 9229) proves the pid path
node --inspect=127.0.0.1:9339 "$MONO/langs/wait.js" >/dev/null 2>&1 &
plain_pid=$!
keys Space d c
wait_screen "the config menu is up for the process attach" "Attach to process" 20
keys 2 Enter
wait_screen "attach asks for part of the process name" "Process name contains" 15
keys "langs/wait.js" Enter
picked=""
for _ in $(seq 1 30); do
  picked=$(screen | grep -E "^ *[0-9]+: id=$plain_pid " | head -1 | grep -oE '^ *[0-9]+' | tr -d ' ')
  [ -n "$picked" ] && break
  sleep 0.5
done
if [ -n "$picked" ]; then
  ok "the filtered picker lists the running node process"
  keys "$picked" Enter
  wait_lexpr "attach to process stops inside the interval" "$(session_stopped)" 60
  keys Space d d
  wait_lexpr "the process attach disconnects" "$(no_session)" 25
else
  bad "the filtered picker lists the running node process" "$(screen | tail -3 | tr '\n' ' ')"
  keys Escape
fi
kill "$plain_pid" 2>/dev/null
keys Space b r

# --strictPort and a fixture-only file: else vite moves to 5174, 5173 is another app
(cd "$MONO/frontend" && npm run dev -- --strictPort >/dev/null 2>&1) &
dev_up=""
for _ in $(seq 1 40); do
  curl -s -m 1 http://localhost:5173/src/lib/shape.ts | grep -q "Square" && {
    dev_up=1
    break
  }
  sleep 1
done
if [ -n "$dev_up" ]; then
  ok "the fixture's vite dev server answers on 5173"
else
  bad "the fixture's vite dev server answers on 5173" "port 5173 busy or vite failed: $(lsof -nP -iTCP:5173 -sTCP:LISTEN 2>/dev/null | tail -1)"
fi
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

chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
profile="$(mktemp -d)/nvim-deep-chrome"
"$chrome" --headless=new --remote-debugging-port=9222 --user-data-dir="$profile" \
  --no-first-run --no-default-browser-check http://localhost:5173 >/dev/null 2>&1 &
chrome_pid=$!
for _ in $(seq 1 30); do
  curl -s -m 1 http://127.0.0.1:9222/json/version >/dev/null && break
  sleep 1
done
open_file frontend/src/App.tsx
goto_line 7
keys Space b b
keys Space d c
wait_screen "the config menu offers the chrome attach" "Attach to Chrome" 20
keys 5 Enter
wait_lexpr "attach to Chrome port 9222 stops inside the component" "$(session_stopped)" 90
wait_lexpr "it stopped on the component's total line" "$(frame_line 7)" 10
keys Space d d
wait_lexpr "the chrome attach disconnects" "$(no_session)" 25
kill "$chrome_pid" 2>/dev/null
rm -rf "$(dirname "$profile")"
keys Space b r

deep_finish
