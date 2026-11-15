-- Order matters: every vim.lsp.config call must run before vim.lsp.enable below.

-- What blink.cmp's get_lsp_capabilities() adds over nvim's defaults, set without loading blink:
-- loading it here cost ~80ms per first file (setup spawns git twice and shasum to check its
-- prebuilt binary). tests/features.lua fails if blink's own answer drifts from this table.
local COMPLETION_CAPABILITIES = {
  textDocument = {
    completion = {
      insertTextMode = 1,
      completionItem = {
        insertTextModeSupport = { valueSet = { 1 } },
        resolveSupport = {
          properties = { "documentation", "detail", "additionalTextEdits", "command", "data" },
        },
      },
      completionList = {
        itemDefaults = {
          "commitCharacters",
          "editRange",
          "insertTextFormat",
          "insertTextMode",
          "data",
        },
      },
    },
  },
}
vim.lsp.config("*", { capabilities = COMPLETION_CAPABILITIES })

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
-- install.sh installs only some of these; an absent binary would error on every match
local function installed(name)
  local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
  return type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1
end

-- One python type server, never both (duplicate hover and diagnostics). ty (Rust) answers
-- first hover in ~165ms vs ~1.5s for pyright; NVIM_PY_LSP=pyright switches back.
local OTHER_PY_TYPE_SERVER = { ty = "pyright", pyright = "ty" }
local wanted = OTHER_PY_TYPE_SERVER[vim.env.NVIM_PY_LSP] and vim.env.NVIM_PY_LSP or "ty"
-- a machine without ty yet keeps a type server instead of silently having none
local PY_TYPE_SERVER = installed(wanted) and wanted or OTHER_PY_TYPE_SERVER[wanted]

local SERVERS = {
  PY_TYPE_SERVER,
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
return {
  SERVERS = SERVERS,
  PY_TYPE_SERVER = PY_TYPE_SERVER,
  COMPLETION_CAPABILITIES = COMPLETION_CAPABILITIES,
}
