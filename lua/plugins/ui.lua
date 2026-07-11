return {
  {
    "xiantang/darcula-dark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("darcula-dark")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        separator_style = "slant",
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "NvimTree", text = "Project", text_align = "left" },
        },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
      },
      sections = {
        lualine_x = { "encoding", "fileformat", "filetype" },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = true,
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = {
        width = math.max(30, math.floor(vim.o.columns * 0.2)),
      },
      actions = { open_file = { window_picker = { enable = false } } },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true },
      filters = {
        git_ignored = false,
        custom = { "^__pycache__$", "\\.pyc$" },
      },
    },
  },
}
