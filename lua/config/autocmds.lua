---@diagnostic disable: undefined-global
-- Autocommands go here

-- Open nvim-tree when opening a directory
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function(data)
    -- Check if we opened a directory (e.g., `nvim .` or `nvim /path/to/dir`)
    local directory = vim.fn.isdirectory(data.file) == 1

    -- Also check if no file was specified (empty buffer means we opened a directory)
    local bufname = vim.fn.bufname()
    local no_file = bufname == "" or bufname == nil

    if directory or no_file then
      -- Open nvim-tree after a short delay to ensure everything is loaded
      vim.defer_fn(function()
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          api.tree.open()
        end
      end, 0)
    end
  end,
})

-------------------------------------------------------------------------------
-- Auto-equalize windows when sidebars open/close
-------------------------------------------------------------------------------

-- Function to equalize windows in all tabs
local function equalize_windows_all_tabs()
  -- Save current tab
  local current_tab = vim.fn.tabpagenr()

  -- Iterate through all tabs
  for tab = 1, vim.fn.tabpagenr('$') do
    -- Switch to tab
    vim.cmd('tabnext ' .. tab)
    -- Equalize windows in this tab
    vim.cmd('wincmd =')
  end

  -- Return to original tab
  vim.cmd('tabnext ' .. current_tab)
end

-- List of filetypes that are considered sidebars
local sidebar_filetypes = {
  'NvimTree',
  'nvim-tree',
  'avante',
  'dapui_scopes',
  'dapui_breakpoints',
  'dapui_stacks',
  'dapui_watches',
  'dapui_console',
  'dap-repl',
  'dbui',
  'dbout',
}

-- Check if a buffer is a sidebar
local function is_sidebar(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  for _, sidebar_ft in ipairs(sidebar_filetypes) do
    if ft == sidebar_ft then
      return true
    end
  end
  return false
end

-- Create autocommand group for window equalization
local eq_group = vim.api.nvim_create_augroup('EqualizeWindowsOnSidebar', { clear = true })

-- Equalize when a sidebar buffer enters a window
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = eq_group,
  callback = function(args)
    if is_sidebar(args.buf) then
      -- Defer the equalization to ensure the window is fully rendered
      vim.defer_fn(function()
        equalize_windows_all_tabs()
      end, 50)
    end
  end,
})

-- Equalize when a sidebar buffer leaves a window (closes)
vim.api.nvim_create_autocmd('BufWinLeave', {
  group = eq_group,
  callback = function(args)
    if is_sidebar(args.buf) then
      -- Defer the equalization to ensure the window is fully closed
      vim.defer_fn(function()
        equalize_windows_all_tabs()
      end, 50)
    end
  end,
})
