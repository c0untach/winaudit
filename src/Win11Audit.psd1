@{
    RootModule        = 'Win11Audit.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '00000000-0000-0000-0000-000000000001'
    Author            = 'c0untach'
    CompanyName       = 'n/a'
    Copyright         = '(c) c0untach'
    Description       = 'Windows 11 Workstation Auditing Module'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Get-WorkstationAudit',
        'Get-AuditNetworkInfo',
        'Get-AuditUsersAndGroups'
    )

    PrivateData = @{
        PSData = @{
            Tags        = @('Audit','Security','Windows11')
            ProjectUri  = 'https://github.com/c0untach/winaudit'
        }
    }
}
