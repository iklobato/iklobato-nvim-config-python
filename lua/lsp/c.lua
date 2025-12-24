-- C/C++ LSP server: clangd
return {
  -- clangd (C/C++ language server)
  {
    name = "clangd",
    ensure_installed = true,
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
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
      
      -- Look for compile_commands.json (CMake, Bear, etc.)
      local compile_commands = vim.fs.find("compile_commands.json", { path = dir, upward = true })[1]
      if compile_commands then
        return vim.fs.dirname(compile_commands)
      end
      
      -- Look for build system files
      local build_markers = {
        "CMakeLists.txt",
        "Makefile",
        "meson.build",
        "build.ninja",
        ".git",
      }
      for _, marker in ipairs(build_markers) do
        local found = vim.fs.find(marker, { path = dir, upward = true })[1]
        if found then
          return vim.fs.dirname(found)
        end
      end
      
      return vim.fn.getcwd()
    end,
    -- clangd configuration via command-line flags
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
  },
}
