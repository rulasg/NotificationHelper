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

            # Transformation
            switch ($Notification.type) {
                "Issue" { $type = "issue" }
                "Discussion" { $type = "discussion" }
                "PullRequest" { $type = "pr" }
                "AgentSessionThread" { $type = $null }
                Default { $type = $null }
            }

            # Error if type can not be shown
            if (-not $type) {
                "Can't show this notification type [ $($Notification.type) ] for id [$Id]" | Write-MyError
                return
            }

            #Show the notification using the GitHub CLI
            Invoke-NotificationsShow $type $Notification.Url

        }
        else{
            "Notification with id [$Id] not found." | Write-MyError
        }
    }
} Export-ModuleMember -Function Show-NotificationIssue -Alias 'vn','View-Notification'

function Invoke-NotificationsShow {
    [CmdletBinding()]
    param(
        $Type,$Url
    )

     gh $Type view $Url

}

