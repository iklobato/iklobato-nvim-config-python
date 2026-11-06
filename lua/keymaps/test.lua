local map = vim.keymap.set

-- <leader>n, not <leader>t: <leader>t is taken by the tab keys
map("n", "<leader>nn", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })
map("n", "<leader>nf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })
map("n", "<leader>nd", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })
map("n", "<leader>ns", function()
  require("neotest").summary.toggle()
end, { desc = "Test summary" })
map("n", "<leader>no", function()
  require("neotest").output.open({ enter = true, auto_close = true })
end, { desc = "Test output" })
