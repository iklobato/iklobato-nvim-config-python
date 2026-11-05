#!/usr/bin/env bash
# Deep e2e, stress: intensive interleaved use. Tests combinations and coexistence
# the per-feature areas miss (feature A still live while B runs), in one long
# session. No server, browser or port: debug runs demo.py, a single file.
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup stress
deep_boot backend/core/services.py

TMP="$(dirname "$SOCK")"

# --- 1. multi-language LSP coexistence across splits and tabs ----------------
keys Escape ":vsplit backend/core/views.py" Enter
wait_lexpr "combo: views.py opens in a vsplit beside services.py" \
  'vim.fn.expand("%:t") == "views.py" and #vim.api.nvim_tabpage_list_wins(0) == 2 and 1 or 0' 15
keys Escape ":tabnew frontend/src/lib/shape.ts" Enter
wait_lexpr "combo: shape.ts opens in a second tab" \
  'vim.fn.expand("%:t") == "shape.ts" and vim.fn.tabpagenr("$") == 2 and 1 or 0' 15
wait_lexpr "combo: pyright, ruff and ts_ls are all live in one session" \
  '(function() local n = {} for _, c in ipairs(vim.lsp.get_clients()) do n[c.name] = true end return (n.pyright and n.ruff and n.ts_ls) and 1 or 0 end)()' 45

# --- 2. matchit % and matchparen (re-enabled in this config) -----------------
keys Escape ":tabonly" Enter
open_file backend/core/services.py
keys Escape ":1" Enter
keys "0" f "("
wait_lexpr "cursor sits on the open paren" \
  'vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col(".")) == "(" and 1 or 0' 10
keys "%"
wait_lexpr "matchit: % jumps to the matching paren" \
  'vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col(".")) == ")" and 1 or 0' 10
wait_lexpr "matchparen and matchit plugins are loaded" \
  'vim.g.loaded_matchparen == 1 and vim.g.loaded_matchit == 1 and 1 or 0'

# --- 3. telescope driven over a live split ----------------------------------
keys Escape ":vsplit backend/core/views.py" Enter
wait_lexpr "two windows before the telescope-over-split check" \
  '#vim.api.nvim_tabpage_list_wins(0) == 2 and 1 or 0' 10
keys Space f f
wait_lexpr "combo: telescope opens over a live vsplit" "$(win_with_ft TelescopePrompt)" 15
keys "shape"
wait_screen "combo: telescope filters to the typed query" "> shape" 10
keys Escape Escape
keys Space f g
wait_lexpr "combo: live grep opens over the split" "$(win_with_ft TelescopePrompt)" 15
keys "summarize"
sleep 1
keys Enter
wait_lexpr "combo: a grep match opens its file on the matching line" \
  'vim.fn.getline("."):find("summarize") and 1 or 0' 15

# --- 4. format then save, on a disposable scratch (never the fixture) --------
SCRATCH="$TMP/scratch.lua"
printf 'local   x   =   {1,2}\n' >"$SCRATCH"
open_file "$SCRATCH"
keys Space F
wait_lexpr "combo: <leader>F reformats the scratch lua with stylua" \
  'vim.fn.getline(1) == "local x = { 1, 2 }" and 1 or 0' 15
keys Space w w
wait_lexpr "combo: <leader>ww then saves it clean" 'vim.bo.modified == false and 1 or 0' 10

# --- 5. diagnostics + code action, then rename, with two LSP buffers open ----
open_file backend/core/legacy.py
wait_lexpr "ruff reports the unused import in legacy.py" \
  '(function() for _, d in ipairs(vim.diagnostic.get(0)) do if tostring(d.message):find("unused") then return 1 end end return 0 end)()' 45
keys Escape ":vsplit backend/core/services.py" Enter
wait_lexpr "services.py opens beside legacy.py" 'vim.fn.expand("%:t") == "services.py" and 1 or 0' 20
wait_lexpr "pyright attaches to the services.py split before the rename" \
  '(function() for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do if c.name == "pyright" then return 1 end end return 0 end)()' 40
cursor_on double
keys Space r n
sleep 1
# C-u clears the prompt, which is prefilled with the current name
keys C-u "triple" Enter
wait_lexpr "combo: <leader>rn renames double to triple while legacy.py stays open" \
  '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:find("def triple") then return 1 end end return 0 end)()' 20
wait_lexpr "combo: both python split buffers still hold an LSP client" \
  '(function() local ok = 0 for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do if #vim.lsp.get_clients({ bufnr = vim.api.nvim_win_get_buf(w) }) > 0 then ok = ok + 1 end end return ok >= 2 and 1 or 0 end)()' 20
keys Escape ":silent! e!" Enter

# --- 6. a bigfile and a live LSP buffer side by side ------------------------
BIG="$TMP/big.py"
yes "x = 1" | head -n 200000 >"$BIG"
keys Escape ":tabonly" Enter
open_file backend/core/services.py
keys Escape ":vsplit $BIG" Enter
wait_lexpr "bigfile: a >1MB file in a split gets ft=bigfile and no LSP" \
  '(function() return (vim.bo.filetype == "bigfile" and #vim.lsp.get_clients({ bufnr = 0 }) == 0) and 1 or 0 end)()' 15
keys C-w p
wait_lexpr "bigfile: the python split beside it keeps pyright" \
  '(function() for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do if c.name == "pyright" then return 1 end end return 0 end)()' 15

# --- 7. git blame toggled while an edit turns into a hunk -------------------
keys Escape ":tabonly" Enter
open_file notes.md
wait_lexpr "gitsigns attaches to notes.md" 'vim.b.gitsigns_status_dict ~= nil and 1 or 0' 15
keys Space g b
sleep 1
keys G o "- a stress edit" Escape
wait_lexpr "combo: an edit while blame is on becomes a gitsigns hunk" \
  '#require("gitsigns").get_hunks(vim.fn.bufnr("notes.md")) > 0 and 1 or 0' 15
keys Escape "u"

# --- 8. text objects and substitute on a live LSP buffer -------------------
keys Escape ":tabonly" Enter
open_file backend/core/services.py
keys Escape ":6" Enter
keys d a f
wait_lexpr "textobject: daf deletes the whole summarize function" \
  '(function() local t = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") return (not t:find("def summarize")) and 1 or 0 end)()' 10
keys Escape ":silent! e!" Enter
open_file frontend/src/lib/shape.ts
keys Escape "/class" Enter
keys d a c
wait_lexpr "textobject: dac deletes the whole class in typescript" \
  '(function() local t = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") return (not t:find("class Square")) and 1 or 0 end)()' 10
keys Escape ":silent! e!" Enter
open_file backend/core/services.py
cursor_on double
keys Space S
wait_screen "combo: <leader>S prefills the substitute command" "%s/" 10
keys C-c

# --- 9. a debug session coexisting with a user split -----------------------
keys Escape ":silent! %bd!" Enter
open_file backend/demo.py
keys Escape ":vsplit backend/core/services.py" Enter
keys C-w h
wait_lexpr "focused the demo.py window of the user split" \
  'vim.fn.expand("%:t") == "demo.py" and #vim.api.nvim_tabpage_list_wins(0) == 2 and 1 or 0' 10
keys Escape ":3" Enter
keys Space b b
wait_lexpr "combo: breakpoint set while a user vsplit is open" \
  "(function() return $(bp_count) == 1 and 1 or 0 end)()" 10
keys Space d c
wait_screen "dap prompts for a launch configuration" "Launch file" 20
keys 1 Enter
wait_lexpr "combo: the session stops and dap-ui opens beside the user split" \
  "(function() return ($(session_stopped) == 1 and $(win_with_ft dapui_scopes) == 1) and 1 or 0 end)()" 30
keys Space d j
wait_lexpr "combo: step over advances the frame to the print line" \
  "(function() return $(frame_line 4) == 1 and 1 or 0 end)()" 15
keys Space d t
wait_lexpr "combo: terminate ends the session and closes dap-ui" \
  "(function() return ($(no_session) == 1 and $(win_with_ft dapui_scopes) == 0) and 1 or 0 end)()" 20
wait_lexpr "combo: the user services.py split survived the debug session" \
  '(function() for _, b in ipairs(vim.api.nvim_list_bufs()) do if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t") == "services.py" then return 1 end end return 0 end)()' 10

# --- 10. rapid buffer churn across languages, no client leak ---------------
keys Escape ":silent! %bd!" Enter
for f in backend/core/services.py frontend/src/lib/shape.ts service/main.go \
  langs/tool.lua langs/data.json langs/style.css notes.md langs/index.html; do
  keys Escape ":e $f" Enter
  sleep 0.4
done
wait_lexpr "churn: eight files across languages open at once" \
  '#vim.fn.getbufinfo({ buflisted = 1 }) >= 6 and 1 or 0' 10
keys Escape ":silent! %bd!" Enter
sleep 1
open_file backend/core/services.py
wait_lexpr "churn: pyright reattaches after %bd wipes every buffer" \
  '(function() for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do if c.name == "pyright" then return 1 end end return 0 end)()' 30
wait_lexpr "churn: no LSP client leak after the churn (<=12 live)" \
  '#vim.lsp.get_clients() <= 12 and 1 or 0' 10

deep_finish
