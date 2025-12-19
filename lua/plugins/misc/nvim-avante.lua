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
  providers = {
    bedrock = {
      model = "arn:aws:bedrock:us-west-2:471112984857:application-inference-profile/8svvvjlk6tpp",
      aws_profile = "sanctum",
      aws_region = "us-west-2",
    },
  },
  config = function()

    require('avante').setup({
      behaviour = {
        auto_set_keymaps = false,
        support_paste_from_clipboard = true,
      },
      mappings = {
        sidebar = {
          -- Tab keybinding removed to keep default Tab behavior
          -- Users can still use <leader>af to switch sidebar focus
        },
        ask = {
          -- Disable Tab in ask mode to prevent conflicts
        },
        edit = {
          -- Disable Tab in edit mode to prevent conflicts
        },
      },
      hints = {
        enabled = false, -- Disable hints to reduce potential conflicts
      },
    })
  end,
}








