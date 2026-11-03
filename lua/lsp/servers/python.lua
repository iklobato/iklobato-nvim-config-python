vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        -- "workspace" type-checks the whole repo in the background: heavy in a monorepo
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})

vim.lsp.config("ruff", {
  init_options = {
    settings = {
      lineLength = 88,
    },
  },
})
