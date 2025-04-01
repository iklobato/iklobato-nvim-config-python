-- Basic Configuration
-- Sets the leader key to space for all custom keymaps
vim.g.mapleader = " "

local keymap = vim.keymap

-- Auto-session Management
-- Provides functionality to manage Neovim sessions
keymap.set('n', '<leader>sd', function() require('auto-session').DeleteSession() end)
keymap.set('n', '<leader>ss', function() require('auto-session.session-lens').search_session() end)

-- Buffer Navigation Controls
-- Quick movement between and management of buffers
keymap.set('n', '<leader>bd', ':bdelete<CR>')
keymap.set('n', '<leader>bn', ':bnext<CR>')
keymap.set('n', '<leader>bp', ':bprevious<CR>')

-- Code Folding Operations
-- Controls for managing code folds
keymap.set('n', '<leader>zA', 'zA')
keymap.set('n', '<leader>za', 'za')
keymap.set('n', '<leader>zc', 'zc')
keymap.set('n', '<leader>zM', 'zM')
keymap.set('n', '<leader>zo', 'zo')
keymap.set('n', '<leader>zR', 'zR')

-- CodeCompanion Integration
-- AI-powered coding assistant features
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
keymap.set("v", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Open CodeCompanion Actions" })
keymap.set("v", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
keymap.set("v", "<leader>ae", "", {
  callback = function() require("codecompanion").prompt("explain") end,
  desc = "Explain code"
})
keymap.set("v", "<leader>af", "", {
  callback = function() require("codecompanion").prompt("fix") end,
  desc = "Fix code"
})
keymap.set("v", "<leader>as", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to chat" })
keymap.set("v", "<leader>at", "", {
  callback = function() require("codecompanion").prompt("tests") end,
  desc = "Generate tests"
})

-- Cursor Centering Functions
-- Keeps cursor centered during navigation
keymap.set('n', '*', '*zz', { desc = 'Search word under cursor and center' })
keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Page down and center' })
keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Page up and center' })
keymap.set('n', 'N', 'Nzz', { desc = 'Previous search result and center' })
keymap.set('n', 'n', 'nzz', { desc = 'Next search result and center' })
keymap.set('n', '{', '{zz', { desc = 'Previous paragraph and center' })
keymap.set('n', '}', '}zz', { desc = 'Next paragraph and center' })
keymap.set('n', 'j', 'jzz', { desc = 'Move down and center' })
keymap.set('n', 'k', 'kzz', { desc = 'Move up and center' })

-- Database Operations (vim-dadbod)
-- Database interface controls
keymap.set('n', '<leader>db', '<cmd>DBUIToggle<CR>', { desc = 'Toggle DB UI' })
keymap.set('n', '<leader>dq', '<cmd>DBUIExecuteQuery<CR>', { desc = 'Execute query' })
keymap.set('v', '<leader>dq', ':DBUIExecuteQuery<CR>', { desc = 'Execute selected query' })

-- Debugging Controls
-- Debug adapter protocol integration
keymap.set("n", "<leader>ba", '<cmd>Telescope dap list_breakpoints<cr>')
keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>")
keymap.set("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>")
keymap.set("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>")
keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>")
keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>")
keymap.set("n", '<leader>dd', function() require('dap').disconnect(); require('dapui').close(); end)
keymap.set("n", '<leader>de', function() require('telescope.builtin').diagnostics({default_text=":E:"}) end)
keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>')
keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>')
keymap.set("n", '<leader>di', function() require "dap.ui.widgets".hover() end)
keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>")
keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>")
keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>")
keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>")
keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>")
keymap.set("n", '<leader>dt', function() require('dap').terminate(); require('dapui').close(); end)
keymap.set("n", '<leader>d?', function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end)

-- General Utility Keymaps
-- Basic editor operations
keymap.set("n", "gx", ":!open <c-r><c-a><CR>", { desc = "Open URL under cursor" })
keymap.set("n", "<leader>qq", ":q!<CR>", { desc = "Quit without saving" })
keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save file" })

-- Git Integration
keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>", { desc = "Toggle git blame" })

-- Indent Visualization
keymap.set('n', '<leader>ti', ':IBLToggle<CR>', { desc = "Toggle indent lines" })

-- LSP (Language Server Protocol) Controls
-- Language server integration
keymap.set('n', '<leader>e', vim.diagnostic.open_float)
keymap.set('n', '<leader>ga', vim.lsp.buf.code_action)
keymap.set('n', '<leader>gD', vim.lsp.buf.declaration)
keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition() end)
keymap.set('n', '<leader>gf', function() vim.lsp.buf.format({async = true}) end)
keymap.set('n', '<leader>gg', vim.lsp.buf.hover)
keymap.set('n', '<leader>gi', vim.lsp.buf.implementation)
keymap.set('n', '<leader>gl', vim.diagnostic.open_float)
keymap.set('n', '<leader>gn', vim.diagnostic.goto_next)
keymap.set('n', '<leader>gp', vim.diagnostic.goto_prev)
keymap.set('n', '<leader>gr', vim.lsp.buf.references)
keymap.set('n', '<leader>gs', vim.lsp.buf.signature_help)
keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition)
keymap.set('n', '<leader>q', function()
    vim.diagnostic.setloclist({ wrap = true })
end)
keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = "LSP rename" })
keymap.set('n', '<leader>tr', vim.lsp.buf.document_symbol)
keymap.set('n', '[d', vim.diagnostic.goto_prev)
keymap.set('n', ']d', vim.diagnostic.goto_next)
keymap.set('v', '<leader>gf', function() vim.lsp.buf.format({async = true}) end)

-- Method Navigation
-- Quick method jumping
keymap.set('n', ']m', ']mzz', { desc = "Next method and center" })
keymap.set('n', '[m', '[mzz', { desc = "Previous method and center" })

-- File Explorer (Nvim-tree)
-- File tree controls
keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find file in explorer" })
keymap.set("n", "<leader>er", ":NvimTreeFocus<CR>", { desc = "Focus file explorer" })

-- Quickfix List Management
-- Quickfix navigation and control
keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix" })
keymap.set("n", "<leader>qf", ":cfirst<CR>", { desc = "First quickfix item" })
keymap.set("n", "<leader>ql", ":clast<CR>", { desc = "Last quickfix item" })
keymap.set("n", "<leader>qn", ":cnext<CR>", { desc = "Next quickfix item" })
keymap.set("n", "<leader>qo", ":copen<CR>", { desc = "Open quickfix" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { desc = "Previous quickfix item" })

-- REST Client Operations
-- HTTP request execution
keymap.set("n", "<leader>rd", "<Plug>VrcRequestDelete", { desc = 'Execute DELETE request' })
keymap.set("n", "<leader>rp", "<Plug>VrcRequestPost", { desc = 'Execute POST request' })
keymap.set("n", "<leader>rg", "<Plug>VrcRequestGet", { desc = 'Execute GET request' })
keymap.set("n", "<leader>ru", "<Plug>VrcRequestPut", { desc = 'Execute PUT request' })
keymap.set("n", "<leader>xj", ":call VrcJson()<CR>", { desc = "Format as JSON" })
keymap.set("n", "<leader>xr", ":call VrcQuery()<CR>", { desc = "Run REST query" })

-- Search and Replace
keymap.set("n", "<leader>S", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word under cursor" })
keymap.set("v", "<leader>S", "y:%s/<C-r>\"/<C-r>\"/gI<Left><Left><Left>", { desc = "Replace visual selection" })

-- Split Window Management
-- Window splitting and sizing
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
keymap.set("n", "<leader>sj", "<C-w>-", { desc = "Decrease height" })
keymap.set("n", "<leader>sk", "<C-w>+", { desc = "Increase height" })
keymap.set("n", "<leader>sl", "<C-w>>", { desc = "Increase width" })
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", { desc = "Toggle maximize" })
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close split" })
keymap.set("n", "<leader>sw", "<C-w>T", { desc = "Move split to tab" })

-- Tab Management
-- Tab operations
keymap.set("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })
keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "New tab" })
keymap.set("n", "<leader>tb", ":tabp<CR>", { desc = "Previous tab" })
keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })

-- Telescope (Fuzzy Finder)
-- Advanced fuzzy finding
keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = "Find buffers" })
keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find files" })
keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = "Find text" })
keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = "Find help" })
keymap.set('n', '<leader>fi', require('telescope.builtin').lsp_incoming_calls, { desc = "Find incoming calls" })
keymap.set('n', '<leader>fm', function() require('telescope.builtin').treesitter({default_text=":method:"}) end, { desc = "Find methods" })
keymap.set('n', '<leader>fo', require('telescope.builtin').lsp_document_symbols, { desc = "Find symbols" })
keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', { desc = "Find recent files" })
keymap.set('n', '<leader>fs', require('telescope.builtin').current_buffer_fuzzy_find, { desc = "Find in buffer" })

-- Terminal Integration
-- Terminal controls
keymap.set('n', '<leader>tt', ':terminal<CR>', { desc = "Open terminal" })
keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = "Exit terminal mode" })

-- Treesitter Integration
-- Treesitter functionality
keymap.set('n', '<C-Space>', ':TSHighlightCapturesUnderCursor<CR>', { desc = "Show highlight groups" })
keymap.set('n', '<leader>tp', ':TSPlaygroundToggle<CR>', { desc = "Toggle Treesitter playground" })

-- Command Aliases
-- Shorthand commands
vim.cmd([[cab cc CodeCompanion]])

