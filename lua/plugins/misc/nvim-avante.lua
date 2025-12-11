return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require('avante').setup({
      behaviour = {
        auto_set_keymaps = false,
      },
      mappings = {
        sidebar = {
          -- Tab keybinding removed to keep default Tab behavior
          -- Users can still use <leader>af to switch sidebar focus
        },
      },
    })
  end,
}



