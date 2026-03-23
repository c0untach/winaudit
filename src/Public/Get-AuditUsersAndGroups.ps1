function Get-AuditUsersAndGroups {
    [CmdletBinding()]
    param()

    $localUsers  = Get-LocalUser  -ErrorAction SilentlyContinue
    $localGroups = Get-LocalGroup -ErrorAction SilentlyContinue
    $groupMembers = foreach ($g in $localGroups) {
        try {
            [PSCustomObject]@{
                Group   = $g.Name
                Members = (Get-LocalGroupMember -Group $g.Name -ErrorAction Stop)
            }
        } catch {
            [PSCustomObject]@{
                Group   = $g.Name
                Members = @()
            }
        }
    }

    [PSCustomObject]@{
        Category      = 'Users & Groups'
        Collector     = 'Get-AuditUsersAndGroups'
        Hostname      = $env:COMPUTERNAME
        Timestamp     = (Get-Date).ToString('o')
        SchemaVersion = '1.0'
        Data          = @{
            LocalUsers   = $localUsers
            LocalGroups  = $localGroups
            GroupMembers = $groupMembers
        }
    }
}
