return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/nvim-cmp",        
        "hrsh7th/cmp-nvim-lsp",    
        "hrsh7th/cmp-buffer",      
        "hrsh7th/cmp-path",        
        "hrsh7th/cmp-cmdline",     
        "L3MON4D3/LuaSnip",        
        "saadparwaiz1/cmp_luasnip", 
        "rafamadriz/friendly-snippets",
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
            ensure_installed = { 
                "pyright",          
                "ruff",         
            },
            automatic_installation = true,
        })

        -- Load snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        -- Setup completion
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        local has_words_before = function()
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
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
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'buffer' },
                { name = 'path' },
            }),
            formatting = {
                format = function(entry, vim_item)
                    vim_item.kind = string.format('%s', vim_item.kind)
                    vim_item.menu = ({
                        nvim_lsp = "[LSP]",
                        luasnip = "[Snippet]",
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

        -- Python LSP setup
        require('lspconfig').pyright.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            before_init = function(_, config)
                config.settings.python.analysis.typeCheckingMode = "off"  -- Reduce memory usage
            end,
            cmd = {
                "node",
                "--max-old-space-size=4096",  -- Increase heap size to 4GB
                vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver",
                "--stdio"
            },
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        useLibraryCodeForTypes = true,
                        completeFunctionParens = true,
                        diagnosticSeverityOverrides = {
                            reportGeneralTypeIssues = "warning",
                            reportOptionalMemberAccess = "none",
                            reportOptionalSubscript = "warning",
                            reportPrivateImportUsage = "warning",
                        },
                        extraPaths = {},
                        stubPath = vim.fn.stdpath("data") .. "/mason/packages/django-stubs",
                        django = {
                            enabled = true,
                        },
                        typeCheckingMode = "off",  -- Disable type checking to reduce memory usage
                        reportMissingImports = true,
                        reportMissingTypeStubs = false,
                        -- Add memory optimization settings
                        indexing = true,
                        autoImportCompletions = true,
                        maxAnalysisTimeInSeconds = 60,  -- Limit analysis time
                    }
                }
            }
        })

        -- Ruff (Python linter) setup
        require('lspconfig').ruff.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            init_options = {
                settings = {
                    args = {},
                }
            }
        })
    end
}

