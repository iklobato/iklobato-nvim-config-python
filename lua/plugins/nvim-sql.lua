-- lua/plugins/vim-dadbod.lua
return {
  {
    'tpope/vim-dadbod',
    dependencies = {
      'kristijanhusak/vim-dadbod-ui',
      'kristijanhusak/vim-dadbod-completion',
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    config = function()
      -- Database connections
      vim.g.dbs = {
        default_postgres = 'postgresql://postgres:postgres@localhost:5432/wanna',
        default_ew = 'postgresql://postgres:postgres@localhost:5432/ew'
      }

      -- Core Settings
      vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui"
      vim.g.db_ui_tmp_query_location = vim.fn.stdpath("config") .. "/db_ui/queries"
      
      -- Window Management Settings
      vim.g.db_ui_win_position = 'right'
      vim.g.db_ui_winwidth = math.floor(vim.o.columns * 0.2) -- 20% of screen width
      vim.g.db_ui_show_help = true
      
      -- UI Settings
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_force_echo_notifications = true
      
      -- Table Helpers & Query Settings
      vim.g.db_ui_table_helpers = {
        postgresql = {
          Count = 'select count(*) from {optional_schema}{table}',
          Explain = 'EXPLAIN ANALYZE {last_query}',
          Indexes = 'SELECT * FROM pg_indexes WHERE tablename = \'{table}\' AND schemaname = \'{schema}\'',
          Foreign = 'SELECT * FROM information_schema.table_constraints WHERE constraint_type = \'FOREIGN KEY\' AND table_name = \'{table}\'',
          Primary = 'SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE i.indrelid = \'{table}\'::regclass AND i.indisprimary;'
        }
      }
      
      -- Query Settings
      vim.g.db_ui_auto_execute_table_helpers = true
      vim.g.db_ui_show_database_icon = true
      
      -- Window Dimensions
      vim.g.db_ui_results_height = math.floor(vim.o.lines * 0.4) -- 40% of screen height
      vim.g.db_ui_drawer_width = math.floor(vim.o.columns * 0.2) -- 20% of screen width
      vim.g.db_ui_drawer_persistent = true
      
      -- Column Widths
      vim.g.db_ui_columns_width = {
        bufnr = math.floor(vim.o.columns * 0.03),
        saved_query = math.floor(vim.o.columns * 0.15),
        query = math.floor(vim.o.columns * 0.45),
        time = math.floor(vim.o.columns * 0.07),
        rows = math.floor(vim.o.columns * 0.07)
      }
      
      -- Enhanced Features
      vim.g.db_ui_use_nvim_notify = true
      vim.g.db_ui_auto_refresh_tables = true
      vim.g.db_ui_disable_info_notifications = 0

      -- Modified query window opening function to preserve existing windows
      local function open_query_vsplit()
        -- Store current window
        local current_win = vim.api.nvim_get_current_win()
        
        -- Find the rightmost window
        local wins = vim.api.nvim_list_wins()
        local rightmost_win = current_win
        local max_x = 0
        
        for _, win in ipairs(wins) do
          local win_config = vim.api.nvim_win_get_config(win)
          local win_pos = vim.api.nvim_win_get_position(win)
          if win_pos[2] > max_x and win_config.relative == '' then
            max_x = win_pos[2]
            rightmost_win = win
          end
        end
        
        -- Focus rightmost window and split
        vim.api.nvim_set_current_win(rightmost_win)
        vim.cmd('vsplit')
        
        -- Configure the new window
        local new_win = vim.api.nvim_get_current_win()
        vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 0.6))
        
        -- Return to original window
        vim.api.nvim_set_current_win(current_win)
        
        return true
      end

      -- Window Settings
      vim.g.db_ui_win_settings = {
        query = {
          enable = false,
        },
        drawer = {
          fixed = true,
          width = math.floor(vim.o.columns * 0.2),
          height = vim.o.lines - 4,
          position = 'right',
        }
      }

      vim.g.db_ui_query_window = open_query_vsplit

      -- Window resize handler
      local function update_window_dimensions()
        vim.g.db_ui_drawer_width = math.floor(vim.o.columns * 0.2)
        vim.g.db_ui_columns_width = {
          bufnr = math.floor(vim.o.columns * 0.03),
          saved_query = math.floor(vim.o.columns * 0.15),
          query = math.floor(vim.o.columns * 0.45),
          time = math.floor(vim.o.columns * 0.07),
          rows = math.floor(vim.o.columns * 0.07)
        }
        
        vim.schedule(function()
          local wins = vim.api.nvim_list_wins()
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name:match("DBOut$") then
              vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.6))
            end
          end
        end)
      end

      -- Autocommands
      local autocmd = vim.api.nvim_create_autocmd
      
      -- Window resize handler
      autocmd('VimResized', {
        pattern = '*',
        callback = update_window_dimensions
      })

      -- SQL file settings
      autocmd('FileType', {
        pattern = {'sql', 'mysql', 'plsql', 'sqlite', 'pgsql'},
        callback = function()
          require('cmp').setup.buffer({
            sources = {
              { name = 'vim-dadbod-completion' },
              { name = 'nvim_lsp' },
              { name = 'buffer' }
            },
          })
          
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 2
          vim.opt_local.softtabstop = 2
        end
      })

      -- DBUI opened handler
      autocmd('User', {
        pattern = 'DBUIOpened',
        callback = function()
          vim.cmd('DBUIRefreshTable')
          update_window_dimensions()
        end
      })
    end,
  }
}
