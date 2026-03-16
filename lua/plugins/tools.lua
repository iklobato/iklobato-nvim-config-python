return {
  {
    "github/copilot.vim",
    cmd = "Copilot",
    config = function()
      vim.g.copilot_tab_fallback = function()
        local ok, blink = pcall(require, "blink.cmp")
        if ok and blink and blink.status then
          return vim.api.nvim_replace_termcodes("<C-N>", true, false, true)
        end
        return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
      end
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup({
        auto_save_enabled = true,
        auto_restore_enabled = true,
      })
    end,
  },
  {
    "szw/vim-maximizer",
    lazy = true,
    cmd = "MaximizerToggle",
  },
  {
    "rest-nvim/rest.nvim",
    dependencies = {
      "nvim-neotest/nvim-nio",
      {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "http")
        end,
      },
    },
    ft = { "http", "rest" },
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
      vim.g.mkdp_port = "8080"
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
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          local plugin_path = vim.fn.stdpath("data")
            .. "/lazy/markdown-preview.nvim/plugin/mkdp.vim"
          if vim.fn.filereadable(plugin_path) == 1 then
            vim.cmd("source " .. plugin_path)
          end
        end,
      })
    end,
  },
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI", "DBUIToggle" },
    dependencies = {
      {
        "kristijanhusak/vim-dadbod-ui",
        cmd = { "DBUI", "DBUIToggle" },
      },
      {
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "postgres" },
      },
    },
    config = function()
      vim.g.dbs = {
        default_postgres = "postgresql://postgres:postgres@localhost:5432/postgres",
      }

      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.dbout",
        callback = function()
          if vim.bo.filetype == "dbout" then
            local bufnr = vim.api.nvim_get_current_buf()
            vim.defer_fn(function()
              local winid = vim.fn.bufwinid(bufnr)
              if winid and winid > 0 then
                local total_lines = vim.o.lines - 2
                local height = math.max(10, math.floor(total_lines * 0.75))
                pcall(vim.api.nvim_win_set_height, winid, height)
              end
            end, 100)
          end
        end,
      })
    end,
  },
}