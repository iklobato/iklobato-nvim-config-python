return {
  -- Core functionality
  { import = "plugins.nvim-cmp" },
  { import = "plugins.nvim-lspconfig" },
  { import = "plugins.telescope-nvim" },

  -- Git integration
  { import = "plugins.git" },

  -- UI and appearance
  { import = "plugins.colorscheme" },
  { import = "plugins.lualine-nvim" },
  { import = "plugins.bufferline-nvim" },
  { import = "plugins.barbecue-nvim" },
  { import = "plugins.nvim-tree" },

  -- Development tools
  { import = "plugins.conform-nvim" },
  { import = "plugins.nvim-lint" },
  { import = "plugins.nvim-treesitter" },

  -- Debugging
  { import = "plugins.nvim-dap" },
  { import = "plugins.nvim-dap-ui" },
  { import = "plugins.nvim-dap-virtual-text" },

  -- Language specific
  { import = "plugins.markdown-preview" },
  { import = "plugins.rest-nvim" },
  { import = "plugins.nvim-sql" },

  -- AI and utilities
  { import = "plugins.nvim-avante" },
  { import = "plugins._copilot" },
  { import = "plugins.schemastore-nvim" },
  { import = "plugins.nvim-lspimport" },

  -- Workflow enhancements
  { import = "plugins.auto-session" },
  { import = "plugins.bigfile-nvim" },
  { import = "plugins.nvim-autopairs" },
  { import = "plugins.nvim-surround" },
  { import = "plugins.vim-maximizer" },
}
