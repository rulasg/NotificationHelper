
function Get-Mock_Notifications{

    $ret = @{
        notifications_filename = "Invoke-GetNotifications.json"
        notifications_totalcount = 95
        notification_Id = "223174908960"
        
        notifications_RepoOwner = "github"
        notifications_RepoOwner_Count_All = 31
        notifications_RepoOwner_Count_UnRead = 30
        
        notifications_RepoName = "bit21"
        notifications_RepoName_Count = 2
        
        notifications_Type = "Discussion"
        notifications_Type_Count_All = 18
        notifications_Type_Count_UnRead = 17

        notifications_Reason = "comment"
        notifications_Reason_Count_All = 13
        notifications_Reason_Count_UnRead = 12

        notifications_Title = "copilot"
        notifications_Title_Count_All = 17
        notifications_Title_Count_UnRead = 16




    }

    return $ret

}

function MockHandle{
    MockCallToString -Command 'gh api user --jq ".login"' -Outstring "mockHandle"
}

function Mock_Invoke_GetNotifications($mock_info){
    
    Mock_Database
    MockHandle
    MockCallJson -Command 'Invoke-GetNotifications' -filename $mock_info.notifications_filename
}