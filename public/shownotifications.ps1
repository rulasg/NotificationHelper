function Show-Notifications {
    [CmdletBinding()]
    [alias('sn')]
    param(
        [Parameter(Position=0)][string]$Id,
        [Parameter()][string]$Url,
        [Parameter()][string]$Title,
        [Parameter()][switch]$Force
    )

    $list = Get-Notification -Id $Id -Url $Url -Title $Title -Force:$Force

    $list.Values | Select-Object Id,type,Reason,Title,RepoName,RepoOwner,Updated

} Export-ModuleMember -Function Show-Notifications -Alias sn