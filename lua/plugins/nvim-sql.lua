-- lua/plugins/vim-dadbod.lua
return {
  {
    'tpope/vim-dadbod',
    dependencies = {
      'kristijanhusak/vim-dadbod-ui',
      'kristijanhusak/vim-dadbod-completion',
    },
    opt = true,
    config = function()
      -- Database connections
      vim.g.dbs = {
        default_postgres = 'postgresql://postgres:postgres@localhost:5432/wanna'
      }

      -- Core Settings
      vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui"
      vim.g.db_ui_tmp_query_location = vim.fn.stdpath("config") .. "/db_ui/queries"
      
      -- Window Management Settings
      vim.g.db_ui_win_position = 'right'
      vim.g.db_ui_winwidth = math.floor(vim.o.columns * 0.2) -- 20% of screen width
      vim.g.db_ui_show_help = true
      
      -- Prevent window conflicts
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
      
      -- Query execution settings
      vim.g.db_ui_auto_execute_table_helpers = true
      vim.g.db_ui_show_database_icon = true
      
      -- Results window height
      vim.g.db_ui_results_height = math.floor(vim.o.lines * 0.4) -- 40% of screen height
      
      -- Drawer settings with proportional width
      vim.g.db_ui_drawer_width = math.floor(vim.o.columns * 0.2) -- 20% of screen width
      vim.g.db_ui_drawer_persistent = true
      
      -- Query result column widths
      vim.g.db_ui_columns_width = {
        bufnr = math.floor(vim.o.columns * 0.03),
        saved_query = math.floor(vim.o.columns * 0.15),
        query = math.floor(vim.o.columns * 0.45),
        time = math.floor(vim.o.columns * 0.07),
        rows = math.floor(vim.o.columns * 0.07)
      }
      
      -- Enhanced UI Settings
      vim.g.db_ui_use_nvim_notify = true
      vim.g.db_ui_auto_refresh_tables = true
      vim.g.db_ui_disable_info_notifications = 0

      -- Custom function to open query in vertical split
      local function open_query_vsplit()
        -- Close any existing query window
        vim.cmd('silent! bdelete DBOut')
        
        -- Create vertical split
        vim.cmd('vsplit')
        -- Move to the right window
        vim.cmd('wincmd l')
        -- Set the width to 60% of screen
        vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 0.6))
        
        -- Return true to indicate we handled the window creation
        return true
      end

      -- Improved Window Settings
      vim.g.db_ui_win_settings = {
        query = {
          enable = false, -- Disable default floating window
        },
        drawer = {
          fixed = true,
          width = math.floor(vim.o.columns * 0.2),
          height = vim.o.lines - 4,
          position = 'right',
        }
      }

      -- Register custom query window handler
      vim.g.db_ui_query_window = open_query_vsplit

      -- Window resize handler
      local function update_window_dimensions()
        -- Update drawer width
        vim.g.db_ui_drawer_width = math.floor(vim.o.columns * 0.2)
        -- Update column widths
        vim.g.db_ui_columns_width = {
          bufnr = math.floor(vim.o.columns * 0.03),
          saved_query = math.floor(vim.o.columns * 0.15),
          query = math.floor(vim.o.columns * 0.45),
          time = math.floor(vim.o.columns * 0.07),
          rows = math.floor(vim.o.columns * 0.07)
        }
        
        -- Resize any existing query windows
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

      -- Auto-setup for SQL files
      local autocmd = vim.api.nvim_create_autocmd
      
      -- Add VimResized event handler
      autocmd('VimResized', {
        pattern = '*',
        callback = update_window_dimensions
      })

      -- SQL file type settings
      autocmd('FileType', {
        pattern = {'sql', 'mysql', 'plsql', 'sqlite', 'pgsql'},
        callback = function()
          require('cmp').setup.buffer({
            sources = {
              { name = 'vim-dadbod-completion' },
              { name = 'buffer' },
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
          -- Update dimensions when DBUI is opened
          update_window_dimensions()
        end
      })
    end,
  }
}
