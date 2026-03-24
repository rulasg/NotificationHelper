function Test_SelectNotifications_SUCCESS{

    $p = Get-Mock_Notifications
    $id = $p.notification_Id

    Mock_Invoke_GetNotifications $p

    # Get List
    $list = Get-Notification
    Assert-Count -Expected $p.notifications_totalcount -Presented $list

    # Set some unread
    $some_Unread = @(1,12,24,34,26)
    $some_Unread | ForEach-Object { $list[$_].UnRead = $false }

    # Select a random noti
    $expected = $list | Select-Object -Index 25

    # Id
    $id = $expected.Id
    $result = $list | Select-Notification -Id $id
    Assert-AreEqual -Expected $id -Presented $result.Id

    # Url
    $url = $expected.Url
    $result = $list | Select-Notification -Url $url
    Assert-AreEqual -Expected $url -Presented $result.Url

    # All / UnRead
    # all 
    $result = $list | Select-Notification
    Assert-Count -Expected ($list.Count - $some_Unread.Count) -Presented $result
    
    # UnRead
    $result = $list | Select-Notification -IncludeUnRead
    Assert-Count -Expected $p.notifications_totalcount -Presented $result

    # RepoOwner
    $result = $list | Select-Notification -RepoOwner $p.notifications_RepoOwner
    Assert-Count -Expected $p.notifications_RepoOwner_Count_UnRead -Presented $result

    # RepoName
    $result = $list | Select-Notification -RepoName $p.notifications_RepoName
    Assert-Count -Expected $p.notifications_RepoName_Count -Presented $result
    
    # Type
    $result = $list | Select-Notification -Type $p.notifications_Type
    Assert-Count -Expected $p.notifications_Type_Count_UnRead -Presented $result
    
    # Reason
    $result = $list | Select-Notification -Reason $p.notifications_Reason
    Assert-Count -Expected $p.notifications_Reason_Count_UnRead -Presented $result

    # Title
    $result = $list | Select-Notification -Title $p.notifications_Title
    Assert-Count -Expected $p.notifications_Title_Count_UnRead -Presented $result

}