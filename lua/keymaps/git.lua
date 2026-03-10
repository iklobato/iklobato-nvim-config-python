local map = vim.keymap.set

-- Git
map("n", "<leader>gb", "<cmd>GitBlameToggle<CR>", { desc = "Toggle git blame" })