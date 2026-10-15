#!/usr/bin/env bash
# Deep e2e, langs: every language server the config enables attaches to a file
# of its language, and the non-python formatters (prettier, stylua) format.
# Python and typescript go deeper in deep/lsp.sh; this area is the breadth.
# Run alone: ./tests/deep/langs.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup langs
deep_boot langs/tool.lua

attaches() { # file, server name
  open_file "$1"
  wait_lexpr "$2 attaches to ${1##*/}" "#vim.lsp.get_clients({ bufnr = 0, name = \"$2\" }) > 0 and 1 or 0" 60
}

line_is() { # line number, exact text
  echo "vim.fn.getline($1) == \"$2\" and 1 or 0"
}

# ---------------------------------------------------------------- language servers
attaches langs/tool.lua lua_ls
attaches langs/config.yaml yamlls
attaches langs/data.json jsonls
attaches langs/run.sh bashls
attaches langs/Dockerfile dockerls
attaches langs/main.tf terraformls
attaches langs/main.tf tflint
attaches langs/hello.c clangd
attaches langs/index.html html
attaches langs/style.css cssls
attaches langs/app.js ts_ls
attaches notes.md marksman
# eslint only attaches under a project with an eslint package and config
attaches frontend/src/legacy.js eslint
wait_lexpr "eslint reports the unused variable" \
  '(function() for _, d in ipairs(vim.diagnostic.get(0)) do if tostring(d.source):match("eslint") and d.message:match("unused") then return 1 end end return 0 end)()' 30

# ---------------------------------------------------------------- formatters
open_file langs/tool.lua
keys Space F
wait_lexpr "stylua formats a lua buffer" "$(line_is 7 'local spaced = { 1, 2 }')" 15
keys Escape ":e!" Enter
wait_lexpr "lua buffer reverted" "$(line_is 7 'local   spaced   =   {1,2}')"
goto_line 7
keys V Space F
# conform's end offset points at the last selected byte while stylua's
# --range-end excludes it; without the +1 in config/conform.lua a single
# selected line stayed unformatted
wait_lexpr "stylua formats a single selected line" "$(line_is 7 'local spaced = { 1, 2 }')" 15
keys Escape ":e!" Enter

open_file langs/data.json
keys Space F
wait_lexpr "prettier formats json" "$(line_is 1 '{ \"name\": \"deep\", \"count\": 2 }')" 20
keys Escape ":e!" Enter

open_file frontend/src/lib/shape.ts
keys G o "const  x={a:1}" Escape
keys Space F
wait_lexpr "prettier formats typescript" "$(line_is 'vim.fn.line("$")' 'const x = { a: 1 };')" 20
keys Escape ":e!" Enter

deep_finish
