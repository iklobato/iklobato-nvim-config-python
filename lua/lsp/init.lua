-- Order matters: every vim.lsp.config call must run before vim.lsp.enable below.

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

-- Native enable instead of mason-lspconfig: that plugin cost ~35ms per first buffer.
-- Mason itself loads only on :Mason; its bin dir is put on PATH in init.lua.
local SERVERS = {
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
}

-- install.sh installs only some of these; an absent binary would error on every match
local function installed(name)
  local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
  return type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1
end

vim.lsp.enable(vim.tbl_filter(installed, SERVERS))

local severity = vim.diagnostic.severity
vim.diagnostic.config({
  virtual_text = false,
  -- one diagnostic under the cursor line only; the rest of the file stays clean (0.11+)
  virtual_lines = { current_line = true },
  signs = {
    text = {
      [severity.ERROR] = "",
      [severity.WARN] = "",
      [severity.INFO] = "",
      [severity.HINT] = "",
    },
  },
  underline = true,
  update_in_insert = false,
})

-- read by tests/features.lua
return { SERVERS = SERVERS }
