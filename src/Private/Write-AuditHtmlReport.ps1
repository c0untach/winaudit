function Write-AuditHtmlReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$AuditObjects,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    function Render-Value {
        param([object]$Value)

        if ($null -eq $Value) {
            return "<i>(none)</i>"
        }

        # Multiline text
        if ($Value -is [string] -and $Value.Contains("`n")) {
            return "<pre>$([System.Web.HttpUtility]::HtmlEncode($Value))</pre>"
        }

        # Array of strings
        if ($Value -is [string[]]) {
            if ($Value.Count -eq 0) { return "<i>(none)</i>" }
            $items = $Value | ForEach-Object { "<li>$([System.Web.HttpUtility]::HtmlEncode($_))</li>" }
            return "<ul>$($items -join '')</ul>"
        }

        # Array of objects
        if ($Value -is [System.Collections.IEnumerable] -and
            $Value -notlike [string] -and
            $Value.Count -gt 0 -and
            $Value[0] -isnot [char]) {

            try {
                return ($Value | ConvertTo-Html -Fragment)
            }
            catch {
                return "<pre>$([System.Web.HttpUtility]::HtmlEncode(($Value | Out-String)))</pre>"
            }
        }

        # Single object
        if ($Value -is [psobject] -and $Value.PSObject.Properties.Count -gt 0) {
            try {
                return ($Value | ConvertTo-Html -Fragment)
            }
            catch {
                return "<pre>$([System.Web.HttpUtility]::HtmlEncode(($Value | Out-String)))</pre>"
            }
        }

        # Scalar
        return $([System.Web.HttpUtility]::HtmlEncode($Value.ToString()))
    }

    # Build sections
    $sections = foreach ($category in ($AuditObjects.Category | Sort-Object -Unique)) {
        $items = $AuditObjects | Where-Object Category -eq $category

        $tables = foreach ($item in $items) {

            # Render each property as its own table
            $propertyTables = foreach ($key in $item.Data.Keys) {
                $htmlValue = Render-Value -Value $item.Data[$key]

                @"
<h4>$key</h4>
<table>
<tr><th>Value</th></tr>
<tr><td>$htmlValue</td></tr>
</table>
"@
            }

            @"
<h3>$($item.Collector)</h3>
$($propertyTables -join "`n")
"@
        }

        @"
<h2>$category</h2>
$($tables -join "`n")
"@
    }

    # Metadata
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
ul { margin: 0; padding-left: 20px; }
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
