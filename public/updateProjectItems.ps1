
function Get-NotificationsProjectItemValueEditParameters {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][object]$Item,
        # FieldName
        [Parameter()][string]$FieldName = "NextUp",
        [Parameter()][string]$Value = "🔔",

        [Parameter()][switch]$Force
    )

    begin {

        # Retrive notifications
        $notis = Get-Notification -Force:$Force
        if(-not $notis){
            "No notifications found."| Write-MyDebug -Section "Update-NotificationsProjectItema"
            $noRun = $true
            return
        } else {
            "Retrieved $($notis.Count) notifications" | Write-MyDebug -Section "Update-NotificationsProjectItema"
        }
    }

    process {

        if($noRun) {return}

        $id = $Item.id
        $url = $Item.url
        $projectUrl = $item.projectUrl
        if(-not $id ){
             "Item is missing id, skipping..." | Write-MyDebug -Section "Update-NotificationsProjectItema"
             return
        }
        if(-not $url ){
             "Item is missing url, skipping..." | Write-MyDebug -Section "Update-NotificationsProjectItema"
             return
        }

         if(-not $projectUrl ){
             "Item is missing projectUrl, skipping..." | Write-MyDebug -Section "Update-NotificationsProjectItema"
             return
        }

        # Find notification by url
        $noti = $notis.values | Where-Object { $_.Url -eq $url }
        if(! $noti){
            "No notification found for item with url '$url'" | Write-Debug -Section "Update-NotificationsProjectItema"
            return
        }

        # Extract owner and projectnumber from projecturl like " https://github.com/orgs/github/projects/9279"
        $owner,$projectNumber = extractOwnerAndProjectNumberFromUrl $projectUrl
        if(-not $owner -or -not $projectNumber){
            "Could not extract owner or project number from url '$url'" | Write-MyDebug -Section "Update-NotificationsProjectItema"
            return
        }

        #Create parameters to update
        $fields = [PSCustomObject]@{
            Owner = $owner
            ProjectNumber = $projectNumber
            Id = $item.id
            FieldName = $FieldName
            Value = $Value
        }
        
        return $fields
    }

} Export-ModuleMember -Function Get-NotificationsProjectItemValueEditParameters

function extractOwnerAndProjectNumberFromUrl {
    param(
        [Parameter(Position = 0)][string]$Url
    )

    # Example url:  https://github.com/orgs/github/projects/9279"

    $split = $Url -split "/"
    $owner = $split[4]
    $projectNumber = $split[6]

    return $owner, $projectNumber
}