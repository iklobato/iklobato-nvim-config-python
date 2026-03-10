local map = vim.keymap.set

-- Replace
map("n", "<leader>S", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word" })
map("v", "<leader>S", "y:%s/<C-r>\"/<C-r>\"/gI<Left><Left><Left>", { desc = "Replace selection" })

-- Formatting
map("n", "<leader>f", function()
  require("conform").format({ lsp_fallback = false })
end, { desc = "Format" })
map("v", "<leader>f", function()
  require("conform").format({ lsp_fallback = false })
end, { desc = "Format selection" })