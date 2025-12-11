return {
    ensure_installed = true,
    filetypes = { "terraform", "hcl", "tf" },
    root_dir = function(fname)
        local root_markers = { ".terraform", ".terraform.lock.hcl" }
        for _, marker in ipairs(root_markers) do
            local found = vim.fs.find(marker, { path = fname, upward = true })[1]
            if found then
                return vim.fs.dirname(found)
            end
        end
        local git_root = vim.fs.find(".git", { path = fname, upward = true })[1]
        if git_root then
            return vim.fs.dirname(git_root)
        end
        return vim.fn.getcwd()
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





