-- Order matters: everything that registers a vim.lsp.config entry must run
-- before mason-lspconfig's automatic_enable calls vim.lsp.enable(), otherwise
-- servers started after VimEnter come up with nvim-lspconfig's defaults.

-- blink.cmp's plugin file is what sets vim.lsp.config('*').capabilities;
-- requiring it here is load-bearing, not a leftover.
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

-- mason-lspconfig v2 dropped the `handlers` option, so on_attach has to be
-- wired through LspAttach instead.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    on_attach(nil, args.buf)
  end,
})

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "ts_ls", "pyright", "ruff" },
  -- automatic_enable defaults to true, which starts EVERY server installed in
  -- mason. Keep it to the ones actually used.
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

-- LSP diagnostics performance
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
})
