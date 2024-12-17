-- Set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

-- General keymaps
keymap.set("n", "<leader>wq", ":wq<CR>") -- save and quit
keymap.set("n", "<leader>qq", ":q!<CR>") -- quit without saving
keymap.set("n", "<leader>ww", ":w<CR>") -- save
keymap.set("n", "gx", ":!open <c-r><c-a><CR>") -- open URL under cursor

-- Split window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width
keymap.set("n", "<leader>sx", ":close<CR>") -- close split window
keymap.set("n", "<leader>sj", "<C-w>-") -- make split window height shorter
keymap.set("n", "<leader>sk", "<C-w>+") -- make split windows height taller
keymap.set("n", "<leader>sl", "<C-w>>") -- make split windows width bigger 
keymap.set("n", "<leader>sh", "<C-w><") -- make split windows width smaller

-- Tab management
keymap.set("n", "<leader>to", ":tabnew<CR>") -- open a new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close a tab
keymap.set("n", "<leader>tn", ":tabn<CR>") -- next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") -- previous tab

-- Diff keymaps
keymap.set("n", "<leader>cc", ":diffput<CR>") -- put diff from current to other during diff
keymap.set("n", "<leader>cj", ":diffget 1<CR>") -- get diff from left (local) during merge
keymap.set("n", "<leader>ck", ":diffget 3<CR>") -- get diff from right (remote) during merge
keymap.set("n", "<leader>cn", "]c") -- next diff hunk
keymap.set("n", "<leader>cp", "[c") -- previous diff hunk

-- Quickfix keymaps
keymap.set("n", "<leader>qo", ":copen<CR>") -- open quickfix list
keymap.set("n", "<leader>qf", ":cfirst<CR>") -- jump to first quickfix list item
keymap.set("n", "<leader>qn", ":cnext<CR>") -- jump to next quickfix list item
keymap.set("n", "<leader>qp", ":cprev<CR>") -- jump to prev quickfix list item
keymap.set("n", "<leader>ql", ":clast<CR>") -- jump to last quickfix list item
keymap.set("n", "<leader>qc", ":cclose<CR>") -- close quickfix list

-- Vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle maximize tab

-- Nvim-tree
keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>") -- toggle file explorer
keymap.set("n", "<leader>er", ":NvimTreeFocus<CR>") -- toggle focus to file explorer
keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>") -- find file in file explorer

-- Telescope
keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {}) -- find files
keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {}) -- find text
keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, {}) -- find buffers
keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, {}) -- find help
keymap.set('n', '<leader>fs', require('telescope.builtin').current_buffer_fuzzy_find, {}) -- find in current buffer
keymap.set('n', '<leader>fo', require('telescope.builtin').lsp_document_symbols, {}) -- find symbols
keymap.set('n', '<leader>fi', require('telescope.builtin').lsp_incoming_calls, {}) -- find incoming calls
keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', {}) -- find recent files
keymap.set('n', '<leader>fm', function() require('telescope.builtin').treesitter({default_text=":method:"}) end) -- find methods

-- Git-blame
keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>") -- toggle git blame

-- Auto-session
keymap.set('n', '<leader>ss', function() require('auto-session.session-lens').search_session() end) -- search sessions
keymap.set('n', '<leader>sd', function() require('auto-session').DeleteSession() end) -- delete session

-- LSP keymaps
keymap.set('n', '<leader>e', vim.diagnostic.open_float)
keymap.set('n', '[d', vim.diagnostic.goto_prev)
keymap.set('n', ']d', vim.diagnostic.goto_next)
keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
keymap.set('n', '<leader>gg', vim.lsp.buf.hover)
keymap.set('n', '<leader>gd', vim.lsp.buf.definition)
keymap.set('n', '<leader>gD', vim.lsp.buf.declaration)
keymap.set('n', '<leader>gi', vim.lsp.buf.implementation)
keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition)
keymap.set('n', '<leader>gr', vim.lsp.buf.references)
keymap.set('n', '<leader>gs', vim.lsp.buf.signature_help)
keymap.set('n', '<leader>rr', vim.lsp.buf.rename)
keymap.set('n', '<leader>gf', function() vim.lsp.buf.format({async = true}) end)
keymap.set('v', '<leader>gf', function() vim.lsp.buf.format({async = true}) end)
keymap.set('n', '<leader>ga', vim.lsp.buf.code_action)
keymap.set('n', '<leader>gl', vim.diagnostic.open_float)
keymap.set('n', '<leader>gp', vim.diagnostic.goto_prev)
keymap.set('n', '<leader>gn', vim.diagnostic.goto_next)
keymap.set('n', '<leader>tr', vim.lsp.buf.document_symbol)

-- Debugging
keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>")
keymap.set("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>")
keymap.set("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>")
keymap.set("n", '<leader>br', "<cmd>lua require'dap'.clear_breakpoints()<cr>")
keymap.set("n", '<leader>ba', '<cmd>Telescope dap list_breakpoints<cr>')
keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>")
keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>")
keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>")
keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>")
keymap.set("n", '<leader>dd', function() require('dap').disconnect(); require('dapui').close(); end)
keymap.set("n", '<leader>dt', function() require('dap').terminate(); require('dapui').close(); end)
keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>")
keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>")
keymap.set("n", '<leader>di', function() require "dap.ui.widgets".hover() end)
keymap.set("n", '<leader>d?', function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end)
keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>')
keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>')
keymap.set("n", '<leader>de', function() require('telescope.builtin').diagnostics({default_text=":E:"}) end)

-- Treesitter Selection
keymap.set('n', '<C-Space>', ':TSHighlightCapturesUnderCursor<CR>') -- Show treesitter highlight groups
keymap.set('n', '<leader>tp', ':TSPlaygroundToggle<CR>') -- Toggle Treesitter playground

-- Indent-blankline
keymap.set('n', '<leader>ti', ':IBLToggle<CR>') -- Toggle indent lines

-- Buffer Navigation
keymap.set('n', '<leader>bn', ':bnext<CR>') -- Next buffer
keymap.set('n', '<leader>bp', ':bprevious<CR>') -- Previous buffer
keymap.set('n', '<leader>bd', ':bdelete<CR>') -- Delete buffer

-- REST Client
keymap.set("n", "<leader>xr", ":call VrcQuery()<CR>") -- Run REST query
keymap.set("n", "<leader>xj", ":call VrcJson()<CR>") -- Format as JSON

-- Quick Search and Replace
keymap.set("n", "<leader>S", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>") -- Replace word under cursor
keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>") -- Search word under cursor

-- Terminal
keymap.set('n', '<leader>tt', ':terminal<CR>') -- Open terminal in new buffer
keymap.set('t', '<Esc>', '<C-\\><C-n>') -- Exit terminal mode

-- Code Folding
keymap.set('n', '<leader>za', 'za') -- Toggle fold under cursor
keymap.set('n', '<leader>zA', 'zA') -- Toggle all folds under cursor
keymap.set('n', '<leader>zc', 'zc') -- Close fold under cursor
keymap.set('n', '<leader>zo', 'zo') -- Open fold under cursor
keymap.set('n', '<leader>zR', 'zR') -- Open all folds
keymap.set('n', '<leader>zM', 'zM') -- Close all folds

-- Database (vim-dadbod)
keymap.set('n', '<leader>db', '<cmd>DBUIToggle<CR>', { desc = 'Toggle DB UI' })
keymap.set('n', '<leader>dq', '<cmd>DBUIExecuteQuery<CR>', { desc = 'Execute query' })
keymap.set('v', '<leader>dq', ':DBUIExecuteQuery<CR>', { desc = 'Execute selected query' })

-- Center cursor on search movements
keymap.set('n', '*', '*zz', { desc = 'Search word under cursor and center' })
keymap.set('n', 'n', 'nzz', { desc = 'Next search result and center' })
keymap.set('n', 'N', 'Nzz', { desc = 'Previous search result and center' })

-- Center cursor on page movements
keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Page down and center' })
keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Page up and center' })

