return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "williamboman/mason.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Mason",
    -- without setup() the package registry stays empty, so anything loading
    -- mason on its own (nvim-dap does, via mason-nvim-dap) sees zero packages
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },
}
