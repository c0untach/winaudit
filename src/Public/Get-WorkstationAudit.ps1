function Get-WorkstationAudit {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$OutputPath = (Get-Location).Path,

        [Parameter()]
        [string[]]$IncludeCategories,

        [Parameter()]
        [switch]$NoAdminCheck
    )

    if (-not $NoAdminCheck) {
        if (-not (Test-IsAdmin)) {
            Write-Warning "Not running as Administrator. Some data may be incomplete."
        }
    }

    $sessionFolder = New-AuditSessionFolder -BasePath $OutputPath

    $collectors = @(
        'Get-AuditNetworkInfo',
        'Get-AuditUsersAndGroups'
        # testing. add more later
    )

    $results = @()

    foreach ($name in $collectors) {
        try {
            $fn = Get-Command -Name $name -ErrorAction Stop
            $obj = & $fn
            if ($IncludeCategories -and ($obj.Category -notin $IncludeCategories)) {
                continue
            }
            $results += $obj
        } catch {
            Write-Warning "Collector '$name' failed: $($_.Exception.Message)"
        }
    }

    $jsonPath = Join-Path $sessionFolder 'audit.json'
    $results | ConvertTo-Json -Depth 6 | Out-File -FilePath $jsonPath -Encoding UTF8

    $htmlPath = Join-Path $sessionFolder 'audit.html'
    Write-AuditHtmlReport -AuditObjects $results -OutputPath $htmlPath | Out-Null

    [PSCustomObject]@{
        SessionFolder = $sessionFolder
        JsonReport    = $jsonPath
        HtmlReport    = $htmlPath
        Items         = $results.Count
    }
}
