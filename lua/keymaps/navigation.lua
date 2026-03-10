local map = vim.keymap.set

-- File explorer
map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal file" })

-- Windows and tabs
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>se", function()
  local cur_tab = vim.api.nvim_get_current_tabpage()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    vim.api.nvim_set_current_tabpage(tab)
    vim.cmd("wincmd =")
  end
  vim.api.nvim_set_current_tabpage(cur_tab)
end, { desc = "Equalize splits" })
map("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Maximize split" })
map("n", "<leader>to", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })

-- File operations
map("n", "<leader>ww", ":w<CR>", { desc = "Save file" })
map("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
map("n", "<leader>qq", ":q!<CR>", { desc = "Quit without saving" })