local M = {}

function M.setup()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      -- matched unanchored: a bare "build" would also hide builder.py
      file_ignore_patterns = {
        "^node_modules/",
        "/node_modules/",
        "^%.git/",
        "/%.git/",
        "^dist/",
        "/dist/",
        "^build/",
        "/build/",
        "^__pycache__/",
        "/__pycache__/",
        "%.pyc$",
      },
    },
  })
end

return M
