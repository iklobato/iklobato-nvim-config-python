#!/usr/bin/env bash
# Runs the feature test suite against this nvim config.
set -euo pipefail
cd "$(dirname "$0")/.."

# mason installs the linters and formatters this config declares; they are not
# on the interactive PATH
PATH="$PATH:${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"

# lint first: luacheck catches duplicate keys and shadowed locals that the
# runtime suite happily ignores, stylua catches drift from stylua.toml
if command -v luacheck >/dev/null 2>&1; then
  luacheck lua/ init.lua tests/features.lua
fi
if command -v stylua >/dev/null 2>&1; then
  stylua --check lua/ init.lua tests/features.lua
fi

# Wait for the VeryLazy plugins instead of guessing a delay.
# stderr is kept: a wedged suite must be visible, not silent. The timeout is
# the guard for a suite that errors before its own qa!.
timeout 180 nvim --headless "+lua vim.defer_fn(function()
  vim.wait(10000, function()
    return require('lazy.core.config').plugins['nvim-tree.lua']._.loaded ~= nil
  end, 50)
  vim.cmd('luafile tests/features.lua')
end, 100)"
