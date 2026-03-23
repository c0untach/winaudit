function Write-AuditHtmlReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$AuditObjects,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

function Convert-ValueToHtml {
    param([object]$Value)

    if ($Value -is [string] -and $Value.Contains("`n")) {
        return "<pre>$([System.Web.HttpUtility]::HtmlEncode($Value))</pre>"
    }

    if ($Value -is [System.Collections.IEnumerable] -and
        $Value -notlike [string] -and
        $Value.Count -gt 0 -and
        $Value[0] -isnot [char]) {

        try {
            return ($Value | ConvertTo-Html -Fragment)
        } catch {
            return "<pre>$([System.Web.HttpUtility]::HtmlEncode(($Value | Out-String)))</pre>"
        }
    }

    return $([System.Web.HttpUtility]::HtmlEncode($Value.ToString()))
}


    $sections = foreach ($category in ($AuditObjects.Category | Sort-Object -Unique)) {
        $items = $AuditObjects | Where-Object Category -eq $category

        $tables = foreach ($item in $items) {
            $rows = foreach ($key in $item.Data.Keys) {
                $htmlValue = Convert-ValueToHtml -Value $item.Data[$key]

                [PSCustomObject]@{
                    Name  = $key
                    Value = $htmlValue
                }
            }

            # Build table manually so we can embed HTML safely
            $tableRows = foreach ($r in $rows) {
                "<tr><td><b>$($r.Name)</b></td><td>$($r.Value)</td></tr>"
            }

            @"
<h3>$($item.Collector)</h3>
<table>
<thead><tr><th>Name</th><th>Value</th></tr></thead>
<tbody>
$($tableRows -join "`n")
</tbody>
</table>
"@
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
th, td { border: 1px solid #ccc; padding: 6px 10px; font-size: 13px; vertical-align: top; }
th { background-color: #f0f0f0; text-align: left; }
pre { background: #f7f7f7; padding: 10px; border: 1px solid #ddd; overflow-x: auto; }
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
