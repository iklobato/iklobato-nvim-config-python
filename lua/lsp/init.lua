local capabilities = vim.tbl_deep_extend(
  "force",
  {},
  vim.lsp.protocol.make_client_capabilities(),
  require("blink.cmp").get_lsp_capabilities()
)

local function on_attach(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "<leader>gd", function()
    vim.cmd("vsplit")
    vim.lsp.buf.definition()
  end, "Go to definition (vsplit)")
  map("n", "<leader>gr", function()
    require("telescope.builtin").lsp_references({
      show_line = false,
      include_declaration = false,
    })
  end, "References (Telescope)")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "gi", vim.lsp.buf.implementation, "Implementation")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
end

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "ts_ls", "pyright", "ruff" },
})

vim.lsp.config("*", {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- LSP diagnostics performance
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
})

vim.lsp.handlers["textDocument/diagnostic"] = vim.lsp.with(
  vim.lsp.diagnostic.on_diagnostic, {
    debounce = 150,
  }
)

-- Load server-specific configurations
require("lsp.servers.lua")
require("lsp.servers.python")
require("lsp.servers.typescript")

vim.lsp.enable({ "lua_ls", "ts_ls", "pyright", "ruff" })