-- DAP (Debug Adapter Protocol) Configuration
-- Official documentation: https://github.com/mfussenegger/nvim-dap
return {
  'mfussenegger/nvim-dap',
  event = 'VeryLazy',
  config = function()
    local dap = require('dap')

    -- Configure logging - set to ERROR to suppress telemetry messages
    -- Available levels: TRACE, DEBUG, INFO, WARN, ERROR
    dap.set_log_level('ERROR')

    -- Signs configuration
    vim.fn.sign_define('DapBreakpoint', {
      text = '🔴',
      texthl = 'DapBreakpoint',
      linehl = '',
      numhl = 'DapBreakpoint'
    })
    vim.fn.sign_define('DapBreakpointCondition', {
      text = '🟡',
      texthl = 'DapBreakpoint',
      linehl = '',
      numhl = 'DapBreakpoint'
    })
    vim.fn.sign_define('DapBreakpointRejected', {
      text = '🚫',
      texthl = 'DapBreakpoint',
      linehl = '',
      numhl = 'DapBreakpoint'
    })
    vim.fn.sign_define('DapLogPoint', {
      text = '📝',
      texthl = 'DapLogPoint',
      linehl = '',
      numhl = 'DapLogPoint'
    })
    vim.fn.sign_define('DapStopped', {
      text = '▶️',
      texthl = 'DapStopped',
      linehl = 'DapStoppedLine',
      numhl = 'DapStopped'
    })

    -- Python path detection function
    local function get_python_path()
      local cwd = vim.fn.getcwd()
      
      -- Check for pipenv environment
      if vim.fn.executable('pipenv') == 1 then
        local handle = io.popen('cd "' .. cwd .. '" && pipenv --py 2>/dev/null')
        if handle then
          local pipenv_python = handle:read("*a"):gsub("%s+$", "")
          handle:close()
          if pipenv_python ~= '' and vim.fn.executable(pipenv_python) == 1 then
            return pipenv_python
          end
        end
      end
      
      -- Check for poetry environment
      if vim.fn.executable('poetry') == 1 then
        local handle = io.popen('cd "' .. cwd .. '" && poetry env info -p 2>/dev/null')
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
      local venv_patterns = {
        cwd .. '/.venv/bin/python',
        cwd .. '/venv/bin/python',
        cwd .. '/env/bin/python',
      }
      for _, path in ipairs(venv_patterns) do
        if vim.fn.executable(path) == 1 then
          return path
        end
      end
      
      -- Check for activated virtual environment
      local virtual_env = vim.env.VIRTUAL_ENV
      if virtual_env and virtual_env ~= '' then
        local venv_python = virtual_env .. '/bin/python'
        if vim.fn.executable(venv_python) == 1 then
          return venv_python
        end
      end
      
      -- Fallback to system python3 or python
      if vim.fn.executable('python3') == 1 then
        return 'python3'
      end
      
      return 'python'
    end

    -- Python debugpy adapter configuration
    -- Official debugpy documentation: https://github.com/microsoft/debugpy
    dap.adapters.python = function(callback, config)
      if config.request == 'attach' then
        ---@diagnostic disable-next-line: undefined-field
        local port = (config.connect or config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (config.connect or config).host or '127.0.0.1'
        callback({
          type = 'server',
          port = assert(port, '`connect.port` is required for attach'),
          host = host,
          options = {
            source_filetype = 'python',
          },
        })
      else
        callback({
          type = 'executable',
          command = get_python_path(),
          args = { '-m', 'debugpy.adapter' },
          options = {
            source_filetype = 'python',
          },
        })
      end
    end

    -- Python configurations
    -- Official debugpy configuration options: https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        justMyCode = false,
        stopOnEntry = false,
        showReturnValue = true,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file with arguments',
        program = '${file}',
        args = function()
          local args_string = vim.fn.input('Arguments: ')
          return vim.split(args_string, ' ')
        end,
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Launch module',
        module = function()
          return vim.fn.input('Module name: ')
        end,
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Django',
        program = '${workspaceFolder}/manage.py',
        args = { 'runserver', '--noreload' },
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        django = true,
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Django: Custom command',
        program = '${workspaceFolder}/manage.py',
        args = function()
          local args_string = vim.fn.input('Django command: ')
          return vim.split(args_string, ' ')
        end,
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        django = true,
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'attach',
        name = 'Attach remote',
        connect = function()
          local host = vim.fn.input('Host [127.0.0.1]: ')
          host = host ~= '' and host or '127.0.0.1'
          local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
          return { host = host, port = port }
        end,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🧪 PYTEST: Run All Tests',
        module = 'pytest',
        args = {},
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        justMyCode = false,
        stopOnEntry = false,
        showReturnValue = true,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🧪 PYTEST: Current File',
        module = 'pytest',
        args = { '${file}' },
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        justMyCode = false,
        stopOnEntry = false,
        showReturnValue = true,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🧪 PYTEST: Current Test',
        module = 'pytest',
        args = function()
          local file = vim.fn.expand('%')
          local line = vim.fn.line('.')
          return { file .. '::' .. line }
        end,
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        justMyCode = false,
        stopOnEntry = false,
        showReturnValue = true,
      },
      {
        type = 'python',
        request = 'launch',
        name = '🧪 PYTEST: Custom Path/Args',
        module = 'pytest',
        args = function()
          local test_path = vim.fn.input('Test path (e.g., test_file.py::test_function): ')
          if test_path == '' then
            return {}
          end
          local extra_args = vim.fn.input('Extra args (optional, e.g., -v -k "test_name"): ')
          local args = { test_path }
          if extra_args ~= '' then
            for arg in extra_args:gmatch('%S+') do
              table.insert(args, arg)
            end
          end
          return args
        end,
        pythonPath = get_python_path,
        console = 'integratedTerminal',
        justMyCode = false,
        stopOnEntry = false,
        showReturnValue = true,
      },
    }

    -- Update Python path on directory change
    vim.api.nvim_create_autocmd('DirChanged', {
      callback = function()
        -- Force re-evaluation of python path on next debug session
        dap.adapters.python = nil
        dap.adapters.python = function(callback, config)
          if config.request == 'attach' then
            ---@diagnostic disable-next-line: undefined-field
            local port = (config.connect or config).port
            ---@diagnostic disable-next-line: undefined-field
            local host = (config.connect or config).host or '127.0.0.1'
            callback({
              type = 'server',
              port = assert(port, '`connect.port` is required for attach'),
              host = host,
              options = {
                source_filetype = 'python',
              },
            })
          else
            callback({
              type = 'executable',
              command = get_python_path(),
              args = { '-m', 'debugpy.adapter' },
              options = {
                source_filetype = 'python',
              },
            })
          end
        end
      end,
    })
  end,
}
