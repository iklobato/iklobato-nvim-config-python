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
  -- Ignore plugin-shipped lazy.lua specs. kulala.nvim ships one adding
  -- SessionLoadPost + VimLeavePre triggers, which pulled it in on every quit and
  -- on every session restore instead of only on .http files. It is the only
  -- installed plugin with such a spec, and rocks/packspec are already off.
  pkg = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        -- the runtime file is netrwPlugin.vim; "netrw" matched nothing. netrw is
        -- already disabled via vim.g.loaded_netrw* in init.lua, so this is belt
        -- and braces. ("rrhelper" was dropped: no such runtime file exists.)
        "netrwPlugin",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
      },
    },
  },
})
