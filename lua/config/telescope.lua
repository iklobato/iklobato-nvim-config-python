local M = {}

function M.setup()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      -- telescope runs string.find(path, pattern) unanchored, so a bare "build"
      -- also hides builder.py and ".git" hides .gitignore. Anchor each to a full
      -- path segment (start-of-path or after a slash) so only real dirs are cut.
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
