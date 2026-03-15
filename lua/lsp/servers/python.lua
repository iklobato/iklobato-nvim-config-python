vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

vim.lsp.config("ruff", {
  cmd = { "ruff-lsp" },
  filetypes = { "python" },
  root_dir = function(fname)
    return vim.loop.cwd()
  end,
  settings = {
    ruff = {
      lineLength = 88,
      indentTab = false,
    },
  },
})