local M = {}

function M.setup()
  require("nvim-treesitter.configs").setup({
    highlight = { enable = true },
    ensure_installed = { "lua", "python", "c", "http", "html", "javascript", "tsx", "css" },
  })
end

return M