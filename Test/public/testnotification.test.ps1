function Test_TestNotification_Found{

    $p = Get-Mock_Notifications
    Mock_Invoke_GetNotifications $p

    # Get list to pick a valid URL
    $list = Get-Notification
    $expected = $list | Select-Object -Index 25
    $url = $expected.Url

    # Act
    $result = Test-Notification -Url $url

    # Assert
    Assert-IsTrue -Condition $result
}

function Test_TestNotification_NotFound{

    $p = Get-Mock_Notifications
    Mock_Invoke_GetNotifications $p

    # Act
    $result = Test-Notification -Url "https://nonexistent-url.com/nothing"

    # Assert
    Assert-IsTrue -Condition (-not $result)
}
