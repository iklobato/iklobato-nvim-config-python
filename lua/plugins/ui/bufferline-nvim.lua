-- Bufferline - Browser-style tabs
return {
  'akinsho/bufferline.nvim',
  version = "*",
  event = "VeryLazy",
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    options = {
      mode = "tabs", -- Show tabs instead of buffers
      themable = true,
      numbers = "none", -- "none" | "ordinal" | "buffer_id" | "both"
      close_command = "tabclose",
      right_mouse_command = "tabclose %d",
      left_mouse_command = "tabn %d",
      middle_mouse_command = nil,
      
      -- Indicator
      indicator = {
        icon = '▎',
        style = 'icon', -- 'icon' | 'underline' | 'none'
      },
      
      -- Buffer close icons
      buffer_close_icon = '󰅖',
      modified_icon = '●',
      close_icon = '',
      left_trunc_marker = '',
      right_trunc_marker = '',
      
      -- Name formatting
      max_name_length = 18,
      max_prefix_length = 15,
      truncate_names = true,
      tab_size = 18,
      
      -- Diagnostics
      diagnostics = false,
      
      -- Offsets for file explorer
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "left",
          separator = true
        },
        {
          filetype = "dbui",
          text = "Database",
          text_align = "left",
          separator = true
        }
      },
      
      -- Separators
      separator_style = "thin", -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' }
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      show_buffer_icons = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      show_tab_indicators = true,
      show_duplicate_prefix = true,
      persist_buffer_sort = true,
      
      -- Sorting
      sort_by = 'id',
      
      -- Make tabs fill width proportionally
      style_preset = {
        require('bufferline').style_preset.no_italic,
        require('bufferline').style_preset.no_bold,
      },
    },
    
    highlights = {
      fill = {
        bg = '#1e1e1e',
      },
      background = {
        bg = '#252526',
      },
      tab = {
        bg = '#252526',
      },
      tab_selected = {
        bg = '#1e1e1e',
        bold = true,
      },
      tab_separator = {
        fg = '#1e1e1e',
        bg = '#252526',
      },
      tab_separator_selected = {
        fg = '#1e1e1e',
        bg = '#1e1e1e',
      },
      tab_close = {
        bg = '#252526',
      },
      close_button = {
        bg = '#252526',
      },
      close_button_visible = {
        bg = '#252526',
      },
      close_button_selected = {
        bg = '#1e1e1e',
      },
      modified = {
        bg = '#252526',
      },
      modified_selected = {
        bg = '#1e1e1e',
      },
      indicator_selected = {
        bg = '#1e1e1e',
      },
      separator = {
        fg = '#1e1e1e',
        bg = '#252526',
      },
      separator_selected = {
        fg = '#1e1e1e',
        bg = '#1e1e1e',
      },
      separator_visible = {
        fg = '#1e1e1e',
        bg = '#252526',
      },
    }
  }
}
