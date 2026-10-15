#!/usr/bin/env bash
# Feature suite runner (lint + tests/features.lua): ./tests/run.sh
set -euo pipefail
cd "$(dirname "$0")/.."

PATH="$PATH:${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"

if command -v luacheck >/dev/null 2>&1; then
  luacheck lua/ init.lua tests/features.lua
fi
if command -v stylua >/dev/null 2>&1; then
  stylua --check lua/ init.lua tests/features.lua
fi

# not VeryLazy (headless never fires UIEnter): session.lua loads nvim-tree after VimEnter
timeout 180 nvim --headless "+lua vim.defer_fn(function()
  local ready = vim.wait(10000, function()
    return require('lazy.core.config').plugins['nvim-tree.lua']._.loaded ~= nil
  end, 50)
  if not ready then
    io.stderr:write('nvim-tree never loaded after 10s, aborting before the suite runs on a broken startup\n')
    vim.cmd('cq 1')
  end
  vim.cmd('luafile tests/features.lua')
end, 100)"
