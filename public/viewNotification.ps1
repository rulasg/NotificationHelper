function Show-NotificationIssue {
    [CmdletBinding()]
    [alias('vn','View-Notification')]
    param(
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)][string]$Id
    )

    process {
        "Viewing notification with id [$Id] ..." | Write-MyDebug -Section "View-Notification"
        $Notification = getNotification -Id $Id
        if($Notification){
            "Viewing notification with id [$Id] url [$($Notification.Url)] ..." | Write-MyDebug -Section "View-Notification"

            # switch ($Notification.type) {
            #     "Issue" { $command = "ViewNotificationIssue" }
            #     "Discussion" { $command = "ViewNotificationDiscussion" }
            #     default { "Unknown notification type [$($Notification.Type)] for id [$Id]" | Write-MyDebug -Section "View-Notification" }
            # }
            
            # TODO: Display the content of the issue from inside de module.
            # Get content information and later display
            # To allow gh to manage the terminal we can not assign the output of the command.

            gh $($Notification.type.ToLower()) view $Notification.Url

        }
        else{
            "Notification with id [$Id] not found." | Write-MyError
        }
    }
} Export-ModuleMember -Function Show-NotificationIssue -Alias 'vn','View-Notification'
