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

      -- Save queries automatically
      vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui"
      
      -- Window display settings
      vim.g.db_ui_winwidth = math.floor(vim.o.columns * 0.2) -- Sidebar width 20% of screen
      vim.g.db_ui_results_height = math.floor(vim.o.lines * 0.5) -- Results window 50% of screen height
      
      -- Keep results with query buffer
      vim.g.db_ui_win_position = 'right' -- Places query buffer and results on the right
      vim.g.db_ui_use_nvim_notify = true
      
      -- Drawer position
      vim.g.db_ui_drawer_width = 30 -- Fixed width for the drawer
      vim.g.db_ui_drawer_persistent = true -- Keep drawer open when executing queries
      
      -- Table helpers settings
      vim.g.db_ui_auto_execute_table_helpers = true
      
      -- UI Customization
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_force_echo_notifications = true
      vim.g.db_ui_show_help = true
      vim.g.db_ui_auto_refresh_tables = true
      
      -- Query result options
      vim.g.db_ui_columns_width = {
        bufnr = 4,
        saved_query = 20,
        query = 60,
        time = 10,
        rows = 10
      }
      
      -- Query history
      vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui_queries"
      vim.g.db_ui_disable_mappings = false

      -- Auto-setup when opening SQL files
      local autocmd = vim.api.nvim_create_autocmd
      autocmd('FileType', {
        pattern = {'sql', 'mysql', 'plsql'},
        callback = function()
          -- Setup completion
          require('cmp').setup.buffer({
            sources = {
              { name = 'vim-dadbod-completion' },
              { name = 'buffer' },
            },
          })
          
          -- Set buffer-local options for better SQL editing
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 2
          vim.opt_local.softtabstop = 2
        end
      })
    end,
  }
}
