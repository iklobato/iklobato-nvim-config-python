local plugins = {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        background = { dark = "wave" },
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = {
        width = math.max(30, math.floor(vim.o.columns * 0.2)),
      },
      actions = { open_file = { window_picker = { enable = false } } },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-dap.nvim",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      pcall(telescope.load_extension, "dap")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        ensure_installed = { "lua", "python", "c", "http", "html", "javascript", "tsx", "css" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "williamboman/mason.nvim",
  },
  {
    "williamboman/mason-lspconfig.nvim",
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "python" },
      })
    end,
  },
  {
    "github/copilot.vim",
    event = "VimEnter",
    config = function()
      vim.g.copilot_no_tab_map = true
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            local filetype = vim.bo.filetype
            if vim.fn.exists("*copilot#Accept") == 1
              and filetype ~= "Avante"
              and filetype ~= "AvanteInput"
              and filetype ~= "http"
            then
              local ok, copilot_suggestion = pcall(vim.fn["copilot#Accept"])
              if ok
                and copilot_suggestion
                and copilot_suggestion ~= ""
                and type(copilot_suggestion) == "string"
              then
                vim.api.nvim_feedkeys(copilot_suggestion, "i", false)
                return
              end
            end
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.set_log_level("ERROR")

      local function debugpy_adapter()
        local ok, mason_registry = pcall(require, "mason-registry")
        if not ok then
          return nil
        end
        if not mason_registry.has_package("debugpy") then
          return nil
        end
        if not mason_registry.is_installed("debugpy") then
          return nil
        end
        local path = require("mason-core.installer.InstallLocation")
          .global()
          :package("debugpy")
        if vim.fn.has("win32") == 1 then
          return path .. "\\venv\\Scripts\\python.exe"
        end
        return path .. "/venv/bin/python"
      end

      local function python_path()
        if vim.env.VIRTUAL_ENV then
          return vim.env.VIRTUAL_ENV .. "/bin/python"
        end
        return "python3"
      end

      dap.adapters.python = function(cb, config)
        local adapter_python = debugpy_adapter()
        if config.request == "attach" then
          cb({
            type = "server",
            port = config.port or 5678,
            host = config.host or "127.0.0.1",
          })
        else
          cb({
            type = "executable",
            command = adapter_python or python_path(),
            args = { "-m", "debugpy.adapter" },
          })
        end
      end

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = python_path,
        },
        {
          type = "python",
          request = "launch",
          name = "Django runserver",
          program = "${workspaceFolder}/manage.py",
          args = { "runserver", "--noreload" },
          django = true,
          pythonPath = python_path,
        },
        {
          type = "python",
          request = "launch",
          name = "Pytest file",
          module = "pytest",
          args = { "${file}" },
          pythonPath = python_path,
        },
      }
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dapui = require("dapui")
      local cols = vim.o.columns
      local left_size = math.max(0.12, math.min(0.28, 0.10 + cols * 0.0004))
      local right_size = math.max(0.25, math.min(0.45, 0.22 + cols * 0.0005))
      dapui.setup({
        controls = {
          element = "repl",
          enabled = false,
          icons = {
            disconnect = "⏹",
            pause = "⏸",
            play = "▶",
            run_last = "⏭",
            step_back = "⏮",
            step_into = "↓",
            step_out = "↑",
            step_over = "→",
            terminate = "⏹",
          },
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        force_buffers = true,
        icons = {
          collapsed = "▶",
          current_frame = "▸",
          expanded = "▼",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.5, wrap = false },
              { id = "watches", size = 0.25, wrap = false },
              { id = "breakpoints", size = 0.25, wrap = false },
            },
            size = left_size,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5, wrap = false },
              { id = "console", size = 0.5, wrap = false },
            },
            size = right_size,
            position = "right",
          },
        },
        mappings = {
          edit = "e",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t",
        },
        render = {
          indent = 1,
          max_value_lines = 100,
        },
      })
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(data)
          if vim.bo[data.buf].filetype == "dap-repl" then
            vim.bo[data.buf].modifiable = true
          end
        end,
      })
    end,
  },
  {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    cmd = { "AvanteAsk", "AvanteToggle", "AvanteChat", "AvanteEdit" },
    opts = {
      instructions_file = "avante.md",
      behaviour = { auto_set_keymaps = false },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
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
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = false,
      date_format = "%m/%d/%y %H:%M:%S",
    },
  },
  {
    "szw/vim-maximizer",
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
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      -- Database connections
      vim.g.dbs = {
        default_postgres = "postgresql://postgres:postgres@localhost:5432/postgres",
      }
    end,
  },
}

require("lazy").setup(plugins)
