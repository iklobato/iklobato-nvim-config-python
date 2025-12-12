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

-- Cache sidebar detection per buffer to avoid repeated lookups
local sidebar_cache = {}
local function is_sidebar(bufnr)
  -- Use cached result if available
  if sidebar_cache[bufnr] ~= nil then
    return sidebar_cache[bufnr]
  end
  
  local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local result = false
  for _, sidebar_ft in ipairs(sidebar_filetypes) do
    if ft == sidebar_ft then
      result = true
      break
    end
  end
  
  -- Cache the result
  sidebar_cache[bufnr] = result
  return result
end

-- Clear cache when buffer is deleted
vim.api.nvim_create_autocmd('BufDelete', {
  callback = function(args)
    sidebar_cache[args.buf] = nil
  end,
})

-- Function to equalize windows in current tab only (performance optimization)
local function equalize_windows_current_tab()
  vim.cmd('wincmd =')
end

-- Debouncing for window equalization to prevent rapid-fire updates
local equalize_timer = nil
local function debounced_equalize()
  -- Cancel any pending equalization
  if equalize_timer then
    equalize_timer:stop()
    equalize_timer:close()
  end
  
  -- Schedule new equalization with debounce delay
  equalize_timer = vim.loop.new_timer()
  equalize_timer:start(100, 0, function()
    vim.schedule(function()
      equalize_windows_current_tab()
      if equalize_timer then
        equalize_timer:close()
        equalize_timer = nil
      end
    end)
  end)
end

-- Create autocommand group for window equalization
local eq_group = vim.api.nvim_create_augroup('EqualizeWindowsOnSidebar', { clear = true })

-- Equalize when a sidebar buffer enters a window
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = eq_group,
  callback = function(args)
    if is_sidebar(args.buf) then
      debounced_equalize()
    end
  end,
})

-- Equalize when a sidebar buffer leaves a window (closes)
vim.api.nvim_create_autocmd('BufWinLeave', {
  group = eq_group,
  callback = function(args)
    if is_sidebar(args.buf) then
      debounced_equalize()
    end
  end,
})

-------------------------------------------------------------------------------
-- Line Numbers - Only show in text editor buffers, not in sidebars/plugins
-------------------------------------------------------------------------------

-- Filetypes that should NOT have line numbers (non-editing buffers)
local no_line_numbers_filetypes = {
  'NvimTree',
  'nvim-tree',
  'tsplayground',
  'Trouble',
  'trouble',
  'dapui_scopes',
  'dapui_breakpoints',
  'dapui_stacks',
  'dapui_watches',
  'dapui_console',
  'dap-repl',
  'dbui',
  'dbout',
  'help',
  'qf',
  'quickfix',
  'terminal',
  'TelescopePrompt',
  'TelescopeResults',
  'avante',
}

-- Create autocommand group for line number management
local line_numbers_group = vim.api.nvim_create_augroup('LineNumbersManagement', { clear = true })

-- Disable line numbers for non-editing buffers
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = line_numbers_group,
  callback = function(args)
    local filetype = vim.api.nvim_buf_get_option(args.buf, 'filetype')
    local buftype = vim.api.nvim_buf_get_option(args.buf, 'buftype')
    
    -- Get the window that contains this buffer
    local win_id = vim.fn.bufwinid(args.buf)
    if win_id == -1 then
      -- Buffer not in any window yet, skip
      return
    end
    
    -- Check if this is a non-editing buffer
    local is_no_line_numbers = false
    for _, ft in ipairs(no_line_numbers_filetypes) do
      if filetype == ft then
        is_no_line_numbers = true
        break
      end
    end
    
    -- Also disable for special buffer types (except acwrite which is for editing)
    if buftype ~= '' and buftype ~= 'acwrite' then
      is_no_line_numbers = true
    end
    
    -- Set line numbers accordingly using the window ID
    if is_no_line_numbers then
      vim.api.nvim_win_set_option(win_id, 'number', false)
      vim.api.nvim_win_set_option(win_id, 'relativenumber', false)
    else
      -- Enable line numbers for editing buffers
      vim.api.nvim_win_set_option(win_id, 'number', true)
      vim.api.nvim_win_set_option(win_id, 'relativenumber', false)
    end
  end,
})

-- Also handle when switching windows
vim.api.nvim_create_autocmd('WinEnter', {
  group = line_numbers_group,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
    local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
    
    -- Check if this is a non-editing buffer
    local is_no_line_numbers = false
    for _, ft in ipairs(no_line_numbers_filetypes) do
      if filetype == ft then
        is_no_line_numbers = true
        break
      end
    end
    
    -- Also disable for special buffer types
    if buftype ~= '' and buftype ~= 'acwrite' then
      is_no_line_numbers = true
    end
    
    -- Set line numbers accordingly
    if is_no_line_numbers then
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    else
      -- Enable line numbers for editing buffers
      vim.opt_local.number = true
      vim.opt_local.relativenumber = false
    end
  end,
})

-- Enable line numbers in Telescope preview windows
vim.api.nvim_create_autocmd('User', {
  group = line_numbers_group,
  pattern = 'TelescopePreviewerLoaded',
  callback = function(args)
    -- Enable line numbers in the preview window
    local preview_buf = args.data.bufnr
    if preview_buf then
      vim.schedule(function()
        local win_id = vim.fn.bufwinid(preview_buf)
        if win_id ~= -1 then
          vim.api.nvim_win_set_option(win_id, 'number', true)
          vim.api.nvim_win_set_option(win_id, 'relativenumber', false)
        end
      end)
    end
  end,
})
