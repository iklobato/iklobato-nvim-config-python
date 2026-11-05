return {
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
        -- slant glyphs to match bufferline's "slant" separators
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
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
    -- `nvim .` reads no file, so <leader>gb needs the command to load it
    cmd = "Gitsigns",
    -- inline blame lives here (it replaced git-blame.nvim): one plugin, no extra git process
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 1000 },
      current_line_blame_formatter = "<summary> • <author_time:%R> • <author>",
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = {
        width = math.max(30, math.floor(vim.o.columns * 0.2)),
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        indent_markers = { enable = true },
      },
      actions = { open_file = { window_picker = { enable = false } } },
      -- not respect_buf_cwd: one stray `lcd` would reroot the tree elsewhere
      sync_root_with_cwd = true,
      update_focused_file = { enable = true },
      filters = {
        git_ignored = false,
        custom = { "^__pycache__$", "\\.pyc$" },
      },
    },
  },
}
