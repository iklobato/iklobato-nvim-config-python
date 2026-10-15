#!/usr/bin/env bash
# Deep e2e, dap-python: breakpoints and every python debug config: launch, pytest, django, asyncio, uvicorn.
# Run alone: ./tests/deep/dap-python.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup dap-python
deep_boot backend/core/services.py

# ---------------------------------------------------------------- breakpoints
open_file backend/core/services.py
goto_line 2
keys Space b b
wait_lexpr "keymap <leader>bb sets a breakpoint" "$(bp_count) == 1 and 1 or 0"
keys Space b b
wait_lexpr "keymap <leader>bb removes it again" "$(bp_count) == 0 and 1 or 0"
goto_line 9
keys Space b c "number == 3" Enter
wait_lexpr "keymap <leader>bc sets a conditional breakpoint" "$(bp_count) == 1 and 1 or 0"
goto_line 3
keys Space b l "dbl {doubled}" Enter
wait_lexpr "keymap <leader>bl sets a logpoint" "$(bp_count) == 2 and 1 or 0"
keys Space b a
wait_lexpr "keymap <leader>ba lists breakpoints in the quickfix" '#vim.fn.getqflist() == 2 and 1 or 0' 10
keys Escape ":cclose" Enter
keys Space b r
wait_lexpr "keymap <leader>br clears every breakpoint" "$(bp_count) == 0 and 1 or 0"

# ---------------------------------------------------------------- python session
goto_line 9
keys Space b c "number == 3" Enter
goto_line 3
keys Space b l "dbl {doubled}" Enter
open_file backend/demo.py
keys Space d c
wait_screen "the config menu lists the python configs" "Django runserver" 20
keys 1 Enter
wait_lexpr "python session stops on the conditional breakpoint" "$(session_stopped)" 60
wait_lexpr "it stopped on the loop line in services.py" "$(frame_line 9)" 10
wait_lexpr "dap-ui opened with the session" "$(win_with_ft dapui_scopes)" 15
wait_screen "the logpoint messages reached the REPL" "dbl " 15
keys Space d k
wait_lexpr "keymap <leader>dk steps into double()" "$(frame_name double)" 20
keys Space d o
wait_lexpr "keymap <leader>do steps back out to summarize()" "$(frame_name summarize)" 20
keys Space d j
# step out lands back on the loop body's line 9; a step over has to leave it
wait_lexpr "keymap <leader>dj steps over to another line" \
  '(function() local s = require("dap").session() local f = s and s.current_frame return (f and f.line ~= 9 and f.name:match("summarize")) and 1 or 0 end)()' 20

focus_ft dapui_watches
keys i "total * 10" Enter
wait_lexpr "a watch expression is registered and evaluated" \
  '(function() local w = require("dapui").elements.watches.get() for _, e in ipairs(w) do if e.expression == "total * 10" then return 1 end end return 0 end)()' 20
keys Escape

focus_ft dap-repl
lexpr '(function() _G.__repl_lines_before = #vim.api.nvim_buf_get_lines(0, 0, -1, true) return 1 end)()' >/dev/null
keys i "total" Enter
wait_lexpr "the REPL answers an expression" \
  '(function() return (#vim.api.nvim_buf_get_lines(0, 0, -1, true) > (_G.__repl_lines_before or 0)) and 1 or 0 end)()' 15
keys Escape

keys Space d u
wait_lexpr "keymap <leader>du hides the UI" \
  "(function() return $(win_with_ft dapui_scopes) == 1 and 0 or 1 end)()" 15
keys Space d u
wait_lexpr "keymap <leader>du shows the UI again" "$(win_with_ft dapui_scopes)" 15
keys Space d c
wait_lexpr "keymap <leader>dc continues to the end of the run" "$(no_session)" 30
# run_last re-expands ${file}, and the debugger left the cursor in services.py
open_file backend/demo.py
keys Space d l
wait_lexpr "keymap <leader>dl reruns the last config without the menu" "$(session_stopped)" 40
keys Space d t
wait_lexpr "keymap <leader>dt terminates the session" "$(no_session)" 25
open_file backend/demo.py
keys Space d l
wait_lexpr "another run for the disconnect check" "$(session_stopped)" 40
keys Space d d
wait_lexpr "keymap <leader>dd disconnects the session" "$(no_session)" 25
keys Space b r

# ---------------------------------------------------------------- pytest
open_file backend/tests/test_services.py
wait_lexpr "pyright attaches to the test file" \
  '#vim.lsp.get_clients({ bufnr = vim.fn.bufnr("test_services.py"), name = "pyright" }) > 0 and 1 or 0' 40
# a breakpoint inside the method proves which pytest target was built: only
# "TestServices::test_double_negative" reaches line 16
goto_line 16
keys Space b b
wait_lexpr "breakpoint inside TestServices.test_double_negative" "$(bp_count) == 1 and 1 or 0"
keys Space d p
# Class::method is only ever written in the picker, never in the buffer
wait_screen "keymap <leader>dp lists the class method as Class::method" "TestServices::test_double_negative" 20
choice=$(screen | grep -oE '^ *[0-9]+: TestServices::test_double_negative' | head -1 | grep -oE '[0-9]+' | head -1)
keys "${choice:-0}" Enter
wait_lexpr "picking it in <leader>dp stops inside the method" "$(session_stopped)" 60
wait_lexpr "the dp session stopped on line 16 of test_double_negative" \
  "($(frame_line 16) == 1 and $(frame_name test_double_negative) == 1) and 1 or 0" 10
keys Space d c
wait_lexpr "the dp pytest run finishes" "$(no_session)" 60
keys Space d p
wait_screen "the dp picker is up again" "Manual (type pytest target)" 20
keys 1 Enter
wait_screen "the Manual entry asks for a pytest target" "Pytest target (e.g." 10
keys "TestServices::test_double_negative" Enter
wait_lexpr "a typed Manual target stops inside the method" "$(frame_name test_double_negative)" 60
keys Space d c
wait_lexpr "the Manual pytest run finishes" "$(no_session)" 60
goto_line 15
cursor_on test_double_negative
keys Space d f
wait_lexpr "keymap <leader>df resolves the method under the cursor to Class::method" "$(session_stopped)" 60
wait_lexpr "the df session stopped inside test_double_negative" "$(frame_name test_double_negative)" 10
keys Space d c
wait_lexpr "the df pytest run finishes" "$(no_session)" 60
keys Space b r

# ---------------------------------------------------------------- django
# the Django config launches ${workspaceFolder}/manage.py, so the working
# directory has to be the django project, not the monorepo root
keys Escape ":cd backend" Enter
open_file core/views.py
goto_line 8
keys Space b b
keys Space d c
wait_screen "the config menu is up for the django run" "Django runserver" 20
keys 2 Enter
(
  for _ in $(seq 1 45); do
    curl -s -m 3 -o /dev/null http://127.0.0.1:8000/
    # 28 is curl's timeout: the request is held at the breakpoint. A fast answer
    # means the server is not up yet and something else on the port replied
    [ $? -eq 28 ] && break
    sleep 1
  done
) &
wait_lexpr "a real request stops in the django view" "$(session_stopped)" 45
wait_lexpr "it stopped on the view's total line" "$(frame_line 8)" 10
keys Space d t
wait_lexpr "the django session terminates" "$(no_session)" 25
keys Space b r

# ---------------------------------------------------------------- asyncio
open_file async_demo.py
keys Space b e
wait_screen "keymap <leader>be lists the exception stop modes" "user unhandled" 15
keys 2 Enter
keys Space d c
wait_screen "the config menu lists the uvicorn config" "Uvicorn" 20
keys 1 Enter
wait_lexpr "the error lost in an asyncio task stops the session" "$(session_stopped)" 60
wait_lexpr "it stopped on the raise inside the task" "$(frame_line 6)" 10
lexpr '(function() local s = require("dap").session() s:request("evaluate", { expression = "asyncio.get_running_loop().get_debug()", frameId = s.current_frame.id, context = "repl" }, function(_, r) _G.__loop_debug = r and r.result end) return 1 end)()' >/dev/null
wait_lexpr "Launch file runs the event loop in asyncio debug mode" '_G.__loop_debug == "True" and 1 or 0' 15
keys Space d c
wait_lexpr "the asyncio run finishes after the stop" "$(no_session)" 30
keys Space b e
keys 1 Enter
wait_lexpr "keymap <leader>be puts back the uncaught-only default" \
  '(function() local f = require("dap").defaults.python.exception_breakpoints return (#f == 1 and f[1] == "uncaught") and 1 or 0 end)()' 10

open_file asgi_demo.py
goto_line 4
keys Space b b
keys Space d c
wait_screen "the config menu is up for the uvicorn run" "Uvicorn" 20
keys 4 Enter
wait_screen "it asks for the ASGI app with a default" "main:app" 15
keys C-u "asgi_demo:app" Enter
(
  for _ in $(seq 1 45); do
    curl -s -m 3 -o /dev/null http://127.0.0.1:8000/
    # same as the django probe: only a request held at the breakpoint stops it
    [ $? -eq 28 ] && break
    sleep 1
  done
) &
wait_lexpr "a real request stops in the ASGI app" "$(session_stopped)" 45
wait_lexpr "it stopped on the app's total line" "$(frame_line 4)" 10
keys Space d t
wait_lexpr "the uvicorn session terminates" "$(no_session)" 25
keys Space b r
keys Escape ":cd .." Enter

deep_finish
