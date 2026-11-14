local function lsp_names()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(names, client.name)
  end
  return table.concat(names, " ")
end

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
        lualine_a = { { "mode", icon = "\u{e7c5}" } },
        lualine_c = { { "filename", path = 2 } },
        lualine_x = {
          {
            lsp_names,
            icon = "\u{f085}",
            cond = function()
              return #vim.lsp.get_clients({ bufnr = 0 }) > 0
            end,
          },
          "encoding",
          "fileformat",
          "filetype",
        },
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
      -- a thin bar instead of the default "┃": same width, softer in the gutter
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = { delay = 1000 },
      current_line_blame_formatter = "<summary> • <author_time:%R> • <author>",
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "breakpoints" },
        { "<leader>d", group = "debug" },
        { "<leader>e", group = "explorer" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>m", group = "markdown" },
        { "<leader>n", group = "tests" },
        { "<leader>s", group = "splits" },
        { "<leader>t", group = "tabs" },
        { "<leader>w", group = "write" },
      },
    },
  },
  {
    -- dims the other uses of the word under the cursor; colors come from the theme's LspReference*
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay = 200,
        filetypes_denylist = { "NvimTree", "TelescopePrompt", "bigfile", "dapui_scopes" },
        large_file_cutoff = 2000,
      })
    end,
  },
  {
    -- brackets colored by nesting depth, from the treesitter tree
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "rainbow-delimiters.setup",
    opts = {},
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {
    -- folds with a preview of the folded text; treesitter first, indent when there is no parser
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "kevinhwang91/promise-async" },
    init = function()
      -- ufo needs every fold open at start and a 1-wide column for the fold arrows
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
    end,
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
  },
  {
    -- animates <C-u>/<C-d>/<C-b>/<C-f>/<C-y>/<C-e> and zt/zz/zb
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = { duration_multiplier = 0.6 },
  },
  {
    -- LSP progress ("pyright: indexing") in the corner, so a slow first rename is visible
    "j-hui/fidget.nvim",
    event = "LspAttach",
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
      renderer = {
        group_empty = true,
        highlight_git = true,
        indent_markers = { enable = true },
        -- git state in the sign column, so file names stay aligned
        icons = { git_placement = "signcolumn" },
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
