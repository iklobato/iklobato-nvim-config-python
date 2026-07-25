local map = vim.keymap.set

-- Diagnostics. goto_prev/goto_next are deprecated and go away in nvim 0.13.
local function diagnostic_jump(count)
  return function()
    vim.diagnostic.jump({ count = count, float = true })
  end
end

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "[d", diagnostic_jump(-1), { desc = "Prev diagnostic" })
map("n", "]d", diagnostic_jump(1), { desc = "Next diagnostic" })
map("n", "<leader>gp", diagnostic_jump(-1), { desc = "Prev diagnostic" })
map("n", "<leader>gn", diagnostic_jump(1), { desc = "Next diagnostic" })
map("n", "<leader>E", function()
  vim.diagnostic.open_float({
    float = { focusable = true, focus = true },
  })
end, { desc = "Diagnostic float (focus to copy)" })

-- Markdown preview
map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = "Markdown preview" })
map("n", "<leader>mP", "<cmd>MarkdownPreviewStop<CR>", { desc = "Markdown preview stop" })

-- HTTP client (kulala, .http / rest files)
map(
  "n",
  "<leader>rr",
  "<cmd>lua require('kulala').run()<CR>",
  { desc = "Run HTTP request under cursor" }
)

-- Database. Query execution is dadbod-ui's own buffer-local <Leader>S; there is
-- no :DBUIExecuteQuery command to map here.
map("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = "Toggle DB UI" })
