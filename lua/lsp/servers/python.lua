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

-- pyenv's prefix for a root: `.python-version` up the tree, else the global version file.
-- Read from disk: `python3 -c 'import sys; print(sys.prefix)'` through the shim takes ~270ms.
local function pyenv_prefix(root)
  local pyenv_root = vim.env.PYENV_ROOT or vim.fs.joinpath(vim.env.HOME, ".pyenv")
  local version_file = vim.fs.find(".python-version", { path = root, upward = true })[1]
    or vim.fs.joinpath(pyenv_root, "version")
  if vim.fn.filereadable(version_file) == 0 then
    return nil
  end
  local lines = vim.fn.readfile(version_file, "", 1)
  if not lines[1] or vim.trim(lines[1]) == "" then
    return nil
  end
  local prefix = vim.fs.joinpath(pyenv_root, "versions", vim.trim(lines[1]))
  return vim.fn.isdirectory(prefix) == 1 and prefix or nil
end

vim.lsp.config("ty", {
  -- With no venv, pyright falls back to the python on PATH but ty only to its bundled
  -- stdlib, so every third-party import is unresolved. Give ty the interpreter pyright
  -- would find. ty cannot use the pyenv shim itself (it reads lib/ under the given path).
  before_init = function(params, config)
    local root = config.root_dir
    if vim.env.VIRTUAL_ENV or not root or vim.uv.fs_stat(vim.fs.joinpath(root, ".venv")) then
      return
    end
    local prefix = pyenv_prefix(root)
    if prefix then
      params.initializationOptions =
        vim.tbl_deep_extend("force", params.initializationOptions or {}, {
          configuration = { environment = { python = prefix } },
        })
    end
  end,
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
