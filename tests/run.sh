#!/usr/bin/env bash
# Runs the feature test suite against this nvim config.
set -euo pipefail
cd "$(dirname "$0")/.."
# VeryLazy plugins need a moment to load before the checks run
nvim --headless "+lua vim.defer_fn(function() vim.cmd('luafile tests/features.lua') end, 3000)" 2>/dev/null
