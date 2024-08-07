-- Setup lazy.nvim
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

-- Set leader key
vim.g.mapleader = " "

-- Load plugins with lazy.nvim
require("lazy").setup("plugins", {
   change_detection = {
    enabled = true,
    notify = false,
  },
})

-- Load core options and keymaps
require("core.options")
require("core.keymaps")

