#!/usr/bin/env bash
# Deep e2e, search: telescope pickers.
# Run alone: ./tests/deep/search.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup search
deep_boot backend/core/services.py

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

deep_finish
