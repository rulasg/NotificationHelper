
class ValidReasons : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $g = Get-Notification
        $ret = $g | Select-Object -ExpandProperty Reason -Unique
        return $ret
    }
}

class ValidType : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $g = Get-Notification
        $ret = $g | Select-Object -ExpandProperty type -Unique
        return $ret
    }
}

Set-MyInvokeCommandAlias -Alias GetNotifications -Command "Invoke-GetNotifications"

function Get-Notification {
    [CmdletBinding()]
    [alias('gn')]
    param(
        [Parameter(Position=0,ValueFromPipelineByPropertyName)][string]$Id,
        [Parameter()][string]$Url,
        [Parameter()][string]$Title,
        [Parameter()][ValidateSet([ValidType])][string]$Type,
        [Parameter()][ValidateSet([ValidReasons])][string]$Reason,

        [Parameter()][switch]$IncludeUnRead,
        [Parameter()][string]$RepoName,
        [Parameter()][string]$RepoOwner,
        [Parameter()][switch]$Force
    )

    process {

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
    }

} Export-ModuleMember -Function Get-Notification -Alias gn

function Get-NotificationByUrl {
    [CmdletBinding()]
    [alias('gn')]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][string]$Url,
        [Parameter()][switch]$Force
    )

    if([string]::IsNullOrEmpty($Url)){
        "Url parameter is required." | Write-MyDebug -Section "Get-NotificationByUrl"
        return
    }

    $params =@{
        Url = $Url
        Force = $Force
    }

    # retreive
    $ns = getNotification
    $n = $ns | Select-Notification @params

    $ret =[pscustomobject] $n
    return $ret

} Export-ModuleMember -Function Get-NotificationByUrl

function Update-Notifications{
    [CmdletBinding()]
    [alias('un')]
    param()

    $result = Get-Notification -Force

    "Updated notifications. Total count: $($result.Count)" | Write-MyHost

} Export-ModuleMember -Function Update-Notifications -Alias un

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

        $owner = $matches[1]
        $type = $matches[2]
        $number = $matches[3]

        switch ($type){
            "pulls" { $type = "pull" }
            default { $type = $type }
        }

        $ret =  "https://github.com/$owner/$type/$number"

        return $ret
    }
}