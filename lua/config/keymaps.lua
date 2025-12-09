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

-- Basic movement with full centering (vertical and horizontal)
keymap.set('n', 'h', function()
  vim.cmd('normal! h')
  center_cursor()
end, { desc = "Move left and center", noremap = true })
keymap.set('n', 'j', function()
  vim.cmd('normal! j')
  center_cursor()
end, { desc = "Move down and center", noremap = true })
keymap.set('n', 'k', function()
  vim.cmd('normal! k')
  center_cursor()
end, { desc = "Move up and center", noremap = true })
keymap.set('n', 'l', function()
  vim.cmd('normal! l')
  center_cursor()
end, { desc = "Move right and center", noremap = true })

-- Arrow keys with full centering (vertical and horizontal)
keymap.set('n', '<Left>', function()
  vim.cmd('normal! h')
  center_cursor()
end, { desc = "Move left and center", noremap = true })
keymap.set('n', '<Down>', function()
  vim.cmd('normal! j')
  center_cursor()
end, { desc = "Move down and center", noremap = true })
keymap.set('n', '<Up>', function()
  vim.cmd('normal! k')
  center_cursor()
end, { desc = "Move up and center", noremap = true })
keymap.set('n', '<Right>', function()
  vim.cmd('normal! l')
  center_cursor()
end, { desc = "Move right and center", noremap = true })

-- External Navigation
keymap.set("n", "gx", ":!open <c-r><c-a><CR>", { desc = "Open URL under cursor" })

-------------------------------------------------------------------------------
-- Code Editing and Refactoring
-------------------------------------------------------------------------------

-- LSP Controls
keymap.set('n', '<leader>gd', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.lsp_definitions then
    builtin.lsp_definitions()
  else
    vim.lsp.buf.definition()
  end
end, { desc = "Go to definition" })
keymap.set('n', '<leader>gD', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.lsp_declarations then
    builtin.lsp_declarations()
  else
    vim.lsp.buf.declaration()
  end
end, { desc = "Go to declaration" })
keymap.set('n', '<leader>gi', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.lsp_implementations then
    builtin.lsp_implementations()
  else
    vim.lsp.buf.implementation()
  end
end, { desc = "Go to implementation" })
keymap.set('n', '<leader>gr', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.lsp_references then
    builtin.lsp_references()
  else
    vim.lsp.buf.references()
  end
end, { desc = "Find references" })
keymap.set('n', '<leader>gt', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.lsp_type_definitions then
    builtin.lsp_type_definitions()
  else
    vim.lsp.buf.type_definition()
  end
end, { desc = "Go to type definition" })
keymap.set('n', '<leader>gg', vim.lsp.buf.hover, { desc = "Show hover info" })
keymap.set('n', '<leader>gs', vim.lsp.buf.signature_help, { desc = "Show signature help" })
keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap.set('n', '<leader>ga', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.lsp_code_actions then
    builtin.lsp_code_actions()
  else
    vim.lsp.buf.code_action()
  end
end, { desc = "Code actions" })
-- Format keybinding is handled by conform.nvim (<leader>f)

-- Diagnostics
keymap.set('n', '<leader>e', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.diagnostics then
    builtin.diagnostics()
  else
    vim.diagnostic.open_float()
  end
end, { desc = "Show diagnostics" })
keymap.set('n', '<leader>gn', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.diagnostics then
    builtin.diagnostics()
  else
    vim.diagnostic.goto_next()
  end
end, { desc = "Show diagnostics" })
keymap.set('n', '<leader>gp', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.diagnostics then
    builtin.diagnostics()
  else
    vim.diagnostic.goto_prev()
  end
end, { desc = "Show diagnostics" })
keymap.set('n', ']d', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.diagnostics then
    builtin.diagnostics()
  else
    vim.diagnostic.goto_next()
  end
end, { desc = "Show diagnostics" })
keymap.set('n', '[d', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.diagnostics then
    builtin.diagnostics()
  else
    vim.diagnostic.goto_prev()
  end
end, { desc = "Show diagnostics" })
keymap.set('n', '<leader>q', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin.diagnostics then
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

-- File Explorer (Nvim-tree)
keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find file in explorer" })
keymap.set("n", "<leader>er", ":NvimTreeFocus<CR>", { desc = "Focus file explorer" })

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

keymap.set('n', '<leader>ff', function()
  -- Get absolute path of current working directory to ensure we're in the right place
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':p')
  -- Remove trailing slash if present
  cwd = cwd:gsub('/$', '')
  
  -- Ensure we're searching in the current directory
  require('telescope.builtin').find_files({
    cwd = cwd,
    hidden = true,
    no_ignore = false,  -- Respect .gitignore (set to true if .gitignore is too restrictive)
    follow = true,
  })
end, { desc = "Find files" })
keymap.set('n', '<leader>fg', function()
  -- Get absolute path of current working directory
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':p')
  -- Remove trailing slash if present
  cwd = cwd:gsub('/$', '')
  
  -- Ensure live grep searches in the current directory
  require('telescope.builtin').live_grep({
    cwd = cwd,
  })
end, { desc = "Find text" })
keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = "Find buffers" })
keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = "Find help" })
keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', { desc = "Find recent files" })
keymap.set('n', '<leader>fs', require('telescope.builtin').current_buffer_fuzzy_find, { desc = "Find in buffer" })
keymap.set('n', '<leader>fo', require('telescope.builtin').lsp_document_symbols, { desc = "Find symbols" })
keymap.set('n', '<leader>fi', require('telescope.builtin').lsp_incoming_calls, { desc = "Find incoming calls" })
keymap.set('n', '<leader>fm', function() require('telescope.builtin').treesitter({default_text=":method:"}) end, { desc = "Find methods" })

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
-- AI Assistant (CodeCompanion)
-------------------------------------------------------------------------------

-- Normal Mode
keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Open CodeCompanion Actions" })
keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
keymap.set("n", "<leader>al", "", {
  callback = function() require("codecompanion").prompt("lsp") end,
  desc = "Explain LSP error"
})
keymap.set("n", "<leader>am", "", {
  callback = function() require("codecompanion").prompt("commit") end,
  desc = "Generate commit message"
})

-- Visual Mode
keymap.set("v", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Open CodeCompanion Actions" })
keymap.set("v", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
keymap.set("v", "<leader>as", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to chat" })
keymap.set("v", "<leader>ae", "", {
  callback = function() require("codecompanion").prompt("explain") end,
  desc = "Explain code"
})
keymap.set("v", "<leader>af", "", {
  callback = function() require("codecompanion").prompt("fix") end,
  desc = "Fix code"
})
keymap.set("v", "<leader>at", "", {
  callback = function() require("codecompanion").prompt("tests") end,
  desc = "Generate tests"
})

-------------------------------------------------------------------------------
-- Terminal
-------------------------------------------------------------------------------

keymap.set('n', '<leader>tt', ':terminal<CR>', { desc = "Open terminal" })
keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = "Exit terminal mode" })

-------------------------------------------------------------------------------
-- Database Operations (vim-dadbod)
-------------------------------------------------------------------------------

keymap.set('n', '<leader>db', function()
  -- Check if DBUI is currently open by looking for the buffer in windows
  local dbui_open = false
  -- First check visible windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
    if buf_name:match("dbui://") or buf_name:match("DBUI") or filetype == "dbui" then
      dbui_open = true
      break
    end
  end
  -- Also check all buffers if not found in windows
  if not dbui_open then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local buf_name = vim.api.nvim_buf_get_name(buf)
      local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
      if buf_name:match("dbui://") or buf_name:match("DBUI") or filetype == "dbui" then
        dbui_open = true
        break
      end
    end
  end
  
  -- Toggle the state
  if dbui_open then
    -- Currently open, so close it
    vim.g.db_ui_should_be_open = false
    vim.cmd('DBUIToggle')
  else
    -- Currently closed, so open it
    vim.g.db_ui_should_be_open = true
    vim.cmd('DBUI')
  end
end, { desc = "Toggle DB UI" })
keymap.set('n', '<leader>dq', '<cmd>DBUIExecuteQuery<CR>', { desc = "Execute query" })
keymap.set('v', '<leader>dq', ':DBUIExecuteQuery<CR>', { desc = "Execute selected query" })

-------------------------------------------------------------------------------
-- REST Client Operations
-------------------------------------------------------------------------------

keymap.set("n", "<leader>rg", "<Plug>VrcRequestGet", { desc = "Execute GET request" })
keymap.set("n", "<leader>rp", "<Plug>VrcRequestPost", { desc = "Execute POST request" })
keymap.set("n", "<leader>ru", "<Plug>VrcRequestPut", { desc = "Execute PUT request" })
keymap.set("n", "<leader>rd", "<Plug>VrcRequestDelete", { desc = "Execute DELETE request" })
keymap.set("n", "<leader>xr", ":call VrcQuery()<CR>", { desc = "Run REST query" })
keymap.set("n", "<leader>xj", ":call VrcJson()<CR>", { desc = "Format as JSON" })

-------------------------------------------------------------------------------
-- Treesitter Integration
-------------------------------------------------------------------------------

keymap.set('n', '<C-Space>', ':TSHighlightCapturesUnderCursor<CR>', { desc = "Show highlight groups" })
keymap.set('n', '<leader>tp', ':TSPlaygroundToggle<CR>', { desc = "Toggle Treesitter playground" })

-------------------------------------------------------------------------------
-- Command Aliases
-------------------------------------------------------------------------------

vim.cmd([[cab cc CodeCompanion]])

