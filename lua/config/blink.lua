local M = {}

function M.setup()
  require("blink.cmp").setup({
    keymap = {
      preset = "default",
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      -- iTerm uses JetBrainsMono Nerd Font Mono: icons are one cell wide
      nerd_font_variant = "mono",
    },
    fuzzy = {
      implementation = "prefer_rust",
    },
    completion = {
      list = {
        max_items = 15,
      },
      menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
    },
    sources = {
      -- dadbod-completion only self-registers with nvim-cmp; blink needs this wiring
      per_filetype = {
        sql = { "dadbod", inherit_defaults = true },
        mysql = { "dadbod", inherit_defaults = true },
        plsql = { "dadbod", inherit_defaults = true },
      },
      providers = {
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
      },
    },
  })
end

return M
