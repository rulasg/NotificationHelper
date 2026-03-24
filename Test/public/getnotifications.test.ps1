function Test_GetNotifications{

    $p = Get-Mock_Notifications
    $totalCount = $p.notifications_totalcount

    Mock_Invoke_GetNotifications $p

    # Act
    $result = Get-Notification

    # Assert
    Assert-Count -Expected $totalCount -Presented $result

}
