function Get-AuditNetworkInfo {
    [CmdletBinding()]
    param()

    $ipConfig = ipconfig /all | Out-String
    $routes   = route print | Out-String
    $arp      = arp -a | Out-String
    $dns      = Get-DnsClientServerAddress -ErrorAction SilentlyContinue
    $netAdapters = Get-NetAdapter -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Category      = 'Network'
        Collector     = 'Get-AuditNetworkInfo'
        Hostname      = $env:COMPUTERNAME
        Timestamp     = (Get-Date).ToString('o')
        SchemaVersion = '1.0'
        Data          = @{
            IpConfig    = $ipConfig
            Routes      = $routes
            ArpTable    = $arp
            DnsConfig   = $dns
            NetAdapters = $netAdapters
        }
    }
}
