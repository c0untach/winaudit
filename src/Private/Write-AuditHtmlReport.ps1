function Write-AuditHtmlReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$AuditObjects,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $sections = foreach ($category in ($AuditObjects.Category | Sort-Object -Unique)) {
        $items = $AuditObjects | Where-Object Category -eq $category

        $tables = foreach ($item in $items) {
            # Flatten Data hashtables into a table-friendly object list
            $data = $item.Data
            if ($data -is [System.Collections.IDictionary]) {
                $rows = foreach ($key in $data.Keys) {
                    [PSCustomObject]@{
                        Name  = $key
                        Value = ($data[$key] | Out-String).Trim()
                    }
                }
            } else {
                $rows = [PSCustomObject]@{
                    Name  = 'Data'
                    Value = ($data | Out-String).Trim()
                }
            }

            $rows | ConvertTo-Html -Fragment -PreContent "<h4>$($item.Collector)</h4>"
        }

        @"
<h2>$category</h2>
$($tables -join "`n")
"@
    }

    $meta = $AuditObjects | Select-Object -First 1

    $head = @"
<title>Workstation Audit - $($meta.Hostname)</title>
<style>
body { font-family: Segoe UI, Arial, sans-serif; margin: 20px; }
h1, h2, h3, h4 { color: #333; }
table { border-collapse: collapse; margin-bottom: 20px; width: 100%; }
th, td { border: 1px solid #ccc; padding: 4px 8px; font-size: 12px; }
th { background-color: #f0f0f0; text-align: left; }
.code { font-family: Consolas, monospace; white-space: pre; }
.meta { font-size: 12px; color: #666; margin-bottom: 20px; }
</style>
"@

    $header = @"
<h1>Workstation Audit Report</h1>
<div class="meta">
    <div><b>Hostname:</b> $($meta.Hostname)</div>
    <div><b>Generated:</b> $([DateTime]::Now.ToString('u'))</div>
    <div><b>SchemaVersion:</b> $($meta.SchemaVersion)</div>
</div>
"@

    $html = ConvertTo-Html -Head $head -Body ($header + ($sections -join "`n")) -Title "Workstation Audit"

    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    return $OutputPath
}
