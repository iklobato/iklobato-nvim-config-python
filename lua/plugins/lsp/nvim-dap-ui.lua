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
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5, wrap = false },
            { id = "console", size = 0.5, wrap = false }
          },
          size = 40,
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
    dapui.setup(opts)

    -- Simple Python path detection
    local function get_python_path()
      local cwd = vim.fn.getcwd()
      
      -- Check for pipenv environment
      if vim.fn.executable('pipenv') == 1 then
        local handle = io.popen('cd ' .. cwd .. ' && pipenv --venv 2>/dev/null')
        if handle then
          local pipenv_venv = handle:read("*a"):gsub("%s+$", "")
          handle:close()
          if pipenv_venv ~= '' then
            local pipenv_python = pipenv_venv .. '/bin/python'
            if vim.fn.executable(pipenv_python) == 1 then
              return pipenv_python
            end
          end
        end
      end
      
      -- Check for poetry environment
      if vim.fn.executable('poetry') == 1 then
        local handle = io.popen('cd ' .. cwd .. ' && poetry env info -p 2>/dev/null')
        if handle then
          local poetry_venv = handle:read("*a"):gsub("%s+$", "")
          handle:close()
          if poetry_venv ~= '' then
            local poetry_python = poetry_venv .. '/bin/python'
            if vim.fn.executable(poetry_python) == 1 then
              return poetry_python
            end
          end
        end
      end
      
      -- Check for local virtual environments
      local patterns = { '.venv/bin/python', 'venv/bin/python' }
      for _, pattern in ipairs(patterns) do
        local path = cwd .. '/' .. pattern
        if vim.fn.executable(path) == 1 then
          return path
        end
      end
      
      -- Check for activated virtual environment
      if vim.fn.exists('$VIRTUAL_ENV') == 1 then
        local venv_path = vim.fn.expand('$VIRTUAL_ENV/bin/python')
        if vim.fn.executable(venv_path) == 1 then
          return venv_path
        end
      end
      
      return 'python'
    end

    -- Python adapter configuration
    dap.adapters.python = {
      type = 'executable',
      command = get_python_path(),
      args = { '-m', 'debugpy.adapter' }
    }

    -- Build common env for Python (reuse pyright PYTHONPATH if present)
    local function build_python_env()
      local env = {}
      if _G._pyright_pythonpath and type(_G._pyright_pythonpath) == 'string' then
        env.PYTHONPATH = _G._pyright_pythonpath
      end
      -- Return nil instead of empty table to avoid serialization issues
      if next(env) == nil then
        return vim.empty_dict()
      end
      return env
    end

    -- Basic Python configurations
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Debug Current File',
        program = '${file}',
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Debug Python Module',
        module = '${input:moduleName}',
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Debug with Arguments',
        program = '${file}',
        args = {}, -- Will be set via input when launched
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
      },

      -- Django-specific configurations
      {
        type = 'python',
        request = 'launch',
        name = 'Django: runserver',
        program = '${workspaceFolder}/manage.py',
        args = { 'runserver', '0.0.0.0:8000' },
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
        django = true,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Django: runserver (custom addr)',
        program = '${workspaceFolder}/manage.py',
        args = { 'runserver', '${input:djangoRunserverAddress}' },
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
        django = true,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Django: test (manual args)',
        program = '${workspaceFolder}/manage.py',
        args = function()
          -- Prompt once per run and split on whitespace
          local input = vim.fn.input('manage.py test args: ')
          if input == nil or input == '' then
            return { 'test' }
          end
          local parts = vim.split(input, '%s+')
          local args = { 'test' }
          for _, p in ipairs(parts) do
            if p ~= '' then
              table.insert(args, p)
            end
          end
          return args
        end,
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
        django = true,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Django: shell',
        program = '${workspaceFolder}/manage.py',
        args = { 'shell' },
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
        django = true,
      },

      -- Custom command configurations
      {
        type = 'python',
        request = 'launch',
        name = 'Uvicorn: api.asgi:application (0.0.0.0:8000)',
        module = 'uvicorn',
        args = {
          'api.asgi:application',
          '--host', '0.0.0.0',
          '--port', '8000',
          '--reload'
        },
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Custom: Run Command',
        module = function()
          local input = vim.fn.input('Module name (e.g., uvicorn): ')
          return input ~= '' and input or nil
        end,
        args = function()
          local input = vim.fn.input('Module arguments (e.g., api.asgi:application --host 0.0.0.0 --port 8000 --reload): ')
          if input == nil or input == '' then
            return {}
          end
          local args = {}
          for arg in string.gmatch(input, '%S+') do
            table.insert(args, arg)
          end
          return args
        end,
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Custom: Uvicorn/ASGI Server',
        module = 'uvicorn',
        args = function()
          local app_path = vim.fn.input('ASGI app path (e.g., api.asgi:application): ', '', 'file')
          local host = vim.fn.input('Host (default 0.0.0.0): ')
          local port = vim.fn.input('Port (default 8000): ')
          
          if app_path == '' then
            app_path = 'main:app'
          end
          host = host ~= '' and host or '0.0.0.0'
          port = port ~= '' and port or '8000'
          
          return {
            app_path,
            '--host', host,
            '--port', port,
            '--reload'
          }
        end,
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Custom: Free-form Command',
        program = function()
          local input = vim.fn.input('Script path (e.g., ${workspaceFolder}/manage.py): ')
          return input ~= '' and vim.fn.expand(input) or '${file}'
        end,
        args = function()
          local input = vim.fn.input('Arguments (space-separated): ')
          if input == nil or input == '' then
            return {}
          end
          local args = {}
          for arg in string.gmatch(input, '%S+') do
            table.insert(args, arg)
          end
          return args
        end,
        console = 'integratedTerminal',
        justMyCode = false,
        env = build_python_env(),
      },
    }

    -- DAP input prompts used by some configurations
    dap.defaults.fallback.inputs = dap.defaults.fallback.inputs or {}
    dap.defaults.fallback.inputs.djangoRunserverAddress = {
      description = 'Django runserver address (host:port)',
      default = '127.0.0.1:8000',
    }

    -- DAP UI event listeners
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Handle debugpy-specific events to suppress warnings
    dap.listeners.after.event_debugpySockets["dapui_config"] = function(session, body)
      -- debugpy socket information - can be used for remote debugging if needed
    end
    
    dap.listeners.after.event_debugpyWaitingForServer["dapui_config"] = function(session, body)
      -- debugpy waiting for server connection - informational only
    end

    -- Update Python path on directory change
    vim.api.nvim_create_autocmd({"DirChanged"}, {
      callback = function()
        dap.adapters.python.command = get_python_path()
      end,
    })
  end
}
