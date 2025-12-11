-- Auto-completion / Snippets
return {
  -- https://github.com/hrsh7th/nvim-cmp
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
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
        { name = "nvim_lsp" }, -- lsp 
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
      }),
      window = {
        -- Add borders to completions popups
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    })
  end,
 }

