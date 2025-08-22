return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    dependencies = {
        "williamboman/mason.nvim", -- Ensure Mason is available
    },
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            desc = "Format buffer",
            mode = { "n", "v" }
        },
    },
    config = function()
        require("conform").setup({
            -- Define formatters
            formatters_by_ft = {
                -- Frontend formatters
                html = { "prettierd", "prettier" },
                css = { "prettierd", "prettier" },
                scss = { "prettierd", "prettier" },
                javascript = { "prettierd", "prettier" },
                javascriptreact = { "prettierd", "prettier" },
                typescript = { "prettierd", "prettier" },
                typescriptreact = { "prettierd", "prettier" },
                json = { "prettierd", "prettier" },
                jsonc = { "prettierd", "prettier" },
                vue = { "prettierd", "prettier" },
                svelte = { "prettierd", "prettier" },
                
                -- Ensure existing formatters aren't overridden
                lua = { "stylua" },
                python = { "ruff", "black" },
            },
            
            -- Format on save
            format_on_save = {
                -- I recommend setting up format on save with a timeout
                timeout_ms = 500,
                lsp_fallback = true,
            },
            
            -- Customize formatters
            formatters = {
                prettier = {
                    -- Customize prettier options if needed
                    env = {
                        PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/.prettierrc.json"),
                    },
                },
            },
        })
        
        -- Ensure formatters are installed in Mason
        require("mason-registry"):on("package:install:success", function()
            vim.defer_fn(function()
                require("conform").setup({})
            end, 200)
        end)
    end,
}