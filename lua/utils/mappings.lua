local M = {}

-- Helper function to create keymaps with consistent options
function M.map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Helper function to create buffer-local keymaps
function M.buf_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
end

-- Helper function to create LSP keymaps
function M.lsp_map(bufnr, mode, lhs, rhs, desc)
  M.buf_map(bufnr, mode, lhs, rhs, desc)
end

return M