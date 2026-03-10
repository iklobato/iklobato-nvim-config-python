local M = {}

function M.setup()
  local telescope = require("telescope")
  telescope.setup({})
  pcall(telescope.load_extension, "dap")
end

return M