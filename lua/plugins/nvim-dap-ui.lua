-- DAP UI Configuration
-- Official documentation: https://github.com/rcarriga/nvim-dap-ui
return {
  'rcarriga/nvim-dap-ui',
  event = 'VeryLazy',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-telescope/telescope-dap.nvim',
  },
  opts = function()
    return {
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
          terminate = "⏹"
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
        collapsed = "▶",
        current_frame = "▸",
        expanded = "▼"
      },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.50, wrap = false },
            { id = "stacks", size = 0.30, wrap = false  },
            { id = "watches", size = 0.10, wrap = false  },
            { id = "breakpoints", size = 0.10, wrap = false  }
          },
          size = 0.20, -- 30% of screen width
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5, wrap = false },
            { id = "console", size = 0.5, wrap = false }
          },
          size = 0.30, -- 30% of screen width
          position = "right",
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
    }
  end,
  config = function(_, opts)
    local dap = require('dap')
    local dapui = require('dapui')
    -- Setup DAP UI with provided options
    dapui.setup(opts)
    -- Automatically open DAP UI when debug session starts
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    -- Don't automatically close on termination (user can manually close)
    -- This allows inspection of state even after errors
    dap.listeners.before.event_terminated['dapui_config'] = function()
      -- Keep UI open - user can manually close with :DapUIToggle or <leader>dt
      -- dapui.close() -- Commented out to prevent auto-close
    end
    -- Don't automatically close on exit (especially for errors)
    -- This keeps the UI open so you can inspect what went wrong
    dap.listeners.before.event_exited['dapui_config'] = function()
      -- Keep UI open - user can manually close with :DapUIToggle or <leader>dt
      -- dapui.close() -- Commented out to prevent auto-close
    end
  end,
}
