---@diagnostic disable: undefined-global
-- Autocommands go here
-- Open nvim-tree when opening a directory
-- Note: This runs after auto-session restoration, so it won't interfere
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function(data)
    -- Wait a bit to let auto-session restore first
    vim.defer_fn(function()
      -- Check if we opened a directory (e.g., `nvim .` or `nvim /path/to/dir`)
      local directory = vim.fn.isdirectory(data.file) == 1
      -- Also check if no file was specified (empty buffer means we opened a directory)
      local bufname = vim.fn.bufname()
      local no_file = bufname == "" or bufname == nil
      -- Only open nvim-tree if no session was restored (no tabs/windows exist)
      local tab_pages = vim.api.nvim_list_tabpages()
      local tab_count = #tab_pages
      local should_open_tree = (directory or no_file) and tab_count <= 1
      if should_open_tree then
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          -- Check if nvim-tree is already open
          local tree_open = false
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name:match("NvimTree") then
              tree_open = true
              break
            end
          end
          if not tree_open then
            api.tree.open()
          end
        end
      end
    end, 500) -- Delay to let auto-session restore first
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
-------------------------------------------------------------------------------
-- Auto-reveal file in nvim-tree when opening/switching files
-------------------------------------------------------------------------------
-- Function to check if nvim-tree is open
local function is_nvim_tree_open()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match("NvimTree") then
      -- Check if the buffer is visible in a window
      local win_id = vim.fn.bufwinid(buf)
      if win_id ~= -1 then
        return true
      end
    end
  end
  return false
end
-- Auto-reveal and highlight current file in nvim-tree
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  callback = function(args)
    -- Skip if this is a special buffer (no file, terminal, etc.)
    local buftype = vim.api.nvim_buf_get_option(args.buf, 'buftype')
    if buftype ~= '' then
      return
    end
    -- Skip if this is nvim-tree itself
    local buf_name = vim.api.nvim_buf_get_name(args.buf)
    if buf_name:match("NvimTree") then
      return
    end
    -- Skip if buffer has no file path
    if buf_name == '' or buf_name == nil then
      return
    end
    -- Only reveal if nvim-tree is open
    if is_nvim_tree_open() then
      -- Load plugin if needed and reveal/highlight file
      local function reveal_file()
        local ok, api = pcall(require, 'nvim-tree.api')
        if ok then
          -- Use find_file to reveal and highlight the file in the tree
          -- This will scroll to the file and highlight it
          api.tree.find_file({
            open = false,      -- Don't open the file (already open in buffer)
            focus = false,     -- Don't focus the tree window (stay in current buffer)
            update_root = false -- Don't change the root directory
          })
        else
          -- Plugin not loaded yet, load it first then reveal
          require('lazy').load({ plugins = { 'nvim-tree.lua' } })
          vim.defer_fn(function()
            local tree_api = require('nvim-tree.api')
            tree_api.tree.find_file({
              open = false,
              focus = false,
              update_root = false
            })
          end, 100)
        end
      end
      -- Small delay to ensure nvim-tree is ready
      vim.defer_fn(reveal_file, 50)
    end
  end,
})
-------------------------------------------------------------------------------
-- HTTP Client Setup
-------------------------------------------------------------------------------
-- Set up HTTP filetype detection
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.http", "*.rest" },
  callback = function()
    vim.bo.filetype = "http"
  end,
})
-- Create user command for HTTP help
vim.api.nvim_create_user_command('HttpFormatHelp', function()
  local help_text = {
    'REST Client format (rest-nvim):',
    '',
    'GET https://api.example.com/users',
    '',
    '###',
    'POST https://api.example.com/users',
    'Content-Type: application/json',
    '',
    '{',
    '  "name": "John Doe",',
    '  "email": "john@example.com"',
    '}',
    '',
    '###',
    'PUT https://api.example.com/users/1',
    'Authorization: Bearer {{API_TOKEN}}',
    'Content-Type: application/json',
    '',
    '{',
    '  "name": "Jane Doe"',
    '}',
    '',
    'Environment Variables:',
    '- Create .env file: API_BASE_URL=https://api.example.com',
    '- Use variables: {{API_BASE_URL}}/users',
    '- System env vars also work',
    '',
    'Keymaps:',
    '- <leader>rr - Run request under cursor',
    '- <leader>rp - Preview request',
    '- <leader>rl - Run last request',
    '',
    'Features:',
    '- Place cursor on request line',
    '- Press <leader>rr to execute',
    '- Response opens in horizontal split',
    '- Variables are automatically replaced',
  }
  vim.notify(table.concat(help_text, '\n'), vim.log.levels.INFO)
end, { desc = 'Show HTTP format help' })
