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
      view = { width = 50 },
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
        ensure_installed = { "lua", "python" },
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
              { id = "scopes", size = 0.50, wrap = false },
              { id = "stacks", size = 0.30, wrap = false },
              { id = "watches", size = 0.10, wrap = false },
              { id = "breakpoints", size = 0.10, wrap = false },
            },
            size = 0.20,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5, wrap = false },
              { id = "console", size = 0.5, wrap = false },
            },
            size = 0.30,
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
}

require("lazy").setup(plugins)
