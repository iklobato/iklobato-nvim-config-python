#!/usr/bin/env bash
# Deep e2e, completion: blink.cmp lsp items in insert mode and cmdline completion.
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup completion
deep_boot backend/core/services.py

list_has() {
  echo '(function() for _, item in ipairs(require("blink.cmp.completion.list").items or {}) do if item.label:match("^'"$1"'") and item.source_id == "'"$2"'" then return 1 end end return 0 end)()'
}

menu_has() {
  echo "(require(\"blink.cmp\").is_menu_visible() and $(list_has "$1" "$2") == 1) and 1 or 0"
}

wait_lexpr "pyright attaches" \
  '#vim.lsp.get_clients({ bufnr = 0, name = "pyright" }) > 0 and 1 or 0' 40

keys G o "    print(summ"
wait_lexpr "the menu offers summarize from the language server" "$(menu_has summarize lsp)" 20
keys C-y
wait_lexpr "C-y accepts it into the line" 'vim.fn.getline("."):match("print%(summarize") and 1 or 0' 10
keys Escape
keys Escape ":e!" Enter
wait_lexpr "buffer reverted" 'vim.bo.modified == false and 1 or 0'

keys ":Telesc"
# cmdline menu stays hidden until Tab, so check the item list, not menu_has
wait_lexpr "blink lists :Telescope from the cmdline source" "$(list_has Telescope cmdline)" 15
keys Tab
wait_lexpr "Tab completes the command" 'vim.fn.getcmdline():match("^Telescope") and 1 or 0' 10
keys C-c

deep_finish
