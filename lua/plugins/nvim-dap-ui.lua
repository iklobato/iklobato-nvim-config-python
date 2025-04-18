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
      collapsed = "",
      current_frame = "",
      expanded = ""
    },
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.50, wrap = false },
          { id = "stacks", size = 0.30, wrap = false  },
          { id = "watches", size = 0.10, wrap = false  },
          { id = "breakpoints", size = 0.10, wrap = false  }
        },
        size = math.floor(vim.o.columns * 0.25),
        position = "left",
      },
      {
        elements = {
          { id = "repl", size = 0.5, wrap = false },
          { id = "console", size = 0.5, wrap = false }
        },
        size = math.floor(vim.o.columns * 0.4),
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
  },
  config = function(_, opts)
    local dap = require('dap')
    local dapui = require('dapui')
    dapui.setup(opts)

    -- Function to find Django settings module
    local function find_django_settings()
      local current_dir = vim.fn.getcwd()
      local manage_py = vim.fn.findfile('manage.py', current_dir .. ';')
      
      if manage_py ~= '' then
        local manage_content = vim.fn.readfile(manage_py)
        for _, line in ipairs(manage_content) do
          local settings_module = line:match('DJANGO_SETTINGS_MODULE["\'], ["\'](.-)["\']')
          if settings_module then
            return settings_module
          end
        end
        
        local project_dir = vim.fn.fnamemodify(manage_py, ':h')
        local possible_settings = vim.fn.globpath(project_dir, '*/settings.py', 0, 1)
        if #possible_settings > 0 then
          local settings_path = possible_settings[1]
          local module_name = vim.fn.fnamemodify(settings_path, ':h:t')
          return module_name .. '.settings'
        end
      end
      return nil
    end

    -- Function to detect virtual environment
    local function get_python_path()
      local patterns = {
        '.venv/bin/python',
        'venv/bin/python',
        'env/bin/python',
        '.env/bin/python',
        'virtualenv/bin/python',
      }
      
      -- Check for poetry environment
      local poetry_env = vim.fn.systemlist('poetry env info -p 2>/dev/null')
      if #poetry_env > 0 then
        local poetry_path = poetry_env[1] .. '/bin/python'
        if vim.fn.executable(poetry_path) == 1 then
          return poetry_path
        end
      end
      
      -- Check for activated virtual environment
      if vim.fn.exists('$VIRTUAL_ENV') == 1 then
        local venv_path = vim.fn.expand('$VIRTUAL_ENV/bin/python')
        if vim.fn.executable(venv_path) == 1 then
          return venv_path
        end
      end
      
      -- Check common virtual environment patterns
      local cwd = vim.fn.getcwd()
      for _, pattern in ipairs(patterns) do
        local path = cwd .. '/' .. pattern
        if vim.fn.executable(path) == 1 then
          return path
        end
      end
      
      return 'python'
    end

    -- Function to get Django environment variables
    local function get_django_env()
      local env = {}
      for k, v in pairs(vim.fn.environ()) do
        env[k] = v
      end
      
      env.PYTHONPATH = vim.fn.getcwd()
      local settings_module = find_django_settings()
      if settings_module then
        env.DJANGO_SETTINGS_MODULE = settings_module
      end
      env.PYTHONUNBUFFERED = '1'
      env.DJANGO_DEBUG = '1'
      
      return env
    end

    -- Python adapter configuration
    dap.adapters.python = {
      type = 'executable',
      command = get_python_path(),
      args = { '-m', 'debugpy.adapter' }
    }

    -- Initialize last command storage
local last_django_command = nil

    -- Django configurations
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = '⏮️  DJANGO: Rerun Last Command',
        program = '${workspaceFolder}/manage.py',
        args = function()
            if last_django_command then
                vim.notify("Rerunning command: " .. table.concat(last_django_command, " "), vim.log.levels.INFO)
                return last_django_command
            else
                vim.notify("No previous command found. Please run a Django command first.", vim.log.levels.WARN)
                return {'help'}
            end
        end,
        pythonPath = get_python_path,
        django = true,
        justMyCode = false,
        console = 'integratedTerminal',
        env = get_django_env,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🐍 PYTHON: Current File',
        program = '${file}',
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🌐 DJANGO: Run Server',
        program = '${workspaceFolder}/manage.py',
        args = { 'runserver', '--noreload' },
        pythonPath = get_python_path,
        django = true,
        justMyCode = false,
        console = 'integratedTerminal',
        env = get_django_env,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🧪 DJANGO: Run Tests',
        program = '${workspaceFolder}/manage.py',
        args = function()
          local test_path = vim.fn.input('Test path (empty for all): ')
          local args = {'test', '--keepdb'}
          if test_path ~= '' then
            for arg in test_path:gmatch("%S+") do
              table.insert(args, arg)
            end
          end
          last_django_command = args
          vim.notify("Test command stored: test " .. test_path, vim.log.levels.INFO)
          return args
        end,
        pythonPath = get_python_path,
        django = true,
        justMyCode = false,
        console = 'integratedTerminal',
        env = get_django_env,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🔮 DJANGO: Shell Plus',
        program = '${workspaceFolder}/manage.py',
        args = {'shell_plus', '--ipython'},
        pythonPath = get_python_path,
        django = true,
        justMyCode = false,
        console = 'integratedTerminal',
        env = get_django_env,
      },
      {
        type = 'python',
        request = 'launch',
        name = '⚙️  DJANGO: Custom Command',
        program = '${workspaceFolder}/manage.py',
        args = function()
          local cmd = vim.fn.input('Management command: ')
          if cmd == "" then
            vim.notify("Command cancelled", vim.log.levels.WARN)
            return {'help'}
          end
          
          local args = {}
          for arg in cmd:gmatch("%S+") do
            table.insert(args, arg)
          end
          
          last_django_command = args
          vim.notify("Command stored: " .. cmd, vim.log.levels.INFO)
          return args
        end,
        pythonPath = get_python_path,
        django = true,
        justMyCode = false,
        console = 'integratedTerminal',
        env = get_django_env,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🎯 PYTEST: Run All Tests',
        program = '-m',
        args = {'pytest', '--verbose'},
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        cwd = '${workspaceFolder}',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🔍 PYTEST: Current File',
        program = '-m',
        args = function()
          return {
            'pytest',
            '${file}',
            '--verbose'
          }
        end,
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        cwd = '${workspaceFolder}',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🛠️ PYTEST: Custom Path/Args',
        program = '-m',
        args = function()
          local args = {'pytest'}
          
          local test_path = vim.fn.input('Test path (empty for all): ')
          if test_path ~= '' then
            for arg in test_path:gmatch("%S+") do
              table.insert(args, arg)
            end
          end
          
          local extra_args = vim.fn.input('Extra pytest arguments (e.g., -v -k "test_name"): ')
          if extra_args ~= '' then
            for arg in extra_args:gmatch("%S+") do
              table.insert(args, arg)
            end
          end
          
          vim.notify("Running pytest with args: " .. table.concat(args, " "), vim.log.levels.INFO)
          return args
        end,
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        cwd = '${workspaceFolder}',
        justMyCode = false,
      },
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

    -- Automatic virtual environment detection on directory change
    vim.api.nvim_create_autocmd({"DirChanged"}, {
      callback = function()
        dap.adapters.python.command = get_python_path()
      end,
    })
  end
}

