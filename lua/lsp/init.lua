-- Order matters: every vim.lsp.config call must run before mason-lspconfig enables.

-- blink.cmp sets vim.lsp.config('*').capabilities on load; not a leftover.
require("blink.cmp")

require("lsp.servers.lua")
require("lsp.servers.python")
require("lsp.servers.typescript")
require("lsp.servers.terraform")

local function on_attach(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "gi", vim.lsp.buf.implementation, "Implementation")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    on_attach(nil, args.buf)
  end,
})

-- forces mason's setup before mason-lspconfig, which warns on the wrong order
require("mason")
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "ts_ls", "pyright", "ruff" },
  -- the default (true) starts EVERY server installed in mason
  automatic_enable = {
    "pyright",
    "ruff",
    "lua_ls",
    "ts_ls",
    "terraformls",
    "tflint",
    "html",
    "cssls",
    "tailwindcss",
    "bashls",
    "dockerls",
    "jsonls",
    "yamlls",
    "eslint",
    "marksman",
    "clangd",
  },
})

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
})
