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
    -- Configuration Builders
    -- ============================================================================

    -- Create Django configuration
    local function make_django_config(name, args)
      local config_name = type(name) == 'function' and name() or name
      -- Use safe default args if args is a function (don't call it during init)
      -- The function will be called later in resolve_config when dap.run() is invoked
      local default_args = type(args) == 'function' and {'help'} or args
      -- Store original function reference for runtime resolution
      local config = {
        type = 'python',
        request = 'launch',
        name = config_name,
        program = '${workspaceFolder}/manage.py',
        args = default_args,
        django = true,
        env = get_django_env(),
        pythonPath = function() return get_python_path() end,
        console = 'integratedTerminal',
        justMyCode = false,
      }
      -- Store original args function if it was a function, for runtime resolution
      if type(args) == 'function' then
        config._args_func = args
      end
      return config
    end

    -- Create Pytest configuration
    local function make_pytest_config(name, args)
      local config_name = type(name) == 'function' and name() or name
      -- Use safe default args if args is a function (don't call it during init)
      -- The function will be called later in resolve_config when dap.run() is invoked
      local default_args = type(args) == 'function' and {'--help'} or args
      -- Store original function reference for runtime resolution
      local config = {
        type = 'python',
        request = 'launch',
        name = config_name,
        module = 'pytest',
        args = default_args,
        cwd = '${workspaceFolder}',
        pythonPath = function() return get_python_path() end,
        console = 'integratedTerminal',
        justMyCode = false,
      }
      -- Store original args function if it was a function, for runtime resolution
      if type(args) == 'function' then
        config._args_func = args
      end
      return config
    end


    -- ============================================================================
    -- Telescope Picker Helper
    -- ============================================================================

    -- Reusable Telescope picker for test selection
    local function show_test_picker(tests, title, on_select)
      if #tests == 0 then
        vim.notify("No tests found", vim.log.levels.WARN)
        return
      end

      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      local picker = pickers.new({}, {
        prompt_title = title,
        finder = finders.new_table({
          results = tests,
          entry_maker = function(entry)
            return {
              value = entry.value,
              display = entry.display,
              ordinal = entry.display,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          map('i', '<CR>', function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection and on_select then
              on_select(selection.value)
            end
          end)
          map('i', '<Esc>', function()
            actions.close(prompt_bufnr)
          end)
          return true
        end,
      })

      picker:find()
    end

    -- ============================================================================
    -- Test Discovery Functions
    -- ============================================================================

    -- Find Django test files and parse test classes/methods
    local function find_django_tests()
      local tests = {}
      local cwd = vim.fn.getcwd()
      
      -- Find test files: test_*.py or files in tests/ directory
      local test_files = {}
      local patterns = {
        '**/test_*.py',
        '**/tests/**/*.py',
      }
      
      for _, pattern in ipairs(patterns) do
        local files = vim.fn.globpath(cwd, pattern, false, true)
        for _, file in ipairs(files) do
          if not file:match('__pycache__') and not file:match('%.pyc$') then
            test_files[file] = true
          end
        end
      end
      
      -- Parse each test file
      for file, _ in pairs(test_files) do
        local rel_file = vim.fn.fnamemodify(file, ':~:.')
        local lines = vim.fn.readfile(file)
        local current_class = nil
        local class_indent = nil
        
        for i, line in ipairs(lines) do
          -- Match Django test class: class TestClassName(TestCase):
          local class_match = line:match('^%s*class%s+([%w_]+)%s*%([^)]*TestCase')
          if class_match then
            local indent = line:match('^(%s*)')
            current_class = class_match
            class_indent = #indent
            table.insert(tests, {
              display = rel_file .. ' → ' .. current_class,
              value = current_class,
              file = file,
              line = i,
            })
          end
          
          -- Match test methods: def test_method_name(self):
          local method_match = line:match('^%s*def%s+(test_[%w_]+)%s*%(')
          if method_match and current_class then
            local indent = line:match('^(%s*)')
            if #indent > class_indent then
              table.insert(tests, {
                display = rel_file .. ' → ' .. current_class .. '.' .. method_match,
                value = current_class .. '.' .. method_match,
                file = file,
                line = i,
              })
            end
          end
        end
      end
      
      return tests
    end

    -- Find Pytest test files and parse test functions/classes
    local function find_pytest_tests()
      local tests = {}
      local cwd = vim.fn.getcwd()
      
      -- Find test files: test_*.py or *_test.py
      local test_files = {}
      local patterns = {
        '**/test_*.py',
        '**/*_test.py',
      }
      
      for _, pattern in ipairs(patterns) do
        local files = vim.fn.globpath(cwd, pattern, false, true)
        for _, file in ipairs(files) do
          if not file:match('__pycache__') and not file:match('%.pyc$') then
            test_files[file] = true
          end
        end
      end
      
      -- Parse each test file
      for file, _ in pairs(test_files) do
        local rel_file = vim.fn.fnamemodify(file, ':~:.')
        local lines = vim.fn.readfile(file)
        local current_class = nil
        local class_indent = nil
        
        for i, line in ipairs(lines) do
          -- Match pytest test class: class TestClassName:
          local class_match = line:match('^%s*class%s+(Test[%w_]*)%s*:')
          if class_match then
            local indent = line:match('^(%s*)')
            current_class = class_match
            class_indent = #indent
            -- Add class-level entry
            table.insert(tests, {
              display = rel_file .. '::' .. current_class,
              value = rel_file .. '::' .. current_class,
              file = file,
              line = i,
            })
          end
          
          -- Match test functions: def test_function_name():
          local func_match = line:match('^%s*def%s+(test_[%w_]+)%s*%(')
          if func_match then
            local indent = line:match('^(%s*)')
            if current_class and #indent > class_indent then
              -- Method in class
              table.insert(tests, {
                display = rel_file .. '::' .. current_class .. '::' .. func_match,
                value = rel_file .. '::' .. current_class .. '::' .. func_match,
                file = file,
                line = i,
              })
            elseif not current_class or #indent <= (class_indent or 0) then
              -- Standalone function or function at class level
              current_class = nil
              table.insert(tests, {
                display = rel_file .. '::' .. func_match,
                value = rel_file .. '::' .. func_match,
                file = file,
                line = i,
              })
            end
          end
        end
      end
      
      return tests
    end


    -- ============================================================================
    -- Configuration Definitions
    -- ============================================================================

    -- Django configurations
    local django_configs = {
      -- Run Server
      make_django_config(
        '🌐 DJANGO: Run Server (manage.py runserver --noreload)',
        { 'runserver', '--noreload' }
      ),

      -- Run Specific Test (with Telescope selection)
      make_django_config(
        '🧪 DJANGO: Run Specific Test (manage.py test --keepdb [selected])',
        function()
          local tests = find_django_tests()
          
          show_test_picker(tests, "Select Django Test", function(selected_test)
            local dap = require('dap')
            local config = {
              type = 'python',
              request = 'launch',
              name = 'Django Test: ' .. selected_test,
              program = '${workspaceFolder}/manage.py',
              args = {'test', '--keepdb', selected_test},
              django = true,
              console = 'integratedTerminal',
              justMyCode = false,
              env = get_django_env(),
              cwd = '${workspaceFolder}',
            }
            vim.notify("Running Django test: " .. selected_test, vim.log.levels.INFO)
            dap.run(config)
          end)
          
          -- Return default args (picker will handle actual DAP start)
          return {'test', '--keepdb'}
        end
      ),

      -- Custom Command
      make_django_config(
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
          
          vim.notify("Command stored: " .. cmd, vim.log.levels.INFO)
          return args
        end
      ),
    }

    -- Pytest configurations
    local pytest_configs = {
      -- Current File
      make_pytest_config(
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

      -- Run Specific Test (with Telescope selection)
      make_pytest_config(
        '🎯 PYTEST: Run Specific Test (python -m pytest [selected] --verbose)',
        function()
          local tests = find_pytest_tests()
          
          show_test_picker(tests, "Select Pytest Test", function(selected_test)
            local dap = require('dap')
            local config = {
              type = 'python',
              request = 'launch',
              name = 'Pytest: ' .. selected_test,
              module = 'pytest',
              args = {selected_test, '--verbose'},
              console = 'integratedTerminal',
              justMyCode = false,
            }
            vim.notify("Running Pytest test: " .. selected_test, vim.log.levels.INFO)
            dap.run(config)
          end)
          
          -- Return default args (picker will handle actual DAP start)
          return {'pytest', '--verbose'}
        end
      ),
    }


    -- Combine all configurations
    local all_configs = {}
    for _, config in ipairs(django_configs) do
      table.insert(all_configs, config)
    end
    for _, config in ipairs(pytest_configs) do
      table.insert(all_configs, config)
    end
    
    -- Assign configurations
    if not dap.configurations then
      dap.configurations = {}
    end
    
    if #all_configs == 0 then
      vim.notify("ERROR: No DAP configurations were created!", vim.log.levels.ERROR)
      return
    end
    
    dap.configurations.python = all_configs

    -- ============================================================================
    -- Configuration Resolution
    -- ============================================================================

    -- Helper function to resolve function values in configuration before launch
    local function resolve_config(config)
      if not config then return nil end
      
      local resolved = {}
      for k, v in pairs(config) do
        -- Skip internal metadata fields
        if k:match('^_') then
          -- Handle _args_func: resolve it and use for args
          if k == '_args_func' and type(v) == 'function' then
            resolved['args'] = v()
          end
          -- Don't copy other internal fields
        elseif type(v) == 'function' and (k == 'env' or k == 'pythonPath' or k == 'args' or k == 'program' or k == 'name') then
          resolved[k] = v()
        else
          resolved[k] = v
        end
      end
      
      return resolved
    end
    
    -- Override dap.run to resolve functions before launching and handle buffer modifications
    -- Names are already resolved at build time, but args/program/env/pythonPath may still be functions
    local original_run = dap.run
    dap.run = function(config, opts)
      -- Check if current buffer is modified before launching integrated terminal
      -- Neovim requires unmodified buffers for termopen()
      local current_buf = vim.api.nvim_get_current_buf()
      local is_modified = vim.api.nvim_buf_get_option(current_buf, 'modified')
      
      if is_modified then
        local buf_name = vim.api.nvim_buf_get_name(current_buf)
        local is_file_buffer = buf_name ~= '' and not vim.api.nvim_buf_get_option(current_buf, 'buftype')
        
        if is_file_buffer then
          -- Auto-save modified file buffers
          local success, err = pcall(function()
            vim.cmd('silent write')
          end)
          
          if not success then
            vim.notify("Failed to save buffer before DAP launch: " .. tostring(err), vim.log.levels.ERROR)
            vim.notify("Please save the file manually and try again", vim.log.levels.WARN)
            return
          end
          
          vim.notify("Buffer auto-saved before DAP launch", vim.log.levels.INFO)
        else
          -- Scratch buffer or unnamed buffer - warn and abort
          vim.notify("Cannot launch DAP: current buffer has unsaved changes and is not a file buffer", vim.log.levels.WARN)
          vim.notify("Please save your changes or switch to a file buffer", vim.log.levels.INFO)
          return
        end
      end
      
      -- Resolve config functions and launch
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

