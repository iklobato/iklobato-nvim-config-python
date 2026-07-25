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
        lualine_c = { { "filename", path = 2 } },
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
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = {
        width = math.max(30, math.floor(vim.o.columns * 0.2)),
      },
      actions = { open_file = { window_picker = { enable = false } } },
      -- follow the global cwd only. respect_buf_cwd would follow the WINDOW's
      -- cwd instead, so one stray `lcd` (a session is enough) reroots the tree
      -- somewhere unrelated and `nvim .` stops showing the project.
      sync_root_with_cwd = true,
      update_focused_file = { enable = true },
      filters = {
        git_ignored = false,
        custom = { "^__pycache__$", "\\.pyc$" },
      },
    },
  },
}
