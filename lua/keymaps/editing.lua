local map = vim.keymap.set

-- "x" not "v": "v" also binds Select mode, where <leader> (space) would block
-- instead of overwriting a snippet placeholder.

-- Replace
map(
  "n",
  "<leader>S",
  ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "Replace word" }
)
map("x", "<leader>S", 'y:%s/<C-r>"/<C-r>"/gI<Left><Left><Left>', { desc = "Replace selection" })

-- Formatting
local function format()
  require("conform").format()
end

map("n", "<leader>f", format, { desc = "Format" })
map("x", "<leader>f", format, { desc = "Format selection" })
