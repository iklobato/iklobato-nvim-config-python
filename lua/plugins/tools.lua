return {
  {
    "Exafunction/windsurf.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "InsertEnter",
    config = function()
      require("codeium").setup({
        enable_cmp_source = false,
        virtual_text = { enabled = true },
      })
    end,
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    -- `nvim .` never fires BufRead, so <leader>gb needs cmd to load the plugin
    cmd = { "GitBlameToggle", "GitBlameEnable", "GitBlameDisable" },
    -- init, not config: plugin/gitblame.lua snapshots vim.g.gitblame_* when sourced
    init = function()
      vim.g.gitblame_enabled = true
      vim.g.gitblame_delay = 1000
      vim.g.gitblame_message_template = "<summary> • <date> • <author>"
      vim.g.gitblame_date_format = "%r"
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("config.session").setup()
    end,
  },
  {
    "szw/vim-maximizer",
    lazy = true,
    cmd = "MaximizerToggle",
  },
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {},
  },
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
      local app_dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim/app"
      vim.fn.system({ "npm", "install", "--prefix", app_dir })
    end,
    ft = { "markdown" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ""
      vim.g.mkdp_port = ""
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_page_title = "「${name}」"
      vim.g.mkdp_markdown_css = ""
      vim.g.mkdp_highlight_css = ""
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
    end,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = {
      {
        "tpope/vim-dadbod",
        lazy = true,
        cmd = { "DB" },
      },
      {
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql" },
      },
    },
  },
}
