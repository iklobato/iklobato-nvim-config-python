local core_plugins = require("plugins.core")
local ui_plugins = require("plugins.ui")
local lsp_plugins = require("plugins.lsp")
local dap_plugins = require("plugins.dap")
local tools_plugins = require("plugins.tools")

local plugins = {}
vim.list_extend(plugins, core_plugins)
vim.list_extend(plugins, ui_plugins)
vim.list_extend(plugins, lsp_plugins)
vim.list_extend(plugins, dap_plugins)
vim.list_extend(plugins, tools_plugins)

require("lazy").setup(plugins, {
  -- No plugin needs luarocks; leaving it on lets a broken rockspec abort startup.
  rocks = { enabled = false },
  -- kulala's shipped lazy.lua spec would load it on every quit and session restore
  pkg = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        -- the runtime file is netrwPlugin.vim; "netrw" matches nothing
        "netrwPlugin",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
      },
    },
  },
})
