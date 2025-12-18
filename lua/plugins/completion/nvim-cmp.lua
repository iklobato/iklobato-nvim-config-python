-- Auto-completion / Snippets
return {
  -- https://github.com/hrsh7th/nvim-cmp
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  priority = 700, -- High priority: essential for editing
  dependencies = {
    -- LSP completion capabilities
    -- https://github.com/hrsh7th/cmp-nvim-lsp
    'hrsh7th/cmp-nvim-lsp',
    -- https://github.com/hrsh7th/cmp-buffer
    'hrsh7th/cmp-buffer',
    -- https://github.com/hrsh7th/cmp-path
    'hrsh7th/cmp-path',
    -- https://github.com/hrsh7th/cmp-cmdline
    'hrsh7th/cmp-cmdline',
  },
  config = function()
    local cmp = require('cmp')

    cmp.setup({
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      mapping = cmp.mapping.preset.insert {
        ['<C-j>'] = cmp.mapping.select_next_item(), -- next suggestion
        ['<C-k>'] = cmp.mapping.select_prev_item(), -- previous suggestion
        ['<C-b>'] = cmp.mapping.scroll_docs(-4), -- scroll backward
        ['<C-f>'] = cmp.mapping.scroll_docs(4), -- scroll forward
        ['<C-Space>'] = cmp.mapping.complete {}, -- show completion suggestions
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
          -- Check for copilot suggestion first
          local copilot_suggestion = vim.fn['copilot#Accept']()
          if copilot_suggestion and copilot_suggestion ~= '' and type(copilot_suggestion) == 'string' then
            -- Copilot suggestion is available, accept it
            vim.api.nvim_feedkeys(copilot_suggestion, 'i', true)
            return
          end
          -- Then check for nvim-cmp completion
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 }, -- lsp - highest priority
        { name = "buffer", priority = 500, max_item_count = 5 }, -- text within current buffer - limited for performance
        { name = "path", priority = 250 }, -- file system paths
      }),
      performance = {
        debounce = 60, -- Debounce completion requests (ms)
        throttle = 30, -- Throttle completion requests (ms)
        fetching_timeout = 500, -- Timeout for fetching completions (ms)
      },
      window = {
        -- Add borders to completions popups
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    })
  end,
 }

