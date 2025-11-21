-- Helper function to check if value exists in table
local function table_contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Function to detect uv virtual environment
local function detect_uv_venv()
    local cwd = vim.fn.getcwd()
    
    -- When running with `uv run nvim .`, VIRTUAL_ENV is set by uv
    -- This is the most reliable way to detect uv-managed environments
    if vim.fn.exists('$VIRTUAL_ENV') == 1 then
        local venv = vim.fn.expand('$VIRTUAL_ENV')
        if vim.fn.isdirectory(venv) == 1 then
            -- Check if it's a uv-managed venv (look for uv.lock or pyproject.toml)
            local pyproject = vim.fn.findfile('pyproject.toml', cwd .. ';')
            local uv_lock = vim.fn.findfile('uv.lock', cwd .. ';')
            if pyproject ~= '' or uv_lock ~= '' then
                return venv
            end
            -- Even without explicit uv files, if VIRTUAL_ENV is set during uv run, use it
            return venv
        end
    end
    
    -- Check if uv is managing this project (look for pyproject.toml or uv.lock)
    local pyproject = vim.fn.findfile('pyproject.toml', cwd .. ';')
    local uv_lock = vim.fn.findfile('uv.lock', cwd .. ';')
    
    if pyproject ~= '' or uv_lock ~= '' then
        -- When running with `uv run`, the virtual environment is typically in .venv
        local venv_paths = {
            cwd .. '/.venv',
            cwd .. '/venv',
        }
        
        -- Check common venv locations
        for _, venv_path in ipairs(venv_paths) do
            if vim.fn.isdirectory(venv_path) == 1 then
                return venv_path
            end
        end
    end
    
    return nil
end

-- Function to detect Django project structure
local function detect_django_project()
    local cwd = vim.fn.getcwd()
    local manage_py = vim.fn.findfile('manage.py', cwd .. ';')
    
    if manage_py == '' then
        return nil
    end
    
    local project_root = vim.fn.fnamemodify(manage_py, ':h')
    local apps = {}
    local extra_paths = { project_root }
    
    -- Find Django apps (directories with models.py)
    -- Search in common Django app locations
    local search_paths = {
        project_root .. '/*/models.py',  -- apps in project root
        project_root .. '/*/apps/*/models.py',  -- apps in apps/ directory
    }
    
    for _, pattern in ipairs(search_paths) do
        local model_files = vim.fn.globpath(project_root, pattern, 0, 1)
        for _, model_file in ipairs(model_files) do
            local app_dir = vim.fn.fnamemodify(model_file, ':h')
            -- Add app directory and parent directory (for app-level imports)
            table.insert(apps, app_dir)
            local parent_dir = vim.fn.fnamemodify(app_dir, ':h')
            if parent_dir ~= project_root and not table_contains(extra_paths, parent_dir) then
                table.insert(extra_paths, parent_dir)
            end
        end
    end
    
    -- Also add any directory that looks like a Django app (has models.py, views.py, or admin.py)
    local app_patterns = {
        '**/models.py',
        '**/views.py',
        '**/admin.py',
    }
    
    for _, pattern in ipairs(app_patterns) do
        local files = vim.fn.globpath(project_root, pattern, 0, 1)
        for _, file in ipairs(files) do
            local app_dir = vim.fn.fnamemodify(file, ':h')
            if not table_contains(extra_paths, app_dir) then
                table.insert(extra_paths, app_dir)
            end
        end
    end
    
    return {
        root = project_root,
        apps = apps,
        manage_py = manage_py,
        extra_paths = extra_paths
    }
end

-- Function to get Python interpreter path
local function get_python_interpreter()
    local cwd = vim.fn.getcwd()
    
    -- Check for uv virtual environment first
    local uv_venv = detect_uv_venv()
    if uv_venv then
        local python_path = uv_venv .. '/bin/python'
        if vim.fn.executable(python_path) == 1 then
            return python_path
        end
    end
    
    -- Check for activated virtual environment
    if vim.fn.exists('$VIRTUAL_ENV') == 1 then
        local venv_path = vim.fn.expand('$VIRTUAL_ENV/bin/python')
        if vim.fn.executable(venv_path) == 1 then
            return venv_path
        end
    end
    
    -- Check common virtual environment patterns
    local patterns = {
        '.venv/bin/python',
        'venv/bin/python',
        'env/bin/python',
        '.env/bin/python',
        'virtualenv/bin/python',
    }
    
    for _, pattern in ipairs(patterns) do
        local path = cwd .. '/' .. pattern
        if vim.fn.executable(path) == 1 then
            return path
        end
    end
    
    -- Check for poetry environment
    local poetry_env = vim.fn.systemlist('poetry env info -p 2>/dev/null')
    if #poetry_env > 0 and poetry_env[1] ~= '' then
        local poetry_path = poetry_env[1] .. '/bin/python'
        if vim.fn.executable(poetry_path) == 1 then
            return poetry_path
        end
    end
    
    return 'python3'
end

-- Build dynamic configuration
local function build_pyright_config()
    local cwd = vim.fn.getcwd()
    local extra_paths = {}
    local python_path = get_python_interpreter()
    local venv_path = detect_uv_venv()
    local django_project = detect_django_project()
    
    -- Add current working directory for project-level imports
    table.insert(extra_paths, cwd)
    
    -- If Django project detected, add Django-specific paths
    if django_project then
        for _, path in ipairs(django_project.extra_paths) do
            if not table_contains(extra_paths, path) then
                table.insert(extra_paths, path)
            end
        end
    end
    
    -- If uv venv detected, add site-packages to extraPaths
    if venv_path then
        local site_packages_dirs = vim.fn.globpath(venv_path, 'lib/python*/site-packages', 0, 1)
        for _, sp_dir in ipairs(site_packages_dirs) do
            if not table_contains(extra_paths, sp_dir) then
                table.insert(extra_paths, sp_dir)
            end
        end
    end
    
    -- Build PYTHONPATH
    local pythonpath_parts = { cwd }
    if django_project then
        if not table_contains(pythonpath_parts, django_project.root) then
            table.insert(pythonpath_parts, django_project.root)
        end
        for _, path in ipairs(django_project.extra_paths) do
            if not table_contains(pythonpath_parts, path) then
                table.insert(pythonpath_parts, path)
            end
        end
    end
    local pythonpath = table.concat(pythonpath_parts, ':')
    
    -- Build settings
    local settings = {
        python = {
            pythonPath = python_path,
            venvPath = venv_path and vim.fn.fnamemodify(venv_path, ':h') or nil,
            venv = venv_path and vim.fn.fnamemodify(venv_path, ':t') or nil,
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
                extraPaths = extra_paths,
                stubPath = vim.fn.stdpath("data") .. "/mason/packages/django-stubs",
                django = {
                    enabled = django_project ~= nil,
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
    
    -- Log detection results for debugging
    if django_project then
        vim.notify("Django project detected: " .. django_project.root, vim.log.levels.INFO)
    end
    if venv_path then
        vim.notify("uv virtual environment detected: " .. venv_path, vim.log.levels.INFO)
    end
    
    return settings, pythonpath
end

local pyright_settings, pythonpath = build_pyright_config()

-- Store pythonpath for use in nvim-lspconfig
_G._pyright_pythonpath = pythonpath

return {
    ensure_installed = true,
    settings = pyright_settings,
}