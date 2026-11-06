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
  -- an unnamed buffer (:enew, ft=python) has no parent path and ruff server panics on it
  -- ("a path to a document should have a parent path"), so attach to real files only
  root_dir = function(bufnr, on_dir)
    if vim.api.nvim_buf_get_name(bufnr) == "" then
      return
    end
    on_dir(vim.fs.root(bufnr, vim.lsp.config.ruff.root_markers))
  end,
  init_options = {
    settings = {
      lineLength = 88,
    },
  },
})
