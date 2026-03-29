function Test-Notification {
     [cmdletbinding()]
     [alias('tn')]
     param(
         [string]$Url
     )
 

    process {
        $list = @(getNotification | Select-Notification -Url $Url )


        if($list){
            "Notification with url [$Url] exists." | Write-MyDebug -Section "Test-Notification"
            return $true
        } else {
            "Notification with url [$Url] does not exist." | Write-MyDebug -Section "Test-Notification"
            return $false
        }
    }
} Export-ModuleMember -Function Test-Notification -Alias tn