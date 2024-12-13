return {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
        { 'j-hui/fidget.nvim', opts = {} },
        { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
        -- Set up mason first
        require('mason').setup()

        -- Set up mason-lspconfig
        require('mason-lspconfig').setup({
            ensure_installed = {
                'bashls',
                'cssls',
                'html',
                'lua_ls',
                'jsonls',
                'lemminx',
                'marksman',
                'quick_lint_js',
                'pyright',
                'tsserver',
                'yamlls',
                'eslint',
                'omnisharp',
            },
        })

        -- Set up mason-tool-installer
        require('mason-tool-installer').setup({
            ensure_installed = {
                'prettierd',
                'black',
                'isort',
                'cspell',
                'stylua',
                'debugpy',
            },
        })

        -- LSP setup
        local lspconfig = require('lspconfig')
        local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
        local lsp_attach = function(client, bufnr)
            -- Create your keybindings here...
        end

        -- Call setup on each LSP server
        require('mason-lspconfig').setup_handlers({
            function(server_name)
                lspconfig[server_name].setup({
                    on_attach = lsp_attach,
                    capabilities = lsp_capabilities,
                })
            end,
            -- Override lua_ls setup
            ["lua_ls"] = function()
                lspconfig.lua_ls.setup({
                    on_attach = lsp_attach,
                    capabilities = lsp_capabilities,
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = {'vim'},
                            },
                        },
                    },
                })
            end,
        })

        -- Configure LSP floating preview popups
        local orig_open_floating_preview = vim.lsp.util.open_floating_preview
        vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
            opts = opts or {}
            opts.border = opts.border or "rounded"
            return orig_open_floating_preview(contents, syntax, opts)
        end
    end
}
