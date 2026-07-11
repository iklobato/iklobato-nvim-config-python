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

-- Enable Lua bytecode caching
vim.loader.enable(true)

-- Disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

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

-- Load LSP configuration (deferred: mason is heavy, LSP isn't needed until a buffer opens)
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  once = true,
  callback = function()
    require("lsp")
    -- vim.lsp.enable() ran after this buffer's FileType event, so re-fire
    -- it for already-open buffers (nvim only does this after VimEnter)
    vim.schedule(function()
      pcall(vim.cmd.doautoall, "nvim.lsp.enable FileType")
    end)
  end,
})

-- Load autocmds
require("autocmds")
