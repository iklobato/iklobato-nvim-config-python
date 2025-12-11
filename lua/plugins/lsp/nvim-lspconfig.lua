return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/nvim-cmp",        
        "hrsh7th/cmp-nvim-lsp",    
        "hrsh7th/cmp-buffer",      
        "hrsh7th/cmp-path",        
        "hrsh7th/cmp-cmdline",     
        "williamboman/mason.nvim",  
        "williamboman/mason-lspconfig.nvim",
        "j-hui/fidget.nvim",       
        "folke/neodev.nvim",       
    },
    config = function()
        -- Setup Lua development
        require("neodev").setup()

        -- Setup fidget for LSP progress
        require("fidget").setup({
            notification = {
                window = {
                    winblend = 0,
                },
            },
            progress = {
                display = {
                    render_limit = 16,
                    done_ttl = 3,
                    progress_ttl = math.huge,
                },
            },
        })

        -- Setup Mason package manager
        require("mason").setup({
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        })

        -- Setup Mason-LSPconfig
        require("mason-lspconfig").setup({
            automatic_installation = true,
        })

        -- Setup completion
        local cmp = require("cmp")

        local has_words_before = function()
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        cmp.setup({
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ 
                    select = true,
                    behavior = cmp.ConfirmBehavior.Replace 
                }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'buffer' },
                { name = 'path' },
            }),
            formatting = {
                format = function(entry, vim_item)
                    vim_item.kind = string.format('%s', vim_item.kind)
                    vim_item.menu = ({
                        nvim_lsp = "[LSP]",
                        buffer = "[Buffer]",
                        path = "[Path]",
                    })[entry.source.name]
                    return vim_item
                end
            },
        })

        -- Setup buffer-local mappings and options
        local on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- Modified highlighting setup using vim.cmd approach
            if client.server_capabilities.documentHighlightProvider then
                vim.cmd('augroup LspHighlight')
                vim.cmd('autocmd! * <buffer>')
                vim.cmd('autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()')
                vim.cmd('autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
                vim.cmd('augroup END')
            end

            -- Inlay hints
            if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(bufnr, true)
            end

            -- Formatting is handled by conform.nvim (format_on_save)
            -- Removed duplicate BufWritePre autocmd to prevent double formatting
        end

        -- Setup LSP handlers with borders
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover, { border = "rounded" }
        )

        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
            vim.lsp.handlers.signature_help, { border = "rounded" }
        )

        -- Diagnostic configuration
        vim.diagnostic.config({
            virtual_text = {
                prefix = '●',
                source = "always",
            },
            float = {
                border = "rounded",
                source = "always",
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })

        -- Configure sign column
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        -- Setup capabilities
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true

        -- Load LSP configurations from lua/lsp/
        -- Cache config path to avoid repeated globpath calls
        local lsp_config_dir = vim.fn.stdpath('config') .. '/lua/lsp'
        local lsp_configs = vim.fn.globpath(lsp_config_dir, '*.lua', false, true)
        local servers_to_enable = {}
        
        for _, lsp_config_file in ipairs(lsp_configs) do
            local server_name = vim.fn.fnamemodify(lsp_config_file, ':t:r')
            local server_opts = require('lsp.' .. server_name)
            
            -- Merge with common config
            local merged_opts = vim.tbl_deep_extend('force', {
                on_attach = on_attach,
                capabilities = capabilities,
            }, server_opts)
            
            -- For Pyright, set PYTHONPATH environment variable from detected configuration
            if server_name == 'pyright' then
                merged_opts.env = merged_opts.env or {}
                if _G._pyright_pythonpath then
                    merged_opts.env.PYTHONPATH = _G._pyright_pythonpath
                else
                    merged_opts.env.PYTHONPATH = vim.fn.getcwd()
                end
            end
            
            -- Use new Neovim 0.11+ API
            vim.lsp.config(server_name, merged_opts)
            table.insert(servers_to_enable, server_name)
        end
        
        -- Enable all configured servers
        vim.lsp.enable(servers_to_enable)
    end
}