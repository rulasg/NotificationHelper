function Get-NotificationsNotInProject{
    [CmdletBinding()]
    [Alias('gnnip')]
    param(
        #owner
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        # reponmae
        [Parameter()][string]$RepoName,
        [Parameter()][string]$RepoOwner,
        [Parameter()][switch]$Force
    )

    $n = get-Notification -Force:$Force

    # Filter by type. Get Just Issues and Pull Requests
    $n = $n | where-object { $_.Type -eq 'Issue' -or $_.Type -eq 'PullRequest' }

    if(-Not [string]::IsNullOrEmpty($RepoName)){
        $n = $n | where-object { $_.RepoName -eq $RepoName }
    }

    if(-Not [string]::IsNullOrEmpty($RepoOwner)){
        $n = $n | where-object { $_.RepoOwner -eq $RepoOwner }
    }

    $ret = @()

    $n | ForEach-Object{ 
        $i = gpibu $_.Url -Owner $Owner -ProjectNumber $ProjectNumber
         if( $null -eq $i){
            $ret += $_
        }
    }

    return $ret

} export-ModuleMember -Function Get-NotificationsNotInProject -Alias gnnip