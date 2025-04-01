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

-- Session Management
keymap.set('n', '<leader>ss', function() require('auto-session.session-lens').search_session() end, { desc = "Search sessions" })
keymap.set('n', '<leader>sd', function() require('auto-session').DeleteSession() end, { desc = "Delete session" })

-------------------------------------------------------------------------------
-- Navigation and Movement
-------------------------------------------------------------------------------

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

-- External Navigation
keymap.set("n", "gx", ":!open <c-r><c-a><CR>", { desc = "Open URL under cursor" })

-------------------------------------------------------------------------------
-- Code Editing and Refactoring
-------------------------------------------------------------------------------

-- LSP Controls
keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { desc = "Go to implementation" })
keymap.set('n', '<leader>gr', vim.lsp.buf.references, { desc = "Find references" })
keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition, { desc = "Go to type definition" })
keymap.set('n', '<leader>gg', vim.lsp.buf.hover, { desc = "Show hover info" })
keymap.set('n', '<leader>gs', vim.lsp.buf.signature_help, { desc = "Show signature help" })
keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap.set('n', '<leader>ga', vim.lsp.buf.code_action, { desc = "Code actions" })
keymap.set('n', '<leader>gf', function() vim.lsp.buf.format({async = true}) end, { desc = "Format code" })
keymap.set('v', '<leader>gf', function() vim.lsp.buf.format({async = true}) end, { desc = "Format selected code" })

-- Diagnostics
keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Show diagnostic" })
keymap.set('n', '<leader>gl', vim.diagnostic.open_float, { desc = "Show diagnostic" })
keymap.set('n', '<leader>gn', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set('n', '<leader>gp', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set('n', '<leader>q', function() vim.diagnostic.setloclist({ wrap = true }) end, { desc = "Diagnostics to location list" })

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

keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find files" })
keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = "Find text" })
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

keymap.set('n', '<leader>db', '<cmd>DBUIToggle<CR>', { desc = "Toggle DB UI" })
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

