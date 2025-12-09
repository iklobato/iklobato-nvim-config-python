return {
    ensure_installed = true,
    filetypes = { "terraform", "hcl", "tf" },
    root_dir = function(fname)
        return require('lspconfig.util').root_pattern(".terraform", "*.tf", ".terraform.lock.hcl")(fname) or
            require('lspconfig.util').find_git_ancestor(fname) or
            vim.fn.getcwd()
    end,
    settings = {
        terraform = {
            format = {
                enable = true,
            },
            validation = {
                enable = true,
            },
        },
    },
}





