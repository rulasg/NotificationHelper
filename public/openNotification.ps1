function Open-Notification {
    [alias('on')]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][string]$Id
    )

    process {
        "Opening notification with id [$Id] ..." | Write-MyDebug -Section "Open-Notification"
        $Notification = getNotification -Id $Id
        if($Notification){
            "Opening notification with id [$Id] url [$($Notification.Url)] ..." | Write-MyDebug -Section "Open-Notification"
            Open-MyUrl $Notification.Url
        }
        else{
            "Notification with id [$Id] not found." | Write-MyDebug -Section "Open-Notification"
        }
    }
} Export-ModuleMember -Function Open-Notification -Alias on