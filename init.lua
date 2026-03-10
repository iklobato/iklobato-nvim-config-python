-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key
vim.g.mapleader = " "

-- Use rest.nvim rocks (mimetypes, xml2lua, nio, fidget) installed by lazy + hererocks.
local rocks_dir = vim.fn.stdpath("data") .. "/lazy-rocks/rest.nvim/share/lua/5.1"
if vim.loop.fs_stat(rocks_dir) then
  package.path = package.path .. ";" .. rocks_dir .. "/?.lua;" .. rocks_dir .. "/?/init.lua"
end

-- Disable netrw (use nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Load core configuration
require("core").setup()

-- Load keymaps
require("keymaps")

-- Load plugins
require("plugins")

-- Load LSP configuration
require("lsp")

-- Load autocmds
require("autocmds")
