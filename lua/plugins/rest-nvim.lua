return {
  {
    "rest-nvim/rest.nvim",
    ft = { "http", "rest" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- Ensure nvim-treesitter is loaded and http parser is available
      require("nvim-treesitter")

      -- Configure rest.nvim using vim.g (new API)
      vim.g.rest_nvim = {
        response = {
          hooks = {
            decode_url = true,
            format = false,
          },
        },
        ui = {
          winbar = true,
          keybinds = {
            prev = "H",
            next = "L",
          },
        },
        clients = {
          curl = {
            statistics = {
              { id = "time_total", title = "Total time", winbar = "time" },
              { id = "size_download", title = "Download size", winbar = "size" },
            },
          },
        },
      }
    end,
  }
}