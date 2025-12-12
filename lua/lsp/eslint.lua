return {
    ensure_installed = true,
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
        "svelte"
    },
    root_dir = function(fname)
        -- Handle buffer number (convert to file path) or file path string
        local path = fname
        if type(fname) == "number" then
            path = vim.api.nvim_buf_get_name(fname)
            if path == "" then
                return vim.fn.getcwd()
            end
        end
        -- Get directory of the file
        local dir = vim.fs.dirname(path)
        local git_root = vim.fs.find(".git", { path = dir, upward = true })[1]
        if git_root then
            return vim.fs.dirname(git_root)
        end
        local root_markers = {
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.json",
            "eslint.config.js",
            "package.json"
        }
        for _, marker in ipairs(root_markers) do
            local found = vim.fs.find(marker, { path = dir, upward = true })[1]
            if found then
                return vim.fs.dirname(found)
            end
        end
        return vim.fn.getcwd()
    end,
    settings = {
        codeAction = {
            disableRuleComment = {
                enable = true,
                location = "separateLine"
            },
            showDocumentation = {
                enable = true
            }
        },
        codeActionOnSave = {
            enable = false,
            mode = "all"
        },
        experimental = {
            useFlatConfig = false
        },
        format = false, -- Use prettier for formatting
        nodePath = "",
        onIgnoredFiles = "off",
        packageManager = "npm",
        problems = {
            shortenToSingleLine = false
        },
        quiet = false,
        rulesCustomizations = {},
        run = "onType",
        useESLintClass = false,
        validate = "on",
        workingDirectory = {
            mode = "auto"
        }
    },
}

