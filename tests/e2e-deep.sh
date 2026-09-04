#!/usr/bin/env bash
# Deep end-to-end suite. Same driver as e2e.sh (real tmux keystrokes, real RPC
# assertions) but over a realistic monorepo, pressing nearly every keymap this
# config defines (see tests/MANUAL.md for the handful it deliberately skips or
# only checks via maparg) and exercising every debug feature in python, go,
# typescript and react.
#
# Run: ./tests/e2e-deep.sh   Exits 0 when every check passes.
# The monorepo is cached under ~/.cache/nvim-e2e-deep, so only the first run
# pays for npm install and the backend venv.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$HERE/tmux_lib.sh"

MONO="${XDG_CACHE_HOME:-$HOME/.cache}/nvim-e2e-deep/monorepo"
S="nvim-deep-$$"
SUITE_LABEL=deep
SOCK="$(mktemp -d)/nvim.sock"

# the servers are started inside subshells, so $! is the subshell and killing it
# leaves the real python/node child holding its port
stop_django() {
  pkill -f "manage.py runserver" 2>/dev/null
  for _ in $(seq 1 20); do
    curl -s -m 1 http://127.0.0.1:8000/ >/dev/null || return 0
    sleep 1
  done
  return 0
}

cleanup() {
  stop_django
  pkill -f "$MONO/frontend.*vite" 2>/dev/null
  pkill -f "npm run dev" 2>/dev/null
  tmux kill-session -t "$S" 2>/dev/null
  rm -rf "$(dirname "$SOCK")"
  return 0
}
trap cleanup EXIT

"$HERE/fixtures/monorepo.sh" "$MONO" || exit 1
# the python adapter follows VIRTUAL_ENV, and the fixture's venv is the one
# with django and a working pytest
export VIRTUAL_ENV="$MONO/backend/.venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"

# focus a window by filetype. The keys sent into the panel afterwards are real;
# only the jump is scripted, because <C-w> hops through a 5-window layout are
# too brittle to assert on.
focus_ft() {
  lexpr '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "'"$1"'" then vim.api.nvim_set_current_win(w) return 1 end end return 0 end)()' >/dev/null
}

# a phase that starts from whatever the previous one left behind cascades its
# failures, so every file switch closes floats and splits and is asserted
open_file() { # relative-path
  local base=${1##*/}
  keys Escape Escape
  keys Escape ":silent! cclose" Enter
  keys Escape ":silent! only" Enter
  keys Escape ":e $1" Enter
  wait_lexpr "opened $base" 'vim.fn.expand("%:t") == "'"$base"'" and 1 or 0' 15
}

goto_line() { keys Escape ":$1" Enter; }

# f/w counting breaks the moment a fixture line changes; searching does not
cursor_on() { # word
  keys Escape "0"
  keys Escape "/$1" Enter
  keys Escape
  wait_lexpr "cursor sits on $1" 'vim.fn.expand("<cword>") == "'"$1"'" and 1 or 0' 10
}

bp_count() {
  echo '(function() local n = 0 for _, bp in pairs(require("dap.breakpoints").get()) do n = n + #bp end return n end)()'
}

session_stopped() {
  echo '(function() local s = require("dap").session() return (s and s.stopped_thread_id and s.current_frame) and 1 or 0 end)()'
}

frame_line() {
  echo '(function() local s = require("dap").session() return (s and s.current_frame and s.current_frame.line == '"$1"') and 1 or 0 end)()'
}

frame_name() {
  echo '(function() local s = require("dap").session() return (s and s.current_frame and s.current_frame.name:match("'"$1"'")) and 1 or 0 end)()'
}

no_session() { echo 'require("dap").session() == nil and 1 or 0'; }

win_with_ft() {
  echo '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "'"$1"'" then return 1 end end return 0 end)()'
}

# ---------------------------------------------------------------- boot
cd "$MONO" || exit 1
tmux new-session -d -s "$S" -x 220 -y 60 "nvim --listen '$SOCK' backend/core/services.py"
wait_lexpr "nvim boots on the monorepo and answers RPC" "1" 20
wait_screen "lualine renders" "NORMAL" 15
wait_screen "bufferline shows the open file" "services.py"

# ---------------------------------------------------------------- motions
goto_line 2
keys L
wait_lexpr "keymap L jumps to end of line" 'vim.fn.col(".") >= 22 and 1 or 0'
keys H
wait_lexpr "keymap H jumps to first non-blank" 'vim.fn.col(".") == 5 and 1 or 0'
goto_line 9
keys "0"
keys B
wait_lexpr "keymap B moves a word forward" 'vim.fn.col(".") > 1 and 1 or 0'
keys Escape '$'
keys W
wait_lexpr "keymap W moves a word back" 'vim.fn.col(".") < vim.fn.col("$") - 1 and 1 or 0'
goto_line 7
keys Space j
wait_lexpr "keymap <leader>j moves down a screen line" 'vim.fn.line(".") == 8 and 1 or 0'
keys Space k
wait_lexpr "keymap <leader>k moves up a screen line" 'vim.fn.line(".") == 7 and 1 or 0'

# ---------------------------------------------------------------- windows
keys Space s v
wait_lexpr "keymap <leader>sv splits vertically" '#vim.api.nvim_tabpage_list_wins(0) == 2 and 1 or 0'
keys Space s h
wait_lexpr "keymap <leader>sh splits horizontally" '#vim.api.nvim_tabpage_list_wins(0) == 3 and 1 or 0'
keys Space s e
wait_lexpr "keymap <leader>se equalizes without closing windows" '#vim.api.nvim_tabpage_list_wins(0) == 3 and 1 or 0'
keys Space s m
wait_lexpr "keymap <leader>sm maximizes the current split" 'vim.api.nvim_win_get_height(0) > 40 and 1 or 0'
keys Space s m
wait_lexpr "keymap <leader>sm restores the layout" 'vim.api.nvim_win_get_height(0) < 40 and 1 or 0'
keys Escape ":only" Enter
wait_lexpr "layout back to a single window" '#vim.api.nvim_tabpage_list_wins(0) == 1 and 1 or 0'

# ---------------------------------------------------------------- tabs
keys Space t o
wait_lexpr "keymap <leader>to opens a tab" 'vim.fn.tabpagenr("$") == 2 and 1 or 0'
keys Space t p
wait_lexpr "keymap <leader>tp goes to the previous tab" 'vim.fn.tabpagenr() == 1 and 1 or 0'
keys Space t n
wait_lexpr "keymap <leader>tn goes to the next tab" 'vim.fn.tabpagenr() == 2 and 1 or 0'
keys Escape ":tabclose" Enter
wait_lexpr "back to one tab" 'vim.fn.tabpagenr("$") == 1 and 1 or 0'

# ---------------------------------------------------------------- explorer
keys Space e e
wait_lexpr "keymap <leader>ee opens nvim-tree" "$(win_with_ft NvimTree)"
keys Space e e
wait_lexpr "keymap <leader>ee closes nvim-tree" "(function() return $(win_with_ft NvimTree) == 1 and 0 or 1 end)()"
keys Space e f
wait_lexpr "keymap <leader>ef reveals the file in the tree" "$(win_with_ft NvimTree)"
wait_screen "the revealed file is on screen" "services.py"
keys Space e e

# ---------------------------------------------------------------- buffers
keys Escape ":silent! %bd!" Enter
open_file backend/core/services.py
open_file notes.md
keys Space b p
wait_lexpr "keymap <leader>bp leaves the current buffer" 'vim.fn.expand("%:t") ~= "notes.md" and 1 or 0'
keys Space b n
wait_lexpr "keymap <leader>bn goes to the next buffer" 'vim.fn.expand("%:t") == "notes.md" and 1 or 0'
keys Space b d
wait_lexpr "keymap <leader>bd closes the buffer" 'vim.fn.expand("%:t") ~= "notes.md" and 1 or 0'

# ---------------------------------------------------------------- save
open_file backend/core/services.py
keys G o "# touched by the deep suite" Escape
wait_lexpr "buffer is modified after typing" 'vim.bo.modified and 1 or 0'
keys Space w w
wait_lexpr "keymap <leader>ww saves the buffer" 'vim.bo.modified == false and 1 or 0'
keys u
keys Space w w

# ---------------------------------------------------------------- telescope
keys Space f f
wait_lexpr "keymap <leader>ff opens the file picker" "$(win_with_ft TelescopePrompt)"
keys "services"
wait_screen "file picker filters as you type" "> services"
keys Escape Escape
keys Space f g
wait_lexpr "keymap <leader>fg opens live grep" "$(win_with_ft TelescopePrompt)"
keys "summarize"
wait_screen "live grep finds the symbol across the monorepo" "> summarize"
keys Escape Escape
keys Space f b
wait_lexpr "keymap <leader>fb opens the buffer picker" "$(win_with_ft TelescopePrompt)"
keys Escape Escape

# ---------------------------------------------------------------- lsp
wait_lexpr "pyright attaches to the backend file" \
  '#vim.lsp.get_clients({ bufnr = vim.fn.bufnr("services.py") }) > 0 and 1 or 0' 40
keys Space f o
wait_lexpr "keymap <leader>fo opens the symbol picker" "$(win_with_ft TelescopePrompt)" 15
keys Escape Escape
goto_line 9
cursor_on double
keys g d
wait_lexpr "keymap gd jumps to the definition of double()" 'vim.fn.line(".") == 1 and 1 or 0' 15
goto_line 9
cursor_on double
keys K
wait_lexpr "keymap K opens the hover float" \
  '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= "" then return 1 end end return 0 end)()' 15
keys Escape
keys g r
wait_lexpr "keymap gr fills the quickfix with references" '#vim.fn.getqflist() > 0 and 1 or 0' 15
keys Escape ":cclose" Enter
keys g i
wait_lexpr "keymap gi runs without wedging nvim" "1" 10
goto_line 9
cursor_on double
keys Space g d
wait_lexpr "keymap <leader>gd opens the definition in a split" '#vim.api.nvim_tabpage_list_wins(0) >= 2 and 1 or 0' 15
open_file backend/core/services.py
goto_line 9
cursor_on double
keys Space g r
wait_lexpr "keymap <leader>gr opens references in telescope" "$(win_with_ft TelescopePrompt)" 15
keys Escape Escape
open_file backend/core/services.py
goto_line 1
cursor_on double
keys Space r n
keys "renamed_double" Enter
wait_lexpr "keymap <leader>rn renames the symbol across the buffer" \
  '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:match("renamed_double") then return 1 end end return 0 end)()' 20
keys Escape "u"
keys Space c a
wait_lexpr "keymap <leader>ca runs without wedging nvim" "1" 10
keys Escape Escape

# ---------------------------------------------------------------- diagnostics
open_file backend/core/legacy.py
wait_lexpr "ruff reports the unused imports in legacy.py" \
  '#vim.diagnostic.get(0) > 0 and 1 or 0' 60
goto_line 8
keys "[" d
wait_lexpr "keymap [d jumps back to a diagnostic" 'vim.fn.line(".") <= 2 and 1 or 0'
goto_line 8
keys Space g p
wait_lexpr "keymap <leader>gp jumps back to a diagnostic" 'vim.fn.line(".") <= 2 and 1 or 0'
goto_line 1
keys "]" d
wait_lexpr "keymap ]d jumps to the next diagnostic" 'vim.fn.line(".") == 2 and 1 or 0'
goto_line 1
keys Space g n
wait_lexpr "keymap <leader>gn jumps to the next diagnostic" 'vim.fn.line(".") == 2 and 1 or 0'
goto_line 1
keys Space e
wait_lexpr "keymap <leader>e opens the diagnostic float" \
  '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= "" then return 1 end end return 0 end)()' 10
keys Escape
keys Space E
wait_lexpr "keymap <leader>E opens a focusable diagnostic float" \
  '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= "" then return 1 end end return 0 end)()' 10
keys Escape

# ---------------------------------------------------------------- editing
open_file backend/core/services.py
keys G o "value    =    1" Escape
keys Space f
wait_lexpr "keymap <leader>f reformats the buffer with ruff" \
  '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l == "value = 1" then return 1 end end return 0 end)()' 20
keys Escape ":1" Enter
keys Space S
wait_screen "keymap <leader>S prefills the substitute command" ":%s/" 10
keys Escape
keys "O" "spaced    =    2" Escape
keys "V" Space f
wait_lexpr "keymap <leader>f formats a visual selection" \
  '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l == "spaced = 2" then return 1 end end return 0 end)()' 15
keys Escape ":e!" Enter

# ---------------------------------------------------------------- git and tools
keys Space g b
wait_lexpr "keymap <leader>gb toggles inline git blame" \
  'vim.g.gitblame_enabled == false and 1 or 0' 10
keys Space g b
wait_lexpr "keymap <leader>gb toggles it back on" \
  'vim.g.gitblame_enabled == true and 1 or 0' 10
open_file notes.md
wait_lexpr "gitsigns sees the second commit's hunk context" \
  'vim.b[vim.fn.bufnr("notes.md")].gitsigns_status_dict ~= nil and 1 or 0' 20
wait_lexpr "keymap <leader>mp is bound to MarkdownPreview" \
  'vim.fn.maparg(" mp", "n"):match("MarkdownPreview") ~= nil and 1 or 0' 10
wait_lexpr "keymap <leader>mP is bound to MarkdownPreviewStop" \
  'vim.fn.maparg(" mP", "n"):match("MarkdownPreviewStop") ~= nil and 1 or 0' 10
# a real server, so the request has something to answer it
(cd "$MONO/backend" && "$VIRTUAL_ENV/bin/python" manage.py runserver 8000 --noreload >/dev/null 2>&1) &
for _ in $(seq 1 30); do
  curl -s -m 1 http://127.0.0.1:8000/api/totals/ >/dev/null && break
  sleep 1
done
open_file api.http
keys Space r r
wait_screen "keymap <leader>rr runs the request and shows the response" "total" 30
# let kulala finish writing its response buffer: pulling the server out from
# under it raises a connection error and a hit-enter prompt
sleep 3
# the debugger starts its own server on 8000 later, so the port has to be free
stop_django
keys Space d b
wait_lexpr "keymap <leader>db opens the database UI" "$(win_with_ft dbui)" 15
# the drawer window exists before dadbod-ui has finished filling it, and a
# toggle sent into that gap is dropped
sleep 3
keys Escape
keys Space d b
wait_lexpr "keymap <leader>db closes the database UI" \
  "(function() return $(win_with_ft dbui) == 1 and 0 or 1 end)()" 25

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
wait_lexpr "keymap <leader>dj steps over" "$(session_stopped)" 20

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
  '#vim.lsp.get_clients({ bufnr = vim.fn.bufnr("test_services.py") }) > 0 and 1 or 0' 40
keys Space d p
wait_screen "keymap <leader>dp lists the tests of the file" "test_summarize" 20
keys Escape
keys Escape ":4" Enter "fd"
keys Space d f
wait_lexpr "keymap <leader>df debugs the test under the cursor" \
  '(function() local s = require("dap").session() return s ~= nil and 1 or 0 end)()' 40
wait_lexpr "the pytest session finishes" "$(no_session)" 60

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
    curl -s -m 3 http://127.0.0.1:8000/ >/dev/null && break
    sleep 1
  done
) &
wait_lexpr "a real request stops in the django view" "$(session_stopped)" 45
wait_lexpr "it stopped on the view's total line" "$(frame_line 8)" 10
keys Space d t
wait_lexpr "the django session terminates" "$(no_session)" 25
keys Space b r
keys Escape ":cd .." Enter

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

# ---------------------------------------------------------------- health
sleep 2
dismiss_prompts
if expr_ 'execute("messages")' | grep -qiE "E[0-9]{3}:|stack traceback"; then
  bad "no vim errors in :messages" "$(expr_ 'execute("messages")' | grep -iE "E[0-9]{3}:|stack traceback" | head -2 | tr '\n' ' ')"
else
  ok "no vim errors in :messages"
fi
if [ "${#PROMPTS[@]}" -gt 0 ]; then
  bad "no hit-enter prompts during the run" "${PROMPTS[0]}"
else
  ok "no hit-enter prompts during the run"
fi

# ---------------------------------------------------------------- quit keymaps
open_file notes.md
keys Space t o
open_file backend/demo.py
keys G o "trailing" Escape
keys Space w q
wait_lexpr "keymap <leader>wq saves and closes the window" 'vim.fn.tabpagenr("$") == 1 and 1 or 0' 15
open_file backend/demo.py
keys u
keys Escape ":w" Enter
keys Space t o
keys G o "unsaved" Escape
keys Space q q
wait_lexpr "keymap <leader>qq quits without saving" 'vim.fn.tabpagenr("$") == 1 and 1 or 0' 15

keys Escape ":qa!" Enter
for _ in $(seq 1 20); do
  tmux has-session -t "$S" 2>/dev/null || break
  sleep 0.5
done
if tmux has-session -t "$S" 2>/dev/null; then
  bad "nvim quits cleanly" "tmux session still alive"
else
  ok "nvim quits cleanly"
fi

summary deep
