return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "williamboman/mason.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Mason",
    -- without setup() the registry is empty for anything else that loads mason
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },
}
