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
          "bigfile",
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
      -- native C sorter: faster than the lua one on big repos, no boot cost
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("config.telescope").setup()
    end,
  },
  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "nvim-mini/mini.surround",
    keys = { "ys", "ds", "cs", { "S", mode = "x" } },
    -- vim-surround's keys: ys{motion}{char}, ds{char}, cs{old}{new}, visual S{char}
    opts = {
      mappings = {
        add = "ys",
        delete = "ds",
        replace = "cs",
        find = "",
        find_left = "",
        highlight = "",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
      search_method = "cover_or_next",
    },
    config = function(_, opts)
      require("mini.surround").setup(opts)
      -- a visual "ys" would make every visual y wait out timeoutlen before yanking
      vim.keymap.del("x", "ys")
      vim.keymap.set(
        "x",
        "S",
        [[:<C-u>lua MiniSurround.add("visual")<CR>]],
        { silent = true, desc = "Surround selection" }
      )
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TodoTelescope" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    cmd = "Neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        -- python path left to the adapter: it follows VIRTUAL_ENV, then a .venv in the root
        adapters = { require("neotest-python")({ runner = "pytest" }) },
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "*",
    -- lsp/init's require("blink.cmp") loads it on the first buffer anyway; these only cover
    -- a scratch buffer with no LSP. Dropped BufReadPost/BufNewFile as redundant with that.
    event = { "InsertEnter", "CmdlineEnter" },
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
