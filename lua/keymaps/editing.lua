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
-- "F" not "f": "<leader>f" is a prefix of the <leader>f{f,g,b,o} find group in
-- keymaps/search.lua, so with timeoutlen=300 a slow second keystroke let this
-- fire Format instead of the find map, leaving the leftover key to run Vim's
-- own f{char} motion.
local function format()
  require("conform").format()
end

map("n", "<leader>F", format, { desc = "Format" })
map("x", "<leader>F", format, { desc = "Format selection" })
