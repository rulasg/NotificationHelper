
Set-MyInvokeCommandAlias -Alias ResolveNotification -Command "Invoke-ResolveNotification -Action {action} -Url {url}"

function Read-Notification {
    [CmdletBinding()]
    [alias('rn')]
    param(
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)][string]$Id
    )

    process {
        Resolve-Notification -Id $Id -Action "Read"
    }
} Export-ModuleMember -Function Read-Notification -Alias rn

function Remove-Notification {
    [CmdletBinding()]
    [alias('dn')]
    param(
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)][string]$Id
    )

    process {
        Resolve-Notification -Id $Id -Action "Done"
    }
} Export-ModuleMember -Function Remove-Notification -Alias dn

function Resolve-Notification {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)][string]$Id,
        [Parameter(Position = 1)][ValidateSet("Done","Read")][string]$Action = "Read"
    )

    process {

        "Resolving notification with id [$Id] action [$Action] ..." | Write-MyDebug -Section "Resolve-Notification"

        $Notification = getNotification -Id $Id
        
        if(-not $Notification){
            "No notification found with id [$Id]" | Write-MyDebug -Section "Resolve-Notification"
            return $false
        }
        
        if($action -eq "Read" -and $Notification.IsRead){
            "Notification with id [$Id] is already marked as read." | Write-MyDebug -Section "Resolve-Notification"
            return $true
        }
        
        $url = $Notification.threadUrl

        if ($PSCmdlet.ShouldProcess($id, "ResolveNotification")) {
            # Call api
            $response = Invoke-MyCommand -Command ResolveNotification -Parameters @{ action = $Action; url = $url }
            if ($response) {
                # Remove from cache
                resolveNotification -Id $Id -Action $Action
                return $true
            }
        } else {
            return $true
        }
        
        
        "Something went wrong while resolving notification with id [$Id]. $response" | Write-MyDebug -Section "Resolve-Notification"
        return $false
    }
}

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

function Invoke-ResolveNotification {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][string]$Url,
        [Parameter(Mandatory)][ValidateSet("Done","Read")][string]$Action
    )

    $methord = if ($Action -eq "Done") { "DELETE" } else { "PATCH" }

    "Resolving [$methord] for [$Url] >>>" | Write-MyDebug -Section "Invoke-ResolveNotification"
    $response = gh api --method $methord $url
    "Resolving [$methord] for [$Url] <<<" | Write-MyDebug -Section "Invoke-ResolveNotification"

    if($null -eq $response){
        "Resolve successful [$methord] for [$Url]" | Write-MyDebug -Section "Invoke-ResolveNotification"
        return $true
    } else {
        "Failed to resolve notification [$methord] for [$Url]. Response: $response" | Write-MyDebug -Section "Invoke-ResolveNotification"
        return $false
    }
} Export-ModuleMember -Function Invoke-ResolveNotification
