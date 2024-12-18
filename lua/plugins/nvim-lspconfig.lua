-- lua/plugins/nvim-lspconfig.lua
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/nvim-cmp",        -- The main completion plugin
        "hrsh7th/cmp-nvim-lsp",    -- LSP completion source
        "hrsh7th/cmp-buffer",      -- Buffer completion source
        "hrsh7th/cmp-path",        -- Path completion source
        "hrsh7th/cmp-cmdline",     -- Command line completion
        "L3MON4D3/LuaSnip",        -- Snippet engine
        "saadparwaiz1/cmp_luasnip", -- Snippet completion source
        "rafamadriz/friendly-snippets", -- Snippet collection
        "williamboman/mason.nvim",  -- Package manager for LSP servers
        "williamboman/mason-lspconfig.nvim",
        "j-hui/fidget.nvim",       -- LSP progress UI
        "folke/neodev.nvim",       -- Additional Lua configuration
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
                "pyright",          -- Python language server
                "ruff",         -- Python linter
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
                -- ["<Tab>"] = cmp.mapping(function(fallback)
                --     if cmp.visible() then
                --         cmp.select_next_item()
                --     elseif luasnip.expand_or_jumpable() then
                --         luasnip.expand_or_jump()
                --     elseif has_words_before() then
                --         cmp.complete()
                --     else
                --         fallback()
                --     end
                -- end, { "i", "s" }),
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
                    -- Kind icons
                    vim_item.kind = string.format('%s %s', vim_item.kind, vim_item.kind) -- This concatenates the icons with the name of the item kind
                    -- Source
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

            -- Highlighting references
            if client.server_capabilities.documentHighlightProvider then
                vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
                vim.api.nvim_clear_autocmds { buffer = bufnr, group = "lsp_document_highlight" }
                vim.api.nvim_create_autocmd("CursorHold", {
                    callback = vim.lsp.buf.document_highlight,
                    buffer = bufnr,
                    group = "lsp_document_highlight",
                    desc = "Document Highlight",
                })
                vim.api.nvim_create_autocmd("CursorMoved", {
                    callback = vim.lsp.buf.clear_references,
                    buffer = bufnr,
                    group = "lsp_document_highlight",
                    desc = "Clear All the References",
                })
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
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        useLibraryCodeForTypes = true,
                        typeCheckingMode = "basic",
                        completeFunctionParens = true,
                        diagnosticSeverityOverrides = {
                            reportGeneralTypeIssues = "warning",
                            reportOptionalMemberAccess = "warning",
                            reportOptionalSubscript = "warning",
                            reportPrivateImportUsage = "warning",
                        },
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

