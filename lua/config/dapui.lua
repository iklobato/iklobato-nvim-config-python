local M = {}

function M.setup()
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
  
  -- Make dap-repl buffer modifiable
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(data)
      if vim.bo[data.buf].filetype == "dap-repl" then
        vim.bo[data.buf].modifiable = true
      end
    end,
  })
end

return M