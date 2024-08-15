return {
  'rcarriga/nvim-dap-ui',
  event = 'VeryLazy',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-telescope/telescope-dap.nvim',
  },
  opts = {
    controls = {
      element = "repl",
      enabled = false,
      icons = {
        disconnect = "",
        pause = "",
        play = "",
        run_last = "",
        step_back = "",
        step_into = "",
        step_out = "",
        step_over = "",
        terminate = ""
      }
    },
    element_mappings = {},
    expand_lines = true,
    floating = {
      border = "single",
      mappings = {
        close = { "q", "<Esc>" }
      }
    },
    force_buffers = true,
    icons = {
      collapsed = "",
      current_frame = "",
      expanded = ""
    },
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.50 },
          { id = "stacks", size = 0.30 },
          { id = "watches", size = 0.10 },
          { id = "breakpoints", size = 0.10 }
        },
        size = 40,
        position = "left",
      },
      {
        elements = { "repl", "console" },
        size = 10,
        position = "bottom",
      }
    },
    mappings = {
      edit = "e",
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      repl = "r",
      toggle = "t"
    },
    render = {
      indent = 1,
      max_value_lines = 100
    }
  },
  config = function(_, opts)
    local dap = require('dap')
    local dapui = require('dapui')
    dapui.setup(opts)

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      -- Uncomment to close DAP UI automatically
      -- dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      -- Uncomment to close DAP UI automatically
      -- dapui.close()
    end
    
    local function get_env_vars()
      local variables = {}
      for k, v in pairs(vim.fn.environ()) do
        variables[k] = v
      end
      return variables
    end
    
    -- Python DAP Configuration
    local pythonPath = function()
      local cwd = vim.loop.cwd()
      if vim.fn.executable(cwd .. '.venv/bin/python') == 1 then
        return cwd .. '.venv/bin/python'
      else
        return 'python'
      end
    end

    dap.adapters.python = {
      type = 'executable',
      command = pythonPath(),
      args = {'-m', 'debugpy.adapter'}
    }

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = "Launch file",
        program = "${file}",
        pythonPath = pythonPath,
        env = get_env_vars(),
      },
      {
        type = 'python',
        request = 'launch',
        name = 'DAP Django',
        program = vim.loop.cwd() .. '/manage.py',
        args = {'runserver', '--noreload'},
        justMyCode = true,
        django = true,
        console = "integratedTerminal",
        env = get_env_vars(),

      },
      {
        type = 'python',
        request = 'attach',
        name = 'Attach remote',
        env = get_env_vars(),
        connect = function()
          return { host = '127.0.0.1', port = 5678 }
        end
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file with arguments',
        program = '${file}',
        args = function()
          local args_string = vim.fn.input('Arguments: ')
          return vim.split(args_string, " +")
        end,
        console = "integratedTerminal",
        env = get_env_vars(),
        pythonPath = pythonPath
      }
    }

    vim.api.nvim_create_autocmd({"DirChanged"}, {
      callback = function() set_python_dap() end,
    })
  end
}

