function Show-Notifications {
    [CmdletBinding()]
    [alias('sn')]
    param(
        [Parameter(Position = 0)][string]$Id,
        [Parameter()][string]$Url,
        [Parameter()][string]$Title,
        [Parameter()][ValidateSet("Issue","Discussion","PullRequest","Release")][string]$Type,
        [Parameter()][ValidateSet(
            "assign",
            "subscribed",
            "comment",
            "author",
            "team_mention",
            "mention",
            "state_change",
            "manual"
        )][string]$Reason,

        [Parameter()][switch]$IncludeUnRead,
        [Parameter()][string]$RepoName,
        [Parameter()][string]$RepoOwner,
        [Parameter()][switch]$Force,
        [Parameter()][string[]]$Sort
    )

    # Default is show ownly the unread

    $list = @(getNotification -Id $Id | Select-Notification -Url $Url -Title $Title -Type $Type -Reason $Reason -IncludeUnRead:$IncludeUnRead -Force:$Force -RepoName $RepoName -RepoOwner $RepoOwner)

    "Listing [$($list.Length)] notifications." | Write-MyDebug -Section "Show-Notifications"

    $list | Select-Object Id, type, Reason, UnRead, Title, RepoName, RepoOwner, Updated | Sort-Object $Sort | Format-Table -AutoSize

} Export-ModuleMember -Function Show-Notifications -Alias sn