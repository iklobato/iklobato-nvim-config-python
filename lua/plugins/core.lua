return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- pin master explicitly: upstream's default branch is now `main` (a rewrite
    -- without nvim-treesitter.configs). Without this, a fresh clone or a :Lazy
    -- update tracks origin/HEAD=main and config.treesitter's setup errors. The
    -- textobjects spec below is pinned to master for the same reason.
    branch = "master",
    event = { "BufReadPre", "BufNewFile" },
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
          "lazy",
          "mason",
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    -- must track master: the main branch needs nvim-treesitter's main branch,
    -- and this config pins nvim-treesitter to master
    branch = "master",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  {
    "chrisgrieser/nvim-puppeteer",
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "python" },
    -- the plugin's own autocmds cover js/ts/lua/vue/astro/svelte too (rewriting
    -- strings on InsertLeave), read at ITS OWN plugin-file source time, so this
    -- has to be `init`, not `config`. Without it, whether a .ts/.lua buffer gets
    -- auto-rewritten depends on whether a .py file happened to load earlier in
    -- the session, not on this ft gate.
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
    -- BufReadPost/BufNewFile are here because lua/lsp/init.lua requires blink so
    -- its plugin file registers vim.lsp.config('*').capabilities before any
    -- server starts. It really does load on the first buffer, so say so.
    event = { "InsertEnter", "CmdlineEnter", "BufReadPost", "BufNewFile" },
    config = function()
      require("config.blink").setup()
    end,
  },
  {
    "stevearc/conform.nvim",
    -- conform only defines :ConformInfo; a stub :Conform would load the plugin
    -- and then fail with "Not an editor command"
    cmd = { "ConformInfo" },
    config = function()
      require("config.conform").setup()
    end,
  },
}
