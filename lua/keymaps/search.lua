local map = vim.keymap.set

-- Search
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files({ no_ignore = true })
end, { desc = "Find files" })
map("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "Buffers" })
map("n", "<leader>fo", function()
  local w = vim.api.nvim_win_get_width(0)
  require("telescope.builtin").lsp_document_symbols({
    symbol_width = math.max(40, math.floor(w * 0.5)),
    symbol_type_width = math.max(8, math.floor(w * 0.15)), -- category column (Variable, Function, Class, ...)
  })
end, { desc = "Find symbols" })