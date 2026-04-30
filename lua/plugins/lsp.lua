return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "williamboman/mason.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Mason",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },
}
