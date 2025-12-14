-- Enable Lua bytecode caching for faster startup (Neovim 0.11.0+)
-- Must be called before any requires
if vim.loader then
    vim.loader.enable()
end

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

-- Set leader key (Only set here, not in keymaps.lua)
vim.g.mapleader = " "

-- Load plugins with lazy.nvim
require("lazy").setup("plugins", {
  performance = {
    rtp = {
      -- Disable some default plugins we don't use
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
})

-- Load core options and keymaps
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.startup") -- Startup profiling

