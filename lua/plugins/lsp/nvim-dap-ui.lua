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
    -- Dynamic window size calculation functions
    local function get_left_panel_width()
      return math.floor(vim.o.columns * 0.25)
    end
    local function get_right_panel_width()
      return math.floor(vim.o.columns * 0.4)
    end
    -- Element sizes can also be dynamic based on terminal height if needed
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
          size = get_left_panel_width(),
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5, wrap = false },
            { id = "console", size = 0.5, wrap = false }
          },
          size = get_right_panel_width(),
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

    -- ============================================================================
    -- Environment Detection Helpers
    -- ============================================================================

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
      -- Use vim.env for Neovim 0.5+ (more reliable than vim.fn.environ())
      for k, v in pairs(vim.env) do
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

    -- ============================================================================
    -- Command Parsing Helpers
    -- ============================================================================

    -- Function to parse shell command and extract Python script and arguments
    local function parse_python_command(cmd)
      if not cmd or cmd == '' then
        return nil, {}
      end
      
      -- Split command into parts, handling quoted strings
      local parts = {}
      local current = ''
      local in_quotes = false
      local quote_char = nil
      
      for i = 1, #cmd do
        local char = cmd:sub(i, i)
        if (char == '"' or char == "'") and not in_quotes then
          in_quotes = true
          quote_char = char
        elseif char == quote_char and in_quotes then
          in_quotes = false
          quote_char = nil
        elseif char == ' ' and not in_quotes then
          if current ~= '' then
            table.insert(parts, current)
            current = ''
          end
        else
          current = current .. char
        end
      end
      if current ~= '' then
        table.insert(parts, current)
      end
      
      if #parts == 0 then
        return nil, {}
      end
      
      -- Find Python executable (python, python3, or full path)
      local python_idx = nil
      for i, part in ipairs(parts) do
        if part:match('^python') or part:match('python$') or part:match('/python') then
          python_idx = i
          break
        end
      end
      
      if not python_idx then
        -- Command doesn't start with python, might be a wrapper like 'make run'
        -- Return the command as-is and let user handle it
        return nil, {}
      end
      
      -- Extract program and args
      local program = nil
      local args = {}
      local next_idx = python_idx + 1
      
      if next_idx <= #parts then
        local next_part = parts[next_idx]
        if next_part == '-m' then
          -- Module mode: python -m module.name args...
          program = '-m'
          if next_idx + 1 <= #parts then
            table.insert(args, parts[next_idx + 1])
            -- Add remaining parts as args
            for i = next_idx + 2, #parts do
              table.insert(args, parts[i])
            end
          end
        else
          -- Script mode: python script.py args...
          program = parts[next_idx]
          -- Add remaining parts as args
          for i = next_idx + 1, #parts do
            table.insert(args, parts[i])
          end
        end
      end
      
      return program, args
    end

    -- ============================================================================
    -- DAP Adapter Configuration
    -- ============================================================================

    dap.adapters.python = {
      type = 'executable',
      command = get_python_path(),
      args = { '-m', 'debugpy.adapter' }
    }

    -- Initialize configurations table early
    if not dap.configurations then
      dap.configurations = {}
    end
    -- Don't initialize python configs here - we'll assign them after building

    -- ============================================================================
    -- State Management
    -- ============================================================================

    -- Initialize last command storage
    local last_django_command = nil
    local last_custom_command = nil

    -- ============================================================================
    -- Path Utilities
    -- ============================================================================

    -- Format file path for display (relative path or filename)
    local function format_file_path(file)
      if file == '' then
        return '[no file]'
      end
      local filename = vim.fn.fnamemodify(file, ':t')
      local relative_path = vim.fn.fnamemodify(file, ':.')
      if relative_path == file then
        relative_path = vim.fn.fnamemodify(file, ':~:.')
      end
      -- Use relative path if it's shorter and different, otherwise just filename
      if #relative_path < #file and relative_path ~= file then
        return relative_path
      else
        return filename
      end
    end

    -- ============================================================================
    -- Name Generation Helpers
    -- ============================================================================

    -- Build command name string from parts
    local function build_command_name(parts)
      return table.concat(parts, ' ')
    end

    -- Create name for current file configs
    local function create_file_name(prefix, file)
      local display_path = format_file_path(file)
      return prefix .. ' (' .. display_path .. ')'
    end

    -- Create name for pytest with file and function
    local function create_pytest_function_name(file, func_name)
      local display_path = format_file_path(file)
      if func_name then
        return '🎯 PYTEST: Function Under Cursor (python -m pytest ' .. display_path .. ' -k "' .. func_name .. '" --verbose)'
      else
        return '🎯 PYTEST: Function Under Cursor (python -m pytest ' .. display_path .. ' -k [no function found] --verbose)'
      end
    end

    -- ============================================================================
    -- Configuration Builders
    -- ============================================================================

    -- Create base Python configuration properties
    local function create_base_python_config()
      return {
        type = 'python',
        request = 'launch',
        pythonPath = function() return get_python_path() end,
        console = 'integratedTerminal',
        justMyCode = false,
      }
    end

    -- Create Django-specific configuration properties
    local function create_django_config()
      local base = create_base_python_config()
      base.django = true
      base.env = get_django_env()
      base.program = '${workspaceFolder}/manage.py'
      return base
    end

    -- Create Pytest-specific configuration properties
    local function create_pytest_config()
      local base = create_base_python_config()
      base.program = '-m'
      base.cwd = '${workspaceFolder}'
      return base
    end

    -- Helper function to resolve name (function or string) to a string
    -- For dynamic names, resolves with current state or provides sensible default
    local function resolve_name(name)
      if type(name) == 'function' then
        -- Call the function to get the name string
        -- Use pcall to handle any errors gracefully
        local success, result = pcall(name)
        if success and type(result) == 'string' then
          return result
        else
          -- Fallback if function fails or returns non-string
          -- Try to provide a meaningful default based on the function's context
          if not success then
            vim.notify("Warning: Name function failed: " .. tostring(result), vim.log.levels.WARN)
          end
          return '[Name resolution failed]'
        end
      elseif type(name) == 'string' then
        return name
      else
        -- Fallback for unexpected types
        return '[Invalid name type]'
      end
    end

    -- Build Django configuration
    local function build_django_config(name, args)
      local config = create_django_config()
      -- Resolve function-based names immediately
      config.name = resolve_name(name)
      config.args = args
      return config
    end

    -- Build Pytest configuration
    local function build_pytest_config(name, args)
      local config = create_pytest_config()
      -- Resolve function-based names immediately
      config.name = resolve_name(name)
      config.args = args
      return config
    end

    -- Build generic Python configuration
    local function build_python_config(name, program, args, extra)
      local config = create_base_python_config()
      -- Resolve function-based names immediately
      config.name = resolve_name(name)
      config.program = program
      config.args = args
      if extra then
        for k, v in pairs(extra) do
          config[k] = v
        end
      end
      return config
    end

    -- Function to get the function name under cursor (for pytest function testing)
    local function get_function_under_cursor()
      local bufnr = vim.api.nvim_get_current_buf()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]  -- 1-indexed
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      
      local current_class = nil
      local class_indent = nil
      
      -- Search backwards from cursor for function or class definition
      for i = cursor_line, 1, -1 do
        local line = lines[i]
        if not line then
          goto continue
        end
        
        -- Skip empty lines and comments
        if line:match('^%s*$') or line:match('^%s*#') then
          goto continue
        end
        
        -- Calculate indentation level
        local indent = line:match('^(%s*)')
        local indent_level = #indent
        
        -- Match class definitions (must be before we find a function)
        local class_match = line:match('^%s*class%s+([%w_]+)')
        if class_match then
          -- Only update if this class is at a higher level (less indented) than current
          if not current_class or (class_indent and indent_level <= class_indent) then
            current_class = class_match
            class_indent = indent_level
          end
        end
        
        -- Match function definitions
        local func_match = line:match('^%s*def%s+([%w_]+)%s*%(')
        if func_match then
          -- If we found a class earlier and this function is indented (inside the class)
          if current_class and class_indent and indent_level > class_indent then
            -- Return pytest format: ClassName::method_name
            return current_class .. '::' .. func_match
          elseif not current_class or (class_indent and indent_level <= class_indent) then
            -- Standalone function or function at class level (not inside)
            return func_match
          end
        end
        
        -- Stop if we've gone too far back (hit top-level code)
        if indent_level == 0 and i < cursor_line - 50 then
          break
        end
        ::continue::
      end
      
      -- If we found a class but no method, return the class name
      if current_class then
        return current_class
      end
      
      return nil
    end

    -- ============================================================================
    -- Configuration Definitions
    -- ============================================================================

    -- Django configurations
    local django_configs = {
      -- Rerun Last Django Command
      build_django_config(
        function()
          if last_django_command then
            return '⏮️  DJANGO: Rerun Last Command (manage.py ' .. table.concat(last_django_command, " ") .. ')'
          else
            return '⏮️  DJANGO: Rerun Last Command (manage.py [no previous command])'
          end
        end,
        function()
          if last_django_command then
            vim.notify("Rerunning command: " .. table.concat(last_django_command, " "), vim.log.levels.INFO)
            return last_django_command
          else
            vim.notify("No previous command found. Please run a Django command first.", vim.log.levels.WARN)
            return {'help'}
          end
        end
      ),

      -- Run Server
      build_django_config(
        '🌐 DJANGO: Run Server (manage.py runserver --noreload)',
        { 'runserver', '--noreload' }
      ),

      -- Run Tests
      build_django_config(
        '🧪 DJANGO: Run Tests (manage.py test --keepdb [path])',
        function()
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
        end
      ),

      -- Shell Plus
      build_django_config(
        '🔮 DJANGO: Shell Plus (manage.py shell_plus --ipython)',
        {'shell_plus', '--ipython'}
      ),

      -- Custom Command
      build_django_config(
        '⚙️  DJANGO: Custom Command (manage.py [command])',
        function()
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
        end
      ),
    }

    -- Python configurations
    local python_configs = {
      -- Current File
      build_python_config(
        function()
          local file = vim.fn.expand('%:p')
          return create_file_name('🐍 PYTHON: Current File', file)
        end,
        '${file}',
        nil,
        { cwd = '${workspaceFolder}', stopOnEntry = false }
      ),
    }

    -- Pytest configurations
    local pytest_configs = {
      -- Run All Tests
      build_pytest_config(
        '🎯 PYTEST: Run All Tests (python -m pytest --verbose)',
        {'pytest', '--verbose'}
      ),

      -- Current File
      build_pytest_config(
        function()
          local file = vim.fn.expand('%:p')
          if file == '' then
            return '🔍 PYTEST: Current File (python -m pytest [no file] --verbose)'
          end
          local display_path = format_file_path(file)
          return '🔍 PYTEST: Current File (python -m pytest ' .. display_path .. ' --verbose)'
        end,
        function()
          return {'pytest', '${file}', '--verbose'}
        end
      ),

      -- Function Under Cursor
      build_pytest_config(
        function()
          local file = vim.fn.expand('%:p')
          if file == '' then
            return '🎯 PYTEST: Function Under Cursor (python -m pytest -k [no file])'
          end
          local func_name = get_function_under_cursor()
          return create_pytest_function_name(file, func_name)
        end,
        function()
          local file = vim.fn.expand('%:p')
          if file == '' then
            vim.notify("No file open", vim.log.levels.WARN)
            return {'pytest', '--verbose'}
          end
          
          local func_name = get_function_under_cursor()
          if not func_name then
            vim.notify("Could not find function under cursor. Make sure your cursor is inside a function definition.", vim.log.levels.WARN)
            return {'pytest', '${file}', '--verbose'}
          end
          
          vim.notify("Running pytest for function: " .. func_name, vim.log.levels.INFO)
          
          return {'pytest', '${file}', '-k', func_name, '--verbose'}
        end
      ),

      -- Custom Path/Args
      build_pytest_config(
        '🛠️ PYTEST: Custom Path/Args (python -m pytest [path] [args])',
        function()
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
        end
      ),
    }

    -- Custom configurations
    local custom_configs = {
      -- Run Command
      build_python_config(
        '🔧 CUSTOM: Run Command (python [script] [args])',
        function()
          local cmd = vim.fn.input('Command (e.g., python script.py or make run): ')
          if cmd == "" then
            vim.notify("Command cancelled", vim.log.levels.WARN)
            return nil
          end
          
          last_custom_command = cmd
          
          local program, args = parse_python_command(cmd)
          
          if not program then
            vim.notify("Could not parse Python command. Please use format: python script.py or python -m module", vim.log.levels.ERROR)
            return nil
          end
          
          if program ~= '-m' and not program:match('^/') then
            if program:match('^%.%/') then
              program = program:sub(3)
            end
            program = '${workspaceFolder}/' .. program
          end
          
          vim.notify("Running command: " .. cmd, vim.log.levels.INFO)
          return program
        end,
        function()
          if not last_custom_command then
            return {}
          end
          local _, args = parse_python_command(last_custom_command)
          return args
        end,
        { cwd = '${workspaceFolder}', env = get_django_env() }
      ),

      -- Run Last Command
      build_python_config(
        function()
          if last_custom_command then
            return '🔧 CUSTOM: Run Last Command (' .. last_custom_command .. ')'
          else
            return '🔧 CUSTOM: Run Last Command ([no previous command])'
          end
        end,
        function()
          if not last_custom_command then
            vim.notify("No previous command found. Please run a custom command first.", vim.log.levels.WARN)
            return nil
          end
          
          vim.notify("Rerunning command: " .. last_custom_command, vim.log.levels.INFO)
          
          local program, _ = parse_python_command(last_custom_command)
          
          if not program then
            vim.notify("Could not parse stored command.", vim.log.levels.ERROR)
            return nil
          end
          
          if program ~= '-m' and not program:match('^/') then
            if program:match('^%.%/') then
              program = program:sub(3)
            end
            program = '${workspaceFolder}/' .. program
          end
          
          return program
        end,
        function()
          if not last_custom_command then
            return {}
          end
          local _, args = parse_python_command(last_custom_command)
          return args
        end,
        { cwd = '${workspaceFolder}', env = get_django_env() }
      ),
    }

    -- Combine all configurations
    -- Ensure dap.configurations exists
    if not dap.configurations then
      dap.configurations = {}
    end
    
    -- Build the configurations array
    local all_configs = {}
    for _, config in ipairs(django_configs) do
      table.insert(all_configs, config)
    end
    for _, config in ipairs(python_configs) do
      table.insert(all_configs, config)
    end
    for _, config in ipairs(pytest_configs) do
      table.insert(all_configs, config)
    end
    for _, config in ipairs(custom_configs) do
      table.insert(all_configs, config)
    end
    
    -- Assign to dap.configurations.python
    -- Ensure we have at least some configurations
    if #all_configs == 0 then
      vim.notify("ERROR: No DAP configurations were created! Check builder functions.", vim.log.levels.ERROR)
      -- Don't assign empty array - leave it as nil so error is clear
      return
    end
    
    -- Explicitly ensure dap.configurations exists
    if not dap.configurations then
      dap.configurations = {}
    end
    
    -- Verify all configurations are proper tables before assignment
    for i, config in ipairs(all_configs) do
      if type(config) ~= 'table' then
        vim.notify("ERROR: Configuration " .. i .. " is not a table! Type: " .. type(config), vim.log.levels.ERROR)
        return
      end
      
      -- Ensure name is a string, not a function
      if config.name and type(config.name) == 'function' then
        vim.notify("WARNING: Configuration " .. i .. " still has function-based name. Resolving now...", vim.log.levels.WARN)
        config.name = resolve_name(config.name)
      end
      
      -- Ensure env is a table, not a function (if present)
      if config.env and type(config.env) == 'function' then
        vim.notify("ERROR: Configuration " .. i .. " has env as function! This should be a table.", vim.log.levels.ERROR)
        config.env = config.env()  -- Resolve it
      end
      
      -- Verify no other table-expected fields are functions (except args/program/pythonPath which are allowed)
      local table_fields = {'cwd', 'console', 'django'}
      for _, field in ipairs(table_fields) do
        if config[field] and type(config[field]) == 'function' then
          vim.notify("ERROR: Configuration " .. i .. " has " .. field .. " as function! This should not be a function.", vim.log.levels.ERROR)
          -- Don't resolve, just remove it to prevent errors
          config[field] = nil
        end
      end
    end
    
    -- Create a clean array copy to ensure no metatables or wrappers
    -- This prevents any issues with DAP's iteration
    local clean_configs = {}
    for i, config in ipairs(all_configs) do
      -- Create a clean copy of each config to ensure it's a plain table
      local clean_config = {}
      for k, v in pairs(config) do
        clean_config[k] = v
      end
      clean_configs[i] = clean_config
    end
    
    -- Assign clean configurations (ensure no metatable)
    dap.configurations.python = clean_configs
    -- Explicitly remove any metatable that might have been set
    setmetatable(dap.configurations.python, nil)
    
    -- Verify assignment worked and test iteration
    if not dap.configurations.python or #dap.configurations.python == 0 then
      vim.notify("ERROR: Failed to assign configurations to dap.configurations.python!", vim.log.levels.ERROR)
      return
    end
    
    -- Test that pairs() works correctly (this is what DAP uses)
    -- This is critical - if this fails, DAP will fail too
    local success, err = pcall(function()
      local pair_count = 0
      for k, v in pairs(dap.configurations.python) do
        if type(k) == 'number' and type(v) == 'table' then
          pair_count = pair_count + 1
          -- Verify each config is iterable
          for ck, cv in pairs(v) do
            -- Just verify we can iterate - don't check types here
          end
        elseif type(v) == 'function' then
          vim.notify("ERROR: Found function at index " .. tostring(k) .. " in configurations array!", vim.log.levels.ERROR)
        end
      end
      
      -- Test that ipairs() works correctly
      local ipair_count = 0
      for i, v in ipairs(dap.configurations.python) do
        if type(v) == 'table' then
          ipair_count = ipair_count + 1
        elseif type(v) == 'function' then
          vim.notify("ERROR: Found function at index " .. i .. " in configurations array!", vim.log.levels.ERROR)
        end
      end
      
      if pair_count ~= #dap.configurations.python or ipair_count ~= #dap.configurations.python then
        vim.notify("WARNING: Configuration iteration test failed. pairs()=" .. pair_count .. ", ipairs()=" .. ipair_count .. ", length=" .. #dap.configurations.python, vim.log.levels.WARN)
      end
    end)
    
    if not success then
      vim.notify("ERROR: Failed to iterate configurations! Error: " .. tostring(err), vim.log.levels.ERROR)
      -- Don't assign if iteration fails
      dap.configurations.python = {}
      return
    end
    
    vim.notify("DAP: Successfully created " .. #dap.configurations.python .. " Python configurations", vim.log.levels.INFO)

    -- Note: Names are now resolved at build time, so no proxy wrapper is needed
    -- This ensures DAP can properly iterate over configurations with pairs()/ipairs()

    -- ============================================================================
    -- Configuration Resolution
    -- ============================================================================

    -- Helper function to resolve function values in configuration before launch
    local function resolve_config(config)
      if not config then return nil end
      
      local resolved = {}
      for k, v in pairs(config) do
        if type(v) == 'function' and (k == 'env' or k == 'pythonPath' or k == 'args' or k == 'program' or k == 'name') then
          resolved[k] = v()
        else
          resolved[k] = v
        end
      end
      
      return resolved
    end
    
    -- Override dap.run to resolve functions before launching
    -- Names are already resolved at build time, but args/program/env/pythonPath may still be functions
    local original_run = dap.run
    dap.run = function(config, opts)
      local resolved_config = resolve_config(config)
      return original_run(resolved_config, opts)
    end
    

    -- ============================================================================
    -- DAP Event Handlers
    -- ============================================================================

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

    -- Handle debugpySockets event to suppress warnings
    dap.listeners.after.event_debugpySockets = function(session, body)
      -- This event is sent by debugpy to inform about socket connections
      -- We can safely ignore it as it's informational only
    end

    -- ============================================================================
    -- Autocmds
    -- ============================================================================

    -- Automatic virtual environment detection on directory change
    vim.api.nvim_create_autocmd({"DirChanged"}, {
      callback = function()
        dap.adapters.python.command = get_python_path()
      end,
    })

    -- Dynamic window resizing when terminal is resized
    vim.api.nvim_create_autocmd({"VimResized"}, {
      callback = function()
        -- Only resize if DAP UI is open
        if dapui.is_open() then
          -- Calculate new sizes based on current terminal dimensions
          local left_width = math.floor(vim.o.columns * 0.25)
          local right_width = math.floor(vim.o.columns * 0.4)
          
          -- Store current state (which elements were open)
          local was_open = dapui.is_open()
          
          -- Close and reopen DAP UI
          dapui.close()
          vim.defer_fn(function()
            if was_open then
              dapui.open()
              
              -- After reopening, resize the windows to match new terminal size
              vim.defer_fn(function()
                local wins = vim.api.nvim_list_wins()
                for _, win in ipairs(wins) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  local buf_name = vim.api.nvim_buf_get_name(buf)
                  
                  -- Check if this is a DAP UI window by buffer name pattern
                  if buf_name:match("dapui_") or buf_name:match("dap%-ui") then
                    local win_config = vim.api.nvim_win_get_config(win)
                    -- Check window position to determine if it's left or right panel
                    if win_config.relative == '' then  -- Only non-floating windows
                      local win_col = vim.api.nvim_win_get_position(win)[2]
                      -- Left panel windows are typically on the left side
                      if win_col < vim.o.columns / 3 then
                        vim.api.nvim_win_set_width(win, left_width)
                      -- Right panel windows are on the right side
                      elseif win_col > vim.o.columns / 2 then
                        vim.api.nvim_win_set_width(win, right_width)
                      end
                    end
                  end
                end
              end, 150)
            end
          end, 50)
        end
      end,
    })
  end
}

