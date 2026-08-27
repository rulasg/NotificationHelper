function Get-NotificationsNotInProject{
    [CmdletBinding()]
    [Alias('gnnip')]
    param(
        #owner
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][string]$RepoName,
        [Parameter()][string]$RepoOwner,
        [Parameter()][switch]$Force
    )

    $n = get-Notification -Force:$Force

    # Filter by type. Get Just Issues and Pull Requests
    $n = $n | where-object { $_.Type -eq 'Issue' -or $_.Type -eq 'PullRequest' }

    # Filter by RepoName
    if(-Not [string]::IsNullOrEmpty($RepoName)){
        $n = $n | where-object { $_.RepoName -eq $RepoName }
    }

    # Filter by RepoOwner
    if(-Not [string]::IsNullOrEmpty($RepoOwner)){
        $n = $n | where-object { $_.RepoOwner -eq $RepoOwner }
    }

    # With $n that contains $_.url , Find-NotInProject
    # Will return all the items in $n with a url that 
    # is not part of the active project
    $ret = $n | ProjectHelper\Find-NotInProject

    return $ret

} export-ModuleMember -Function Get-NotificationsNotInProject -Alias gnnip

function Show-NotificationsNotInProject{
    [CmdletBinding()]
    [Alias('snnip')]
    param(
        #owner
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][string]$RepoName,
        [Parameter()][string]$RepoOwner,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$PassThru,
        [Parameter(Position=0)][string]$Filter
    )

    $params = @{
        Owner = $Owner
        ProjectNumber = $ProjectNumber
        RepoName = $RepoName
        RepoOwner = $RepoOwner
        Force = $Force
    }

    # Get the notifications not in the project
    $n = Get-NotificationsNotInProject @params

    # Filter by title if a filter is provided
    if (-Not [string]::IsNullOrEmpty($Filter)) {
        $n = $n | Where-Object { $_.Title -like "*$Filter*" }
    }

    # If PassThru is specified, return the raw notifications; otherwise, select specific properties for display
    if ($PassThru) {
        return $n
    }

    $n | Select-Object id,Title,RepoName
} Export-ModuleMember -Function Show-NotificationsNotInProject -Alias snnip