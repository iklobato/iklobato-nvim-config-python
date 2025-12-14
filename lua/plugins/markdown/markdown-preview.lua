-- Markdown Preview
-- Preview markdown files in a browser
-- https://github.com/iamcco/markdown-preview.nvim
return {
  "iamcco/markdown-preview.nvim",
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  init = function()
    -- Set global variables before the plugin loads
    vim.g.mkdp_filetypes = { "markdown" }
    -- Basic settings
    vim.g.mkdp_auto_start = 0              -- Don't auto-start preview
    vim.g.mkdp_auto_close = 1              -- Auto-close when leaving markdown buffer
    vim.g.mkdp_refresh_slow = 0            -- Fast refresh
    vim.g.mkdp_command_for_global = 0      -- Only for markdown filetype
    
    -- Browser settings
    vim.g.mkdp_open_to_the_world = 0       -- Only localhost
    vim.g.mkdp_open_ip = ''                -- Use default
    vim.g.mkdp_port = ''                   -- Use random port
    vim.g.mkdp_browser = ''                -- Use system default browser
    vim.g.mkdp_echo_preview_url = 1        -- Echo preview URL in command line
    
    -- Appearance
    vim.g.mkdp_theme = 'dark'              -- Dark theme
    vim.g.mkdp_page_title = '「${name}」'  -- Page title format
    
    -- Custom CSS (leave empty to use defaults)
    vim.g.mkdp_markdown_css = ''
    vim.g.mkdp_highlight_css = ''
    
    -- Preview options
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {}
    }
  end,
  ft = { "markdown" },
  config = function()
    -- Create autocmd to ensure commands are registered when entering markdown buffers
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function()
        -- Source the plugin file to register buffer-local commands
        local plugin_path = vim.fn.stdpath('data') .. '/lazy/markdown-preview.nvim/plugin/mkdp.vim'
        if vim.fn.filereadable(plugin_path) == 1 then
          vim.cmd('source ' .. plugin_path)
        end
      end,
    })
  end,
}
