vim.g.mapleader = " "
local keymap = vim.keymap

-- Auto-session
-- Manage persistence of editor sessions
keymap.set('n', '<leader>sd', function() require('auto-session').DeleteSession() end) -- Delete current session
keymap.set('n', '<leader>ss', function() require('auto-session.session-lens').search_session() end) -- Search saved sessions

-- Buffer Management
-- Handle multiple open files in memory
keymap.set('n', '<leader>bd', ':bdelete<CR>') -- Delete current buffer
keymap.set('n', '<leader>bn', ':bnext<CR>') -- Go to next buffer
keymap.set('n', '<leader>bp', ':bprevious<CR>') -- Go to previous buffer

-- Code Folding
-- Control code visibility through folding
keymap.set('n', '<leader>zA', 'zA') -- Toggle all nested folds
keymap.set('n', '<leader>za', 'za') -- Toggle current fold
keymap.set('n', '<leader>zc', 'zc') -- Close current fold
keymap.set('n', '<leader>zM', 'zM') -- Close all folds
keymap.set('n', '<leader>zo', 'zo') -- Open current fold
keymap.set('n', '<leader>zR', 'zR') -- Open all folds

-- CodeCompanion
-- AI coding assistant integration
keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Open CodeCompanion Actions" }) -- Show AI actions
keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" }) -- Toggle AI chat
keymap.set("n", "<leader>al", "", {
  callback = function()
    require("codecompanion").prompt("lsp")
  end,
  desc = "Explain LSP error"
}) -- Get LSP error explanation
keymap.set("n", "<leader>am", "", {
  callback = function()
    require("codecompanion").prompt("commit")
  end,
  desc = "Generate commit message"
}) -- Generate git commit message
keymap.set("v", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Open CodeCompanion Actions" }) -- Show AI actions for selection
keymap.set("v", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" }) -- Toggle AI chat in visual mode
keymap.set("v", "<leader>ae", "", {
  callback = function()
    require("codecompanion").prompt("explain")
  end,
  desc = "Explain code"
}) -- Get explanation of selected code
keymap.set("v", "<leader>af", "", {
  callback = function()
    require("codecompanion").prompt("fix")
  end,
  desc = "Fix code"
}) -- Get fixes for selected code
keymap.set("v", "<leader>as", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to chat" }) -- Add selection to AI chat
keymap.set("v", "<leader>at", "", {
  callback = function()
    require("codecompanion").prompt("tests")
  end,
  desc = "Generate tests"
}) -- Generate tests for selected code

-- Cursor Centering
-- Keep cursor in screen center during navigation
keymap.set('n', '*', '*zz', { desc = 'Search word under cursor and center' }) -- Center after word search
keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Page down and center' }) -- Center after page down
keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Page up and center' }) -- Center after page up
keymap.set('n', 'N', 'Nzz', { desc = 'Previous search result and center' }) -- Center after previous search
keymap.set('n', 'n', 'nzz', { desc = 'Next search result and center' }) -- Center after next search
keymap.set('n', '{', '{zz', { desc = 'Previous paragraph and center' }) -- Center after previous paragraph
keymap.set('n', '}', '}zz', { desc = 'Next paragraph and center' }) -- Center after next paragraph

-- Database Operations
-- Interface with databases through vim-dadbod
keymap.set('n', '<leader>db', '<cmd>DBUIToggle<CR>', { desc = 'Toggle DB UI' }) -- Show database interface
keymap.set('n', '<leader>dq', '<cmd>DBUIExecuteQuery<CR>', { desc = 'Execute query' }) -- Run SQL query
keymap.set('v', '<leader>dq', ':DBUIExecuteQuery<CR>', { desc = 'Execute selected query' }) -- Run selected SQL

-- Debugging
-- Debug adapter protocol controls
keymap.set("n", "<leader>ba", '<cmd>Telescope dap list_breakpoints<cr>') -- List all breakpoints
keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>") -- Toggle breakpoint
keymap.set("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>") -- Set conditional breakpoint
keymap.set("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>") -- Set logpoint
keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>") -- Clear all breakpoints
keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>") -- Continue execution
keymap.set("n", '<leader>dd', function() require('dap').disconnect(); require('dapui').close(); end) -- Disconnect debugger
keymap.set("n", '<leader>de', function() require('telescope.builtin').diagnostics({default_text=":E:"}) end) -- Show diagnostics
keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>') -- Show stack frames
keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>') -- Show debug commands
keymap.set("n", '<leader>di', function() require "dap.ui.widgets".hover() end) -- Show variable value
keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>") -- Step over
keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>") -- Step into
keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>") -- Run last debug configuration
keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>") -- Step out
keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>") -- Toggle debug REPL
keymap.set("n", '<leader>dt', function() require('dap').terminate(); require('dapui').close(); end) -- Terminate debug session
keymap.set("n", '<leader>d?', function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end) -- Show scopes

-- Essential Commands
-- Basic editor operations
keymap.set("n", "gx", ":!open <c-r><c-a><CR>") -- Open URL under cursor
keymap.set("n", "<leader>qq", ":q!<CR>") -- Quit without saving
keymap.set("n", "<leader>wq", ":wq<CR>") -- Save and quit
keymap.set("n", "<leader>ww", ":w<CR>") -- Save file

-- Git Integration
-- Source control features
keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>") -- Toggle git blame overlay

-- Indent Visualization
-- Control indent guide display
keymap.set('n', '<leader>ti', ':IBLToggle<CR>') -- Toggle indent guidelines

-- LSP Features
-- Language server protocol integration
keymap.set('n', '<leader>e', vim.diagnostic.open_float) -- Show diagnostic float
keymap.set('n', '<leader>ga', vim.lsp.buf.code_action) -- Show code actions
keymap.set('n', '<leader>gD', vim.lsp.buf.declaration) -- Go to declaration
keymap.set('n', '<leader>gd', vim.lsp.buf.definition) -- Go to definition
keymap.set('n', '<leader>gf', function() vim.lsp.buf.format({async = true}) end) -- Format code
keymap.set('n', '<leader>gg', vim.lsp.buf.hover) -- Show hover information
keymap.set('n', '<leader>gi', vim.lsp.buf.implementation) -- Go to implementation
keymap.set('n', '<leader>gl', vim.diagnostic.open_float) -- Show line diagnostics
keymap.set('n', '<leader>gn', vim.diagnostic.goto_next) -- Next diagnostic
keymap.set('n', '<leader>gp', vim.diagnostic.goto_prev) -- Previous diagnostic
keymap.set('n', '<leader>gr', vim.lsp.buf.references) -- Find references
keymap.set('n', '<leader>gs', vim.lsp.buf.signature_help) -- Show signature help
keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition) -- Go to type definition
keymap.set('n', '<leader>q', vim.diagnostic.setloclist) -- Set location list
keymap.set('n', '<leader>rr', vim.lsp.buf.rename) -- Rename symbol
keymap.set('n', '<leader>tr', vim.lsp.buf.document_symbol) -- Show document symbols
keymap.set('n', '[d', vim.diagnostic.goto_prev) -- Previous diagnostic
keymap.set('n', ']d', vim.diagnostic.goto_next) -- Next diagnostic
keymap.set('v', '<leader>gf', function() vim.lsp.buf.format({async = true}) end) -- Format selected code

-- Method Navigation
-- Jump between methods/functions
keymap.set('n', ']m', ']mzz') -- Next method and center
keymap.set('n', '[m', '[mzz') -- Previous method and center

-- File Explorer
-- NvimTree file browser controls
keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>") -- Toggle file explorer
keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>") -- Find current file in explorer
keymap.set("n", "<leader>er", ":NvimTreeFocus<CR>") -- Focus file explorer

-- Quickfix Navigation
-- Manage compiler/linter output list
keymap.set("n", "<leader>qc", ":cclose<CR>") -- Close quickfix window
keymap.set("n", "<leader>qf", ":cfirst<CR>") -- First quickfix item
keymap.set("n", "<leader>ql", ":clast<CR>") -- Last quickfix item
keymap.set("n", "<leader>qn", ":cnext<CR>") -- Next quickfix item
keymap.set("n", "<leader>qo", ":copen<CR>") -- Open quickfix window
keymap.set("n", "<leader>qp", ":cprev<CR>") -- Previous quickfix item

-- REST Client
-- HTTP request handling
keymap.set("n", "<leader>rd", "<Plug>VrcRequestDelete", { desc = 'Execute DELETE request' }) -- Send DELETE request
keymap.set("n", "<leader>rp", "<Plug>VrcRequestPost", { desc = 'Execute POST request' }) -- Send POST request
keymap.set("n", "<leader>rr", "<Plug>VrcRequestGet", { desc = 'Execute GET request' }) -- Send GET request
keymap.set("n", "<leader>ru", "<Plug>VrcRequestPut", { desc = 'Execute PUT request' }) -- Send PUT request
keymap.set("n", "<leader>xj", ":call VrcJson()<CR>") -- Format as JSON
keymap.set("n", "<leader>xr", ":call VrcQuery()<CR>") -- Execute REST query

-- Search and Replace
-- Global text manipulation
keymap.set("n", "<leader>S", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>") -- Replace word under cursor

-- Window Splits
-- Manage editor window layout
keymap.set("n", "<leader>se", "<C-w>=") -- Make splits equal size
keymap.set("n", "<leader>sh", "<C-w>s") -- Split horizontal
keymap.set("n", "<leader>sj", "<C-w>-") -- Decrease height
keymap.set("n", "<leader>sk", "<C-w>+") -- Increase height
keymap.set("n", "<leader>sl", "<C-w>>") -- Increase width
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- Toggle maximize
keymap.set("n", "<leader>sv", "<C-w>v") -- Split vertical
keymap.set("n", "<leader>sx", ":close<CR>") -- Close split
keymap.set("n", "<leader>st", "<C-w>T") -- Move to new tab

-- Tab Management
-- Handle editor tabs
keymap.set("n", "<leader>tn", ":tabn<CR>") -- Next tab
keymap.set("n", "<leader>to", ":tabnew<CR>") -- Open new tab
keymap.set("n", "<leader>tp", ":tabp<CR>") -- Previous tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- Close tab

-- Fuzzy Finding
-- Telescope search functionality
keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, {}) -- Find buffers
keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {}) -- Find files
keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {}) -- Find text
keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, {}) -- Find help
keymap.set('n', '<leader>fi', require('telescope.builtin').lsp_incoming_calls, {}) -- Find incoming calls
keymap.set('n', '<leader>fm', function() require('telescope.builtin').treesitter({default_text=":method:"}) end) -- Find methods
keymap.set('n', '<leader>fo', require('telescope.builtin').lsp_document_symbols, {}) -- Find symbols
keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', {}) -- Find recent files
keymap.set('n', '<leader>fs', require('telescope.builtin').current_buffer_fuzzy_find, {}) -- Find in buffer

-- Terminal Usage
-- Built-in terminal controls
keymap.set('n', '<leader>tt', ':terminal<CR>') -- Open terminal
keymap.set('t', '<Esc>', '<C-\\><C-n>') -- Exit terminal mode

-- Treesitter 
-- Syntax tree operations
keymap.set('n', '<C-Space>', ':TSHighlightCapturesUnderCursor<CR>') -- Show syntax group
keymap.set('n', '<leader>tp', ':TSPlaygroundToggle<CR>') -- Toggle syntax tree view

-- Command Aliases
-- Short command names
vim.cmd([[cab cc CodeCompanion]]) -- Alias for CodeCompanion
