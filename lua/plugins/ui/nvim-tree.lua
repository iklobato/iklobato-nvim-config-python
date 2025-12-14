-- File Explorer / Tree
return {
  -- https://github.com/nvim-tree/nvim-tree.lua
  'nvim-tree/nvim-tree.lua',
  cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile", "NvimTreeFocus" },
  dependencies = {
    -- https://github.com/nvim-tree/nvim-web-devicons
    'nvim-tree/nvim-web-devicons', -- Fancy icon support
  },
  opts = {
    view = {
      width = 50,  -- Set width to 50 columns
    },
    actions = {
      open_file = {
        window_picker = {
          enable = false
        },
      }
    },
    -- Sync root with current working directory
    sync_root_with_cwd = true,
    -- Respect buffer directory
    respect_buf_cwd = true,
  },
  config = function (_, opts)
    require("nvim-tree").setup(opts)
  end
}

