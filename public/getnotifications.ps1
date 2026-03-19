
function Get-Notification {
    [CmdletBinding()]
    [alias('gn')]
    param(
        [Parameter(Position=0)][string]$Id,
        [Parameter()][string]$Url,
        [Parameter()][string]$Title,
        [Parameter()][switch]$Force
    )

    $me = Get-MyHandle
    $cacheKey = "notifications-$me"

    # Get the database
    if($Force -or ! (Test-DatabaseKey -Key $cacheKey)){
        "Refreshing notifications from github api..." | Write-MyDebug -Section "getNotifications"
        $response = Invoke-GetNotifications
        Save-DatabaseKey -Key $cacheKey -Value $response
    }

    "Retrieving notifications from database..." | Write-MyDebug -Section "getNotifications"
    $ret = Get-DatabaseKey -Key $cacheKey -asHashtable
    
    # Get filter based on Id
    if(! [string]::IsNullOrEmpty($Id)){
        "Filtering notifications by Id: $Id" | Write-MyDebug -Section "getNotifications"
        $ret = $ret.$Id
        return $ret
    }

    if(! [string]::IsNullOrEmpty($Title)){
        "Filtering notifications by Title: $Title" | Write-MyDebug -Section "getNotifications"
        $ret = $ret.Values | Where-Object { $_.Title -like "*$Title*" }
        return $ret
    }

    if(! [string]::IsNullOrEmpty($Url)){
        "Filtering notifications by Url: $Url" | Write-MyDebug -Section "getNotifications"
        $ret = $ret.Values | Where-Object { $_.Url -eq $Url }
        return $ret
    }

    # Return the full list
    "Returning all notifications." | Write-MyDebug -Section "getNotifications"
    return $ret

} Export-ModuleMember -Function Get-Notification -Alias gn

function Invoke-GetNotifications {
    [cmdletbinding()]
    param()

    "Fetch notifications from github api >>>" | Write-MyDebug -Section "getNotifications"
    $notifications = gh api /notifications --paginate | ConvertFrom-Json -Depth 10
    "Fetch notifications from github api <<<" | Write-MyDebug -Section "getNotifications"

    "fetched {0} notifications." -f $notifications.Count | Write-MyDebug -Section "getNotifications"

    $ret = @{}

    ForEach($n in $notifications){ 

        $url = geturl $n.subject.url

        $nn = [pscustomobject]@{
            id = $n.id
            Title = $n.subject.title
            type = $n.subject.type
            Url = $url

            InRead = $n.unread
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

function geturl($apiurl){
    if($apiurl -match "https://api.github.com/repos/(.+)/(.+)/(\d+)"){

        $ret =  "https://github.com/$($matches[1])/$($matches[2])/$($matches[3])"

        return $ret
    }
}