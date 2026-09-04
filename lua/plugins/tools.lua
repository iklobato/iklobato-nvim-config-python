return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    init = function()
      -- default is npx @github/copilot-language-server, which dies when the
      -- npm registry is unreachable; always run the bundled server
      vim.g.copilot_npx = false
    end,
    config = function()
      -- copilot.vim only starts its client from its own VimEnter/FileType
      -- autocmds, both of which already fired for the buffer opened at startup
      -- by the time InsertEnter loads this plugin. Without this, the file you
      -- opened nvim with never gets suggestions until a second buffer's
      -- FileType fires. copilot#Init() starts the client; buffers attach on
      -- demand from there.
      vim.fn["copilot#Init"]()
    end,
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    -- `nvim .` opens a directory, so BufRead never fires and <leader>gb died
    -- with E492 until some file was read. The command has to load the plugin.
    cmd = { "GitBlameToggle", "GitBlameEnable", "GitBlameDisable" },
    -- init, not config: the plugin's own plugin/gitblame.lua calls setup(),
    -- which snapshots vim.g.gitblame_* the moment it is sourced. config runs
    -- after that, so the delay was already baked in at the 250ms default.
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
    -- no `config`: the plugin's own plugin/mkdp.vim already registers a
    -- BufEnter/FileType autocmd that defines :MarkdownPreview & friends for
    -- every mkdp_filetypes buffer; re-sourcing it here on every markdown
    -- FileType event just rebuilt the same augroup again for nothing.
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
        -- "postgres" is never a real filetype (dadbod-ui uses "sql" for it);
        -- "plsql" was missing. See lua/config/blink.lua for the blink source
        -- wiring this plugin needs to actually produce completions.
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql" },
      },
    },
    -- connections live in ~/.local/share/db_ui/connections.json;
    -- the *.dbout window sizing is in lua/autocmds/ui.lua
  },
}
