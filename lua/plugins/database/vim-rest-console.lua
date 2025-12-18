return {
  {
    'diepm/vim-rest-console',
    ft = { 'rest', 'http' },
    config = function()
      vim.g.vrc_set_default_mapping = 0
      vim.g.vrc_response_default_content_type = 'application/json'
      vim.g.vrc_output_buffer_name = '_OUTPUT.json'
      vim.g.vrc_auto_format_response_patterns = {
        json = 'jq .',  -- Format JSON with jq (the . ensures it formats even if there are headers)
        xml = 'xmllint --format -',
      }
      vim.g.vrc_horizontal_split = 1  -- Horizontal split for response
      -- Note: vrc_include_response_header is deprecated, using -i in vrc_curl_opts instead
      vim.g.vrc_show_command = 1  -- Show the curl command (shows request method, URL, and headers)
      vim.g.vrc_debug = 0  -- Set to 1 for very verbose output (shows all curl debug info)
      vim.g.vrc_elasticsearch_support = 1
      vim.g.vrc_curl_opts = {
        ['-i'] = '',  -- Include response headers in output
        -- Removed -v (verbose) to reduce clutter and allow proper JSON formatting
        -- Use -i for response headers and vrc_show_command for request info
        ['-k'] = '',  -- Allow insecure SSL
        ['-L'] = '',  -- Follow redirects
        ['--connect-timeout'] = 10,
        ['--max-time'] = 60,
        ['--ipv4'] = '',
        ['-s'] = '',  -- Silent mode (no progress bar) - helps with JSON parsing
      }
      vim.g.vrc_auto_format_response_enabled = 1  -- Enable automatic JSON/XML formatting
      vim.g.vrc_auto_format_uhex = 1  -- Convert unicode escapes in JSON
      vim.g.vrc_keepalt = 1
      vim.g.vrc_allow_get_request_body = 1
      vim.g.vrc_syntax_highlight_response = 1
      vim.g.vrc_split_request_body = 0
      vim.g.vrc_trigger = ''
      vim.g.vrc_body_delimiter = ''

      -- Helper function to execute REST query
      local function execute_rest_query()
        -- Check if function exists
        if vim.fn.exists('*VrcQuery') == 1 then
          -- Check if we're in REST Client format and provide helpful error
          local current_line = vim.api.nvim_get_current_line()
          if current_line:match('^%s*%u+%s+https?://') then
            -- This is REST Client format, vim-rest-console needs different format
            vim.notify(
              'Wrong format! vim-rest-console expects:\n' ..
              'HTTPS://api.example.com\n' ..
              'GET /users\n\n' ..
              'Run :HttpFormatHelp for format info\n' ..
              'Run :HttpConvertFormat to auto-convert',
              vim.log.levels.WARN
            )
            return
          end
          
          -- Create a unique buffer name for each request (with timestamp and counter)
          -- Use a buffer-local counter to ensure uniqueness even within the same second
          if not vim.b.vrc_request_counter then
            vim.b.vrc_request_counter = 0
          end
          vim.b.vrc_request_counter = vim.b.vrc_request_counter + 1
          local timestamp = os.date('%H%M%S')
          local buffer_name = '_OUTPUT_' .. timestamp .. '_' .. vim.b.vrc_request_counter .. '.json'
          vim.b.vrc_output_buffer_name = buffer_name
          
          vim.cmd('call VrcQuery()')
        else
          -- Try to load the plugin via Lazy
          local lazy_ok, lazy = pcall(require, 'lazy')
          if lazy_ok and lazy then
            lazy.load({ plugins = { 'diepm/vim-rest-console' } })
            vim.defer_fn(function()
              if vim.fn.exists('*VrcQuery') == 1 then
                vim.cmd('call VrcQuery()')
              else
                vim.notify('vim-rest-console loaded but VrcQuery not available. Try :Lazy load vim-rest-console', vim.log.levels.WARN)
              end
            end, 100)
          else
            -- Fallback: try to source manually
            local plugin_path = vim.fn.stdpath('data') .. '/lazy/vim-rest-console'
            if vim.fn.isdirectory(plugin_path) == 1 then
              local autoload_file = plugin_path .. '/autoload/vrc/opt.vim'
              local ftplugin_file = plugin_path .. '/ftplugin/rest.vim'
              if vim.fn.filereadable(autoload_file) == 1 then
                vim.cmd('source ' .. autoload_file)
              end
              if vim.fn.filereadable(ftplugin_file) == 1 then
                vim.cmd('source ' .. ftplugin_file)
              end
              vim.defer_fn(function()
                if vim.fn.exists('*VrcQuery') == 1 then
                  vim.cmd('call VrcQuery()')
                else
                  vim.notify('VrcQuery function not available. Please restart Neovim.', vim.log.levels.ERROR)
                end
              end, 50)
            else
              vim.notify('vim-rest-console not found. Run :Lazy install', vim.log.levels.ERROR)
            end
          end
        end
      end

      -- Track if plugin files have been sourced (only source once)
      local plugin_files_sourced = false
      
      -- Helper function to source plugin files (only once)
      local function source_plugin_files()
        if plugin_files_sourced then
          return
        end
        
        local plugin_path = vim.fn.stdpath('data') .. '/lazy/vim-rest-console'
        if vim.fn.isdirectory(plugin_path) == 1 then
          -- Source autoload files first (needed by ftplugin)
          local autoload_file = plugin_path .. '/autoload/vrc/opt.vim'
          if vim.fn.filereadable(autoload_file) == 1 then
            vim.cmd('source ' .. autoload_file)
          end
          -- Source the ftplugin file that contains VrcQuery function
          local ftplugin_file = plugin_path .. '/ftplugin/rest.vim'
          if vim.fn.filereadable(ftplugin_file) == 1 then
            vim.cmd('source ' .. ftplugin_file)
          end
          plugin_files_sourced = true
        end
      end
      
      -- Helper function to set up keymap for HTTP/REST buffer
      local function setup_http_keymap(bufnr)
        -- Get the buffer number (use provided or current)
        local buf = bufnr or vim.api.nvim_get_current_buf()
        local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
        
        -- Only proceed if it's an HTTP/REST file
        if filetype ~= 'http' and filetype ~= 'rest' then
          return
        end
        
        -- Set keymap with proper configuration to prevent conflicts
        vim.defer_fn(function()
          -- Make sure we're still in an HTTP buffer
          local current_buf = vim.api.nvim_get_current_buf()
          local current_ft = vim.api.nvim_buf_get_option(current_buf, 'filetype')
          if current_ft ~= 'http' and current_ft ~= 'rest' then
            return
          end
          
          -- Check if keymap already exists for this buffer using correct API
          local existing = vim.fn.mapcheck('<leader>rr', 'n')
          if existing ~= '' then
            -- Keymap already exists, don't set it again
            return
          end
          
          -- Set the keymap using the proper API for this specific buffer
          vim.keymap.set('n', '<leader>rr', execute_rest_query, {
            buffer = buf,
            desc = "Execute REST request",
            remap = false,  -- Use noremap (don't remap)
            silent = true,  -- Don't echo the command
          })
        end, 10)
      end

      -- Source plugin files when filetype is first detected
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"rest", "http"},
        callback = function(args)
          source_plugin_files()
          setup_http_keymap(args.buf)
        end
      })
      
      -- Set up keymap when entering HTTP/REST buffers (for when switching between buffers)
      -- Only set the keymap, don't source files again
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = {"*.http", "*.rest"},
        callback = function(args)
          setup_http_keymap(args.buf)
        end
      })
      
      -- Also set up when window enters HTTP/REST buffers
      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = {"*.http", "*.rest"},
        callback = function(args)
          setup_http_keymap(args.buf)
        end
      })
      
      -- Configure output buffers (match any buffer starting with "_OUTPUT")
      local function configure_output_buffer()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname:match('_OUTPUT') or vim.fn.bufname(0):match('_OUTPUT') then
          vim.opt_local.wrap = false
          vim.opt_local.linebreak = true
          vim.opt_local.breakindent = true
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
        end
      end
      
      vim.api.nvim_create_autocmd({"BufWinEnter", "BufNewFile"}, {
        callback = configure_output_buffer
      })
    end,
  }
}
