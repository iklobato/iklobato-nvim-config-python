local M = {}

function M.setup()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      file_ignore_patterns = { "node_modules", ".git", "dist", "build" },
    },
  })
end

return M