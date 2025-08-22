return {
    ensure_installed = true,
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
}