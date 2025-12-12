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
