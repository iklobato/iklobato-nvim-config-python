return {
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = { "TSInstall", "TSUpdate" },
    config = function()
      require("config.treesitter").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      enable = true,
      max_lines = 3,
      trim_scope = "outer",
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help",
          "dashboard",
          "lazy",
          "mason",
          "notify",
          "python",
        },
      },
    },
  },
  {
    "chrisgrieser/nvim-puppeteer",
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "python" },
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("config.telescope").setup()
    end,
  },
  {
    "saghen/blink.cmp",
    version = "*",
    config = function()
      require("config.blink").setup()
    end,
  },
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo", "Conform" },
    config = function()
      require("config.conform").setup()
    end,
  },
}
