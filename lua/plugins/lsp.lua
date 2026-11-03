return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
    -- without setup() the registry is empty for anything else that loads mason.
    -- PATH skip: init.lua already prepends mason/bin, so no duplicate entry
    opts = { PATH = "skip" },
  },
}
