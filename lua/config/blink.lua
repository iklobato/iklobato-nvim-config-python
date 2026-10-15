local M = {}

function M.setup()
  require("blink.cmp").setup({
    keymap = {
      preset = "default",
    },
    appearance = {
      use_nvim_cmp_as_default = true,
    },
    fuzzy = {
      implementation = "prefer_rust",
    },
    completion = {
      list = {
        max_items = 15,
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
