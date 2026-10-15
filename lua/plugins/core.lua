return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- main: master crashes the highlighter on nvim 0.12; main can't lazy-load
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
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
          "lazy",
          "mason",
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    -- must match nvim-treesitter's branch
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("config.treesitter").setup_textobjects()
    end,
  },
  {
    "chrisgrieser/nvim-puppeteer",
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "python" },
    -- `init`, not `config`: the plugin reads this var when its plugin file is sourced
    init = function()
      vim.g.puppeteer_disabled_filetypes = {
        "lua",
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "astro",
        "svelte",
      }
    end,
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
    event = { "InsertEnter", "CmdlineEnter", "BufReadPost", "BufNewFile" },
    config = function()
      require("config.blink").setup()
    end,
  },
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    config = function()
      require("config.conform").setup()
    end,
  },
}
