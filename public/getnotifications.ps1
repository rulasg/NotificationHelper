
Set-MyInvokeCommandAlias -Alias GetNotifications -Command "Invoke-GetNotifications"

function Get-Notification {
    [CmdletBinding()]
    [alias('gn')]
    param(
        [Parameter(Position=0)][string]$Id,
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
        [Parameter()][switch]$Force
    )
    $params =@{
        Url = $Url
        Title = $Title
        Type = $Type
        Reason = $Reason
        IncludeUnRead = $IncludeUnRead
        RepoName = $RepoName
        RepoOwner = $RepoOwner
        Force = $Force
    }

    # retreive
    if(-Not [string]::IsNullOrEmpty($Id)){
        $ns = getNotification -Id $Id
    } else {
        $ns = getNotification
        $ns = $ns | Select-Notification @params
    }

    $ret = @()
    foreach($n in $ns){
        $ret += [pscustomobject] $n
    }

    return $ret

} Export-ModuleMember -Function Get-Notification -Alias gn

function resolveNotification{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][string]$Id,
        [Parameter(Mandatory)][ValidateSet("Done","Read")][string]$Action
    )

    begin {
        $me = Get-MyHandle
        $cacheKey = "notifications-$me"
    }

    process {
        $db = Get-DatabaseKey -Key $cacheKey -asHashtable

        # Check if the db exists
        if(-not $db){
            "No db found for key [$cacheKey]" | Write-MyDebug -Section "resolveNotifications"
            return
        }

        $noti = $db.$Id

        if(-not $noti){
            "No notification found with id [$Id] in db" | Write-MyDebug -Section "resolveNotifications"
            return
        }

        if($Action -eq "Read"){
            "Marking as read notification with id [$Id] in db..." | Write-MyDebug -Section "resolveNotifications"
            $db.$Id.UnRead = $false
        }

        if($Action -eq "Done"){
            "Removing notification with id [$Id] from db..." | Write-MyDebug -Section "resolveNotifications"
            $db.Remove($Id) | Out-Null
        }
        
        # Saving the db
        Save-DatabaseKey -Key $cacheKey -Value $db
    }
}

function getNotification {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Id
    )

    $me = Get-MyHandle
    $cacheKey = "notifications-$me"

    # Get the database
    if($Force -or ! (Test-DatabaseKey -Key $cacheKey)){
        "Refreshing notifications from github api..." | Write-MyDebug -Section "getNotification"
        $response = Invoke-MyCommand -Command GetNotifications
        Save-DatabaseKey -Key $cacheKey -Value $response
    }

    "Retrieving notifications from database..." | Write-MyDebug -Section "getNotification"
    $db = Get-DatabaseKey -Key $cacheKey -asHashtable

    # Get filter based on Id
    if(! [string]::IsNullOrEmpty($Id)){
        $ret = $db.$Id
        if($ret.id -ne $Id){
            "No notification found with id [$Id]" | Write-MyDebug -Section "getNotification"
            return
        } else {
            "Notifications found by Id: [ $Id ]. In the list: 1" | Write-MyDebug -Section "getNotification"
        }
        return $ret
    }

    $ret = $db.Values

    # Return the full list
    "Returning $($ret.Count) notifications." | Write-MyDebug -Section "getNotification"
    return $ret
}

function Invoke-GetNotifications {
    [cmdletbinding()]
    param()

    "Fetch notifications from github api >>>" | Write-MyDebug -Section "Invoke-GetNotifications"
    $notifications = gh api /notifications --paginate | ConvertFrom-Json -Depth 10
    "Fetch notifications from github api <<<" | Write-MyDebug -Section "Invoke-GetNotifications"

    "fetched {0} notifications." -f $notifications.Length | Write-MyDebug -Section "Invoke-GetNotifications"

    $ret = @{}

    ForEach($n in $notifications){ 

        $url = getContentUrlFromApiUrl $n.subject.url

        $nn = [pscustomobject]@{
            id = $n.id
            Title = $n.subject.title
            type = $n.subject.type
            Url = $url

            UnRead = $n.unread
            Reason  = $n.reason
            Updated = $n.updated_at
            threadUrl = $n.url
            # subscriptionUrl = $n.subscription_url
            
            RepoName    = $n.repository.name
            RepoOwner   = $n.repository.owner.login

        }
        $ret[$nn.id] = $nn
    }

    return $ret
} Export-ModuleMember -Function Invoke-GetNotifications

function getContentUrlFromApiUrl($apiurl){
    if($apiurl -match "https://api.github.com/repos/(.+)/(.+)/(\d+)"){

        $ret =  "https://github.com/$($matches[1])/$($matches[2])/$($matches[3])"

        return $ret
    }
}