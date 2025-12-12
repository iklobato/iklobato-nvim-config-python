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
            -- ensure_installed not needed when automatic_installation is true
            -- Servers will be automatically installed when configured in lua/lsp/
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
                { name = 'nvim_lsp', priority = 1000 }, -- LSP - highest priority
                { name = 'buffer', priority = 500, max_item_count = 5 }, -- Buffer - limited for performance
                { name = 'path', priority = 250 }, -- Path
            }),
            performance = {
                debounce = 60, -- Debounce completion requests (ms)
                throttle = 30, -- Throttle completion requests (ms)
                fetching_timeout = 500, -- Timeout for fetching completions (ms)
            },
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

            -- Document highlighting with debouncing for performance
            -- Only enable for specific filetypes to reduce overhead
            if client.server_capabilities.documentHighlightProvider then
                local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
                -- Only enable document highlighting for code files, not for markdown, etc.
                local enable_highlighting = vim.tbl_contains({
                    'python', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact',
                    'lua', 'rust', 'go', 'java', 'cpp', 'c', 'vue', 'svelte'
                }, filetype)
                
                if enable_highlighting then
                    -- Use CursorHoldI with longer delay to reduce frequency
                    -- CursorHoldI only triggers in insert mode, reducing overhead
                    local highlight_timer = nil
                    local function debounced_highlight()
                        if highlight_timer then
                            highlight_timer:stop()
                            highlight_timer:close()
                        end
                        highlight_timer = vim.loop.new_timer()
                        highlight_timer:start(500, 0, function()
                            vim.schedule(function()
                                vim.lsp.buf.document_highlight()
                                if highlight_timer then
                                    highlight_timer:close()
                                    highlight_timer = nil
                                end
                            end)
                        end)
                    end
                    
                    vim.cmd('augroup LspHighlight')
                    vim.cmd('autocmd! * <buffer>')
                    -- Use CursorHold with longer updatetime delay
                    vim.cmd('autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()')
                    vim.cmd('autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
                    vim.cmd('augroup END')
                end
            end

            -- Inlay hints - only enable for specific filetypes for performance
            if client.server_capabilities.inlayHintProvider then
                local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
                -- Only enable inlay hints for languages that benefit most
                local enable_inlay_hints = vim.tbl_contains({
                    'typescript', 'typescriptreact', 'javascript', 'javascriptreact',
                    'rust', 'go'
                }, filetype)
                
                if enable_inlay_hints then
                    vim.lsp.inlay_hint.enable(bufnr, true)
                end
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

        -- Diagnostic configuration - optimized for performance
        vim.diagnostic.config({
            virtual_text = {
                prefix = '●',
                source = "if_many", -- Only show source if multiple sources exist (performance optimization)
                spacing = 4, -- Reduce spacing for faster rendering
            },
            float = {
                border = "rounded",
                source = "if_many", -- Only show source if multiple sources exist
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "E",
                    [vim.diagnostic.severity.WARN] = "W",
                    [vim.diagnostic.severity.HINT] = "H",
                    [vim.diagnostic.severity.INFO] = "I",
                },
            },
            underline = true,
            update_in_insert = false, -- Don't update diagnostics while typing (performance)
            severity_sort = true,
        })

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