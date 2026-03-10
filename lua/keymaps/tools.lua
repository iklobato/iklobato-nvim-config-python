local map = vim.keymap.set

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>gp", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "<leader>gn", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>E", function()
  vim.diagnostic.open_float({
    float = { focusable = true, focus = true },
  })
end, { desc = "Diagnostic float (focus to copy)" })

-- Markdown preview
map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = "Markdown preview" })
map("n", "<leader>mP", "<cmd>MarkdownPreviewStop<CR>", { desc = "Markdown preview stop" })

-- HTTP client (rest-nvim, .http / rest files)
map("n", "<leader>rr", "<cmd>vert Rest run<CR>", { desc = "Run REST request under cursor (vertical split)" })

-- Avante
map("n", "<leader>aa", "<cmd>AvanteToggle<CR>", { desc = "Avante" })

-- Database
map("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = "Toggle DB UI" })
map("n", "<leader>dq", "<cmd>DBUIExecuteQuery<CR>", { desc = "Execute query" })
map("v", "<leader>dq", ":DBUIExecuteQuery<CR>", { desc = "Execute selected query" })