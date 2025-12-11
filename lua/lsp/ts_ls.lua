return {
    ensure_installed = true,
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
    root_dir = function(fname)
        local git_root = vim.fs.find(".git", { path = fname, upward = true })[1]
        if git_root then
            return vim.fs.dirname(git_root)
        end
        local root_markers = { "package.json", "tsconfig.json", "jsconfig.json" }
        for _, marker in ipairs(root_markers) do
            local found = vim.fs.find(marker, { path = fname, upward = true })[1]
            if found then
                return vim.fs.dirname(found)
            end
        end
        return vim.fn.getcwd()
    end,
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                languages = { "vue" },
            },
        },
    },
    settings = {
        javascript = {
            inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
            },
        },
        typescript = {
            inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
            },
        },
        vue = {
            inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
            },
        },
    },
}