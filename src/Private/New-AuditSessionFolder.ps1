function New-AuditSessionFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath
    )

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $folder = Join-Path $BasePath "Audit-$($env:COMPUTERNAME)-$timestamp"
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
    return $folder
}
