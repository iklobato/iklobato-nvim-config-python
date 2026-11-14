local map = vim.keymap.set

map("n", "<leader>ff", function()
  require("telescope.builtin").find_files({ no_ignore = true })
end, { desc = "Find files" })
map("n", "<leader>fg", function()
  -- a grep hit prints the whole line, so env files are skipped to keep values hidden
  require("telescope.builtin").live_grep({
    additional_args = { "--glob=!.env", "--glob=!.env.*", "--glob=!*.env", "--glob=!.envrc" },
  })
end, { desc = "Live grep" })
map("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "Buffers" })
map("n", "<leader>fo", function()
  local w = vim.api.nvim_win_get_width(0)
  require("telescope.builtin").lsp_document_symbols({
    symbol_width = math.max(40, math.floor(w * 0.5)),
  })
end, { desc = "Find symbols" })
map("n", "<leader>fd", function()
  require("telescope.builtin").diagnostics()
end, { desc = "Diagnostics (project)" })
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "TODO/FIXME list" })
map("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next TODO" })
map("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous TODO" })
