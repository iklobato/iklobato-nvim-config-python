#!/usr/bin/env bash
# Deep e2e, completion: blink.cmp offers language server items, accepts one
# into the buffer, and completes commands on the command line.
# Run alone: ./tests/deep/completion.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup completion
deep_boot backend/core/services.py

list_has() { # label, source id
  echo '(function() for _, item in ipairs(require("blink.cmp.completion.list").items or {}) do if item.label:match("^'"$1"'") and item.source_id == "'"$2"'" then return 1 end end return 0 end)()'
}

menu_has() { # label, source id: listed and on screen
  echo "(require(\"blink.cmp\").is_menu_visible() and $(list_has "$1" "$2") == 1) and 1 or 0"
}

wait_lexpr "pyright attaches" \
  '#vim.lsp.get_clients({ bufnr = 0, name = "pyright" }) > 0 and 1 or 0' 40

# ---------------------------------------------------------------- insert mode
keys G o "    print(summ"
wait_lexpr "the menu offers summarize from the language server" "$(menu_has summarize lsp)" 20
keys C-y
wait_lexpr "C-y accepts it into the line" 'vim.fn.getline("."):match("print%(summarize") and 1 or 0' 10
keys Escape
keys Escape ":e!" Enter
wait_lexpr "buffer reverted" 'vim.bo.modified == false and 1 or 0'

# ---------------------------------------------------------------- command line
keys ":Telesc"
# blink's cmdline menu stays hidden until Tab (its default), but the items are
# already computed from the cmdline source
wait_lexpr "blink lists :Telescope from the cmdline source" "$(list_has Telescope cmdline)" 15
keys Tab
wait_lexpr "Tab completes the command" 'vim.fn.getcmdline():match("^Telescope") and 1 or 0' 10
keys C-c

deep_finish
