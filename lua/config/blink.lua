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
  })
end

return M
