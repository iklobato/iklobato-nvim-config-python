local map = vim.keymap.set

-- count is the direction; times v:count1 so 3]d jumps three, like nvim's default
local function diagnostic_jump(count)
  return function()
    vim.diagnostic.jump({ count = count * vim.v.count1, float = true })
  end
end

-- "gf" not "e": "<leader>e" prefixes the <leader>e{e,f} explorer maps
map("n", "<leader>gf", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "[d", diagnostic_jump(-1), { desc = "Prev diagnostic" })
map("n", "]d", diagnostic_jump(1), { desc = "Next diagnostic" })
map("n", "<leader>gp", diagnostic_jump(-1), { desc = "Prev diagnostic" })
map("n", "<leader>gn", diagnostic_jump(1), { desc = "Next diagnostic" })
map("n", "<leader>E", function()
  -- open_float has no option to enter the window; jump to the id it returns
  local _, win = vim.diagnostic.open_float()
  if win then
    vim.api.nvim_set_current_win(win)
  end
end, { desc = "Diagnostic float (focus to copy)" })

map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = "Markdown preview" })
map("n", "<leader>mP", "<cmd>MarkdownPreviewStop<CR>", { desc = "Markdown preview stop" })

map(
  "n",
  "<leader>rr",
  "<cmd>lua require('kulala').run()<CR>",
  { desc = "Run HTTP request under cursor" }
)

map("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = "Toggle DB UI" })
