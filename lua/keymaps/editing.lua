local map = vim.keymap.set

-- "x" not "v": "v" also binds Select mode, where <leader> would block snippet typing

map(
  "n",
  "<leader>S",
  ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "Replace word" }
)
map("x", "<leader>S", 'y:%s/<C-r>"/<C-r>"/gI<Left><Left><Left>', { desc = "Replace selection" })

-- "F" not "f": <leader>f prefixes the find maps and would fire on a slow 2nd key
local function format()
  require("conform").format()
end

map("n", "<leader>F", format, { desc = "Format" })
map("x", "<leader>F", format, { desc = "Format selection" })
