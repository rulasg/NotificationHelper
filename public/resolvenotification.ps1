
Set-MyInvokeCommandAlias -Alias ResolveNotification -Command "Invoke-ResolveNotification -Action {action} -Url {url}"

function Resolve-Notification {
    [CmdletBinding()]
    [alias('rn')]
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

        $response = Invoke-MyCommand -Command ResolveNotification -Parameters @{ action = $Action; url = $url }
        
        if ($response) {
            resolveNotification -Id $Id -Action $Action
            return $true
        }
        
        "Something went wrong while resolving notification with id [$Id]. $response" | Write-MyDebug -Section "Resolve-Notification"
        return $false
    }
} Export-ModuleMember -Function Resolve-Notification -Alias rn

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
