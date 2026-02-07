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

require("options")
require("keymaps")
require("plugins")
require("lsp")
require("autocmds")

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    vim.defer_fn(function()
      local directory = vim.fn.isdirectory(data.file) == 1
      local bufname = vim.fn.bufname()
      local no_file = bufname == "" or bufname == nil
      local tab_count = #vim.api.nvim_list_tabpages()
      local should_open = (directory or no_file) and tab_count <= 1
      if should_open then
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          api.tree.open()
        end
      end
    end, 500)
  end,
})
