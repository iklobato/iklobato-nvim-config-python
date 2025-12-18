---@diagnostic disable: undefined-global
--[[
  Neovim Keymaps Configuration

  This file contains all custom keybindings organized by category.
  Most mappings use <Space> as the leader key.

  STRUCTURE:
  - Basic navigation and operations
  - Development tools (LSP, debugging, git)
  - UI controls (windows, tabs, explorer)
  - Specialized tools (AI, database, REST)

  TIP: Search for section headers (e.g. "-- File Navigation")
  to quickly jump to a specific category.
--]]

-- Basic Configuration
-- Leader key is already set in init.lua, don't set it again here
local keymap = vim.keymap -- Shorter reference to keymap function

-------------------------------------------------------------------------------
-- File and Buffer Operations
-------------------------------------------------------------------------------

-- Save and Quit
keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
keymap.set("n", "<leader>qq", ":q!<CR>", { desc = "Quit without saving" })

-- Buffer Navigation
keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = "Next buffer" })
keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = "Previous buffer" })
keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = "Delete buffer" })

-- Session Management (handled by auto-session plugin)
-- <leader>ss - Search sessions
-- <leader>sd - Delete session

-------------------------------------------------------------------------------
-- Navigation and Movement
-------------------------------------------------------------------------------

-- Function to center cursor both vertically and horizontally
local function center_cursor()
  -- Center vertically (middle of screen height)
  vim.cmd('normal! zz')
  -- Center horizontally (middle of screen width)
  local win_width = vim.api.nvim_win_get_width(0)
  local middle_col = math.floor(win_width / 2)
  local tolerance = 2  -- Allow 2 columns of tolerance
  
  -- Iteratively scroll until cursor is centered (within tolerance)
  for _ = 1, 10 do  -- Max 10 iterations to avoid infinite loop
    local screen_col = vim.fn.wincol()  -- Current screen column of cursor
    local diff = screen_col - middle_col
    
    if math.abs(diff) <= tolerance then
      break  -- Close enough to center
    elseif diff > 0 then
      -- Cursor is to the right of center, scroll right
      vim.cmd('normal! zl')
    else
      -- Cursor is to the left of center, scroll left
      vim.cmd('normal! zh')
    end
  end
end

-- Cursor Centering (for long-distance movements)
keymap.set('n', '<C-d>', '<C-d>zz', { desc = "Page down and center" })
keymap.set('n', '<C-u>', '<C-u>zz', { desc = "Page up and center" })
keymap.set('n', 'n', 'nzz', { desc = "Next search result and center" })
keymap.set('n', 'N', 'Nzz', { desc = "Previous search result and center" })
keymap.set('n', '*', '*zz', { desc = "Search word under cursor and center" })
keymap.set('n', '{', '{zz', { desc = "Previous paragraph and center" })
keymap.set('n', '}', '}zz', { desc = "Next paragraph and center" })

-- Method Navigation
keymap.set('n', ']m', ']mzz', { desc = "Next method and center" })
keymap.set('n', '[m', '[mzz', { desc = "Previous method and center" })

-- Basic movement with centering
-- keymap.set('n', 'h', 'hzz', { desc = "Move left and center" })
-- keymap.set('n', 'j', 'jzz', { desc = "Move down and center" })
-- keymap.set('n', 'k', 'kzz', { desc = "Move up and center" })
-- keymap.set('n', 'l', 'lzz', { desc = "Move right and center" })

-- Arrow keys with centering
-- keymap.set('n', '<Left>', 'hzz', { desc = "Move left and center" })
-- keymap.set('n', '<Down>', 'jzz', { desc = "Move down and center" })
-- keymap.set('n', '<Up>', 'kzz', { desc = "Move up and center" })
-- keymap.set('n', '<Right>', 'lzz', { desc = "Move right and center" })

-- External Navigation
keymap.set("n", "gx", ":!open <c-r><c-a><CR>", { desc = "Open URL under cursor" })

-------------------------------------------------------------------------------
-- Telescope Helper Functions
-------------------------------------------------------------------------------

-- Cache Telescope builtin module for performance (lazy load)
local telescope_builtin = nil
local function get_telescope_builtin()
  if not telescope_builtin then
    telescope_builtin = require('telescope.builtin')
  end
  return telescope_builtin
end

-- Lazy load telescope on first use to avoid startup cost
local function safe_telescope(fn_name, ...)
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin[fn_name] then
    return builtin[fn_name](...)
  else
    vim.notify('Telescope not loaded yet', vim.log.levels.WARN)
  end
end

-------------------------------------------------------------------------------
-- Code Editing and Refactoring
-------------------------------------------------------------------------------

-- LSP Controls
-- Cache Telescope builtin for LSP operations
local function safe_telescope_lsp(fn_name, fallback_fn)
  return function()
    local builtin = get_telescope_builtin()
    if builtin[fn_name] then
      builtin[fn_name]()
    else
      fallback_fn()
    end
  end
end

-- Custom function to go to definition in vertical split
local function goto_definition_vertical_split()
  -- Use LSP definition with custom jump handler
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, config)
    if err then
      vim.notify('Error getting definition: ' .. err.message, vim.log.levels.ERROR)
      return
    end
    
    if not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.INFO)
      return
    end
    
    -- Open vertical split first
    vim.cmd('vsplit')
    
    -- Jump to the location (if multiple, use first one)
    local location = result[1]
    if location.uri then
      vim.lsp.util.jump_to_location(location, ctx.client_id)
      vim.cmd('normal! zz') -- Center the cursor
    elseif location.targetUri then
      -- Handle LocationLink format
      vim.lsp.util.jump_to_location({
        uri = location.targetUri,
        range = location.targetRange
      }, ctx.client_id)
      vim.cmd('normal! zz') -- Center the cursor
    end
  end)
end

keymap.set('n', '<leader>gd', goto_definition_vertical_split, { desc = "Go to definition" })
keymap.set('n', '<leader>gD', safe_telescope_lsp('lsp_declarations', vim.lsp.buf.declaration), { desc = "Go to declaration" })
keymap.set('n', '<leader>gi', safe_telescope_lsp('lsp_implementations', vim.lsp.buf.implementation), { desc = "Go to implementation" })
keymap.set('n', '<leader>gr', safe_telescope_lsp('lsp_references', vim.lsp.buf.references), { desc = "Find references" })
keymap.set('n', '<leader>gt', safe_telescope_lsp('lsp_type_definitions', vim.lsp.buf.type_definition), { desc = "Go to type definition" })
keymap.set('n', '<leader>gg', vim.lsp.buf.hover, { desc = "Show hover info" })
keymap.set('n', '<leader>gs', vim.lsp.buf.signature_help, { desc = "Show signature help" })
keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap.set('n', '<leader>ga', safe_telescope_lsp('lsp_code_actions', vim.lsp.buf.code_action), { desc = "Code actions" })
-- Format keybinding is handled by conform.nvim (<leader>f)

-- Diagnostics
keymap.set('n', '<leader>e', function()
  local builtin = get_telescope_builtin()
  if builtin.diagnostics then
    builtin.diagnostics()
  else
    vim.diagnostic.open_float()
  end
end, { desc = "Show diagnostics" })
keymap.set('n', '<leader>E', function()
  vim.diagnostic.open_float({ focus = true })
end, { desc = "Show diagnostic (focused)" })
keymap.set('n', '<leader>gn', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set('n', '<leader>gp', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set('n', '<leader>q', function()
  local builtin = get_telescope_builtin()
  if builtin.diagnostics then
    builtin.diagnostics()
  else
    vim.diagnostic.setloclist({ wrap = true })
  end
end, { desc = "Show diagnostics" })

-- Code Symbols
keymap.set('n', '<leader>tr', vim.lsp.buf.document_symbol, { desc = "Document symbols" })

-- Code Folding
keymap.set('n', '<leader>za', 'za', { desc = "Toggle fold" })
keymap.set('n', '<leader>zA', 'zA', { desc = "Toggle all folds" })
keymap.set('n', '<leader>zo', 'zo', { desc = "Open fold" })
keymap.set('n', '<leader>zc', 'zc', { desc = "Close fold" })
keymap.set('n', '<leader>zR', 'zR', { desc = "Open all folds" })
keymap.set('n', '<leader>zM', 'zM', { desc = "Close all folds" })

-- Search and Replace
keymap.set("n", "<leader>S", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word under cursor" })
keymap.set("v", "<leader>S", "y:%s/<C-r>\"/<C-r>\"/gI<Left><Left><Left>", { desc = "Replace visual selection" })

-------------------------------------------------------------------------------
-- UI Controls
-------------------------------------------------------------------------------

-- File Explorer (Nvim-tree) - lazy loaded
keymap.set('n', '<leader>ee', function()
  require('lazy').load({ plugins = { 'nvim-tree.lua' } })
  vim.schedule(function() require('nvim-tree.api').tree.toggle() end)
end, { desc = "Toggle file explorer" })
keymap.set('n', '<leader>ef', function()
  require('lazy').load({ plugins = { 'nvim-tree.lua' } })
  vim.schedule(function() require('nvim-tree.api').tree.find_file({ open = true, focus = true }) end)
end, { desc = "Find file in explorer" })
keymap.set('n', '<leader>er', function()
  require('lazy').load({ plugins = { 'nvim-tree.lua' } })
  vim.schedule(function() require('nvim-tree.api').tree.focus() end)
end, { desc = "Focus file explorer" })

-- Split Windows
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close split" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal" })
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", { desc = "Toggle maximize" })
keymap.set("n", "<leader>sw", "<C-w>T", { desc = "Move split to tab" })
keymap.set("n", "<leader>sk", "<C-w>+", { desc = "Increase height" })
keymap.set("n", "<leader>sj", "<C-w>-", { desc = "Decrease height" })
keymap.set("n", "<leader>sl", "<C-w>>", { desc = "Increase width" })

-- Tab Management
keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "New tab" })
keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })
keymap.set("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })
keymap.set("n", "<leader>tb", ":tabp<CR>", { desc = "Previous tab" })
keymap.set("n", "<leader>tp", ":tabp<CR>", { desc = "Previous tab" })

-- Quick tab navigation with Alt/Option + number (1-9)
for i = 1, 9 do
  keymap.set("n", string.format("<A-%d>", i), string.format(":tabn %d<CR>", i), { desc = "Go to tab " .. i })
end

-- Quickfix List
keymap.set("n", "<leader>qo", ":copen<CR>", { desc = "Open quickfix" })
keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix" })
keymap.set("n", "<leader>qn", ":cnext<CR>", { desc = "Next quickfix item" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { desc = "Previous quickfix item" })
keymap.set("n", "<leader>qf", ":cfirst<CR>", { desc = "First quickfix item" })
keymap.set("n", "<leader>ql", ":clast<CR>", { desc = "Last quickfix item" })

-- UI Toggles
keymap.set('n', '<leader>ti', ':IBLToggle<CR>', { desc = "Toggle indent lines" })
keymap.set('n', '<leader>gb', ":GitBlameToggle<CR>", { desc = "Toggle git blame" })

-------------------------------------------------------------------------------
-- Fuzzy Finding (Telescope)
-------------------------------------------------------------------------------

-- Cache current working directory (recalculate only when directory changes)
local cached_cwd = nil
local last_cwd_check = 0
local function get_cached_cwd()
  local current_time = vim.loop.now()
  -- Recalculate cwd if more than 1 second has passed or if it's not cached
  if not cached_cwd or (current_time - last_cwd_check) > 1000 then
    cached_cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':p'):gsub('/$', '')
    last_cwd_check = current_time
  end
  return cached_cwd
end

-- Clear cache when directory changes
vim.api.nvim_create_autocmd('DirChanged', {
  callback = function()
    cached_cwd = nil
  end,
})

keymap.set('n', '<leader>ff', function()
  local builtin = get_telescope_builtin()
  builtin.find_files({
    cwd = get_cached_cwd(),
    hidden = true,
    no_ignore = false,  -- Respect .gitignore
    follow = true,
  })
end, { desc = "Find files" })

keymap.set('n', '<leader>fg', function()
  local builtin = get_telescope_builtin()
  builtin.live_grep({
    cwd = get_cached_cwd(),
  })
end, { desc = "Find text" })
keymap.set('n', '<leader>fb', function() get_telescope_builtin().buffers() end, { desc = "Find buffers" })
keymap.set('n', '<leader>fh', function() get_telescope_builtin().help_tags() end, { desc = "Find help" })
keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', { desc = "Find recent files" })
keymap.set('n', '<leader>fs', function() get_telescope_builtin().current_buffer_fuzzy_find() end, { desc = "Find in buffer" })
keymap.set('n', '<leader>fo', function() get_telescope_builtin().lsp_document_symbols() end, { desc = "Find symbols" })
keymap.set('n', '<leader>fi', function() get_telescope_builtin().lsp_incoming_calls() end, { desc = "Find incoming calls" })
keymap.set('n', '<leader>fm', function() get_telescope_builtin().treesitter({default_text=":method:"}) end, { desc = "Find methods" })

-------------------------------------------------------------------------------
-- Debugging (DAP)
-------------------------------------------------------------------------------

-- Breakpoints
keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "Toggle breakpoint" })
keymap.set("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", { desc = "Conditional breakpoint" })
keymap.set("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>", { desc = "Logpoint" })
keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>", { desc = "Clear breakpoints" })
keymap.set("n", "<leader>ba", '<cmd>Telescope dap list_breakpoints<cr>', { desc = "List breakpoints" })

-- Debug Session Control
keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", { desc = "Continue/Start debugging" })
keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", { desc = "Step over" })
keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", { desc = "Step into" })
keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>", { desc = "Step out" })
keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", { desc = "Run last debug config" })
keymap.set("n", "<leader>dt", function() require('dap').terminate(); require('dapui').close(); end, { desc = "Terminate debug session" })
keymap.set("n", '<leader>dd', function() require('dap').disconnect(); require('dapui').close(); end, { desc = "Disconnect debugger" })

-- Debug Info and UI
keymap.set("n", '<leader>di', function() require "dap.ui.widgets".hover() end, { desc = "Variable information" })
keymap.set("n", '<leader>d?', function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end, { desc = "Show scopes" })
keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", { desc = "Toggle REPL" })
keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>', { desc = "List frames" })
keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>', { desc = "List commands" })
keymap.set("n", '<leader>de', function() require('telescope.builtin').diagnostics({default_text=":E:"}) end, { desc = "List diagnostics" })

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- AI Assistant (Avante AI)
-------------------------------------------------------------------------------

-- Avante AI Keybindings
keymap.set({ 'n', 'v' }, '<leader>aa', function() require('avante.api').ask() end, { desc = "Show sidebar (ask AI)" })
keymap.set('n', '<leader>at', function() require('avante.api').toggle() end, { desc = "Toggle sidebar" })
keymap.set('n', '<leader>ar', function() require('avante.api').refresh() end, { desc = "Refresh sidebar" })
keymap.set('n', '<leader>af', function() require('avante.api').focus() end, { desc = "Switch sidebar focus" })
keymap.set({ 'n', 'v' }, '<leader>ae', function() require('avante.api').edit() end, { desc = "Edit selected blocks" })
keymap.set('n', '<leader>an', function() require('avante').build() end, { desc = "Build/Compile avante" })
keymap.set('n', '<leader>a?', function() require('avante.api').switch_provider() end, { desc = "Switch AI provider" })

-------------------------------------------------------------------------------
-- Terminal
-------------------------------------------------------------------------------

keymap.set('n', '<leader>tt', ':terminal<CR>', { desc = "Open terminal" })
keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = "Exit terminal mode" })

-------------------------------------------------------------------------------
-- Database Operations (vim-dadbod)
-------------------------------------------------------------------------------

-- Cache DBUI state to avoid expensive buffer iteration
local dbui_state_cache = nil
local dbui_cache_time = 0
local DBUI_CACHE_TTL = 2000 -- Cache for 2 seconds

local function is_dbui_open()
  local current_time = vim.loop.now()
  -- Use cached result if still valid
  if dbui_state_cache ~= nil and (current_time - dbui_cache_time) < DBUI_CACHE_TTL then
    return dbui_state_cache
  end
  
  -- Only check visible windows (much faster than checking all buffers)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
    if filetype == "dbui" then
      dbui_state_cache = true
      dbui_cache_time = current_time
      return true
    end
  end
  
  dbui_state_cache = false
  dbui_cache_time = current_time
  return false
end

-- Clear cache when DBUI buffers are created/destroyed
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufWinLeave' }, {
  pattern = '*',
  callback = function(args)
    local filetype = vim.api.nvim_buf_get_option(args.buf, 'filetype')
    if filetype == "dbui" then
      dbui_state_cache = nil
    end
  end,
})

keymap.set('n', '<leader>db', function()
  local dbui_open = is_dbui_open()
  
  -- Toggle the state
  if dbui_open then
    vim.g.db_ui_should_be_open = false
    vim.cmd('DBUIToggle')
  else
    vim.g.db_ui_should_be_open = true
    vim.cmd('DBUI')
  end
  
  -- Invalidate cache after toggle
  dbui_state_cache = nil
end, { desc = "Toggle DB UI" })
keymap.set('n', '<leader>dq', '<cmd>DBUIExecuteQuery<CR>', { desc = "Execute query" })
keymap.set('v', '<leader>dq', ':DBUIExecuteQuery<CR>', { desc = "Execute selected query" })

-------------------------------------------------------------------------------
-- REST Client Operations
-------------------------------------------------------------------------------

-- REST Client keymaps - only work in HTTP/REST files
keymap.set("n", "<leader>rg", "<Plug>VrcRequestGet", { desc = "Execute GET request" })
keymap.set("n", "<leader>rp", "<Plug>VrcRequestPost", { desc = "Execute POST request" })
keymap.set("n", "<leader>ru", "<Plug>VrcRequestPut", { desc = "Execute PUT request" })
keymap.set("n", "<leader>rd", "<Plug>VrcRequestDelete", { desc = "Execute DELETE request" })
keymap.set("n", "<leader>xr", function()
  -- Ensure plugin is loaded before calling function
  if vim.fn.exists('*VrcQuery') == 1 then
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
          vim.notify('vim-rest-console not loaded. Open an HTTP file or run :Lazy load vim-rest-console', vim.log.levels.WARN)
        end
      end, 100)
    else
      vim.notify('vim-rest-console not loaded. Please open an HTTP/REST file first.', vim.log.levels.WARN)
    end
  end
end, { desc = "Run REST query" })
keymap.set("n", "<leader>xj", function()
  if vim.fn.exists('*VrcJson') == 1 then
    vim.cmd('call VrcJson()')
  else
    vim.notify('vim-rest-console not loaded. Please open an HTTP/REST file first.', vim.log.levels.WARN)
  end
end, { desc = "Format as JSON" })

-------------------------------------------------------------------------------
-- Treesitter Integration
-------------------------------------------------------------------------------

keymap.set('n', '<C-Space>', ':TSHighlightCapturesUnderCursor<CR>', { desc = "Show highlight groups" })
keymap.set('n', '<leader>tp', ':TSPlaygroundToggle<CR>', { desc = "Toggle Treesitter playground" })

-------------------------------------------------------------------------------
-- Command Aliases
-------------------------------------------------------------------------------

vim.cmd([[cab av Avante]])

