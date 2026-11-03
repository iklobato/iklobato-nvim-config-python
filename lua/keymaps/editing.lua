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
-- conform's 1000ms default timed prettier out: one run took 0.81-1.03s under load
-- (measured 2026-11-03, load avg 31-55), so 3x the slowest run
local FORMAT_TIMEOUT_MS = 3000

local function format()
  require("conform").format({ timeout_ms = FORMAT_TIMEOUT_MS })
end

map("n", "<leader>F", format, { desc = "Format" })
map("x", "<leader>F", format, { desc = "Format selection" })
