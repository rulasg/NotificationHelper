function Select-Notification {
    [CmdletBinding()]
    [alias('wn')]
    param(

        [Parameter(ValueFromPipeline)][object[]]$notification,
        [Parameter(Position=0)][string]$Id,
        [Parameter()][string]$Url,
        [Parameter()][string]$Title,
        [Parameter()][string]$RepoName,
        [Parameter()][string]$RepoOwner,
        [Parameter()][string]$Type,
        [Parameter()][string]$Reason,
        [Parameter()][switch]$IncludeUnRead,
        [Parameter()][switch]$Force
    )

    begin{
        $list = @()
    }

    process{
        $list += $notification
    }
    end{

        # Get filter based on Id
        if(! [string]::IsNullOrEmpty($Id)){
            $ret = $list | Where-Object { $_.id -eq $Id }
            "Find notifications by Id: [ $Id ]. In the list: $($ret.Length)" | Write-MyDebug -Section "selectNotifications"
            return $ret
        }
        
        # Find by Url
        if(! [string]::IsNullOrEmpty($Url)){
            $ret = $list | Where-Object { $_.Url -eq $Url }
            "Find notifications by Url: [ $Url ]. In the list: $($ret.Length)" | Write-MyDebug -Section "selectNotifications"
            return $ret
        }

        $ret = $list
        "All notifications in the list: $($ret.Count)" | Write-MyDebug -Section "selectNotifications"

        # Filter by UnRead    if($UnRead){
        if(-Not $IncludeUnRead){
            $before = $ret.Count
            $ret = @($ret | Where-Object { $_.UnRead -eq $true })
            $after = $ret.Count
            "Filtered notifications by UnRead: Filtered [$($before - $after)] Left: [$($ret.Length)]" | Write-MyDebug -Section "selectNotifications"
        }
        
        # Filter by RepoOwner
        if(! [string]::IsNullOrEmpty($RepoOwner)){
            $before = $ret.Count
            "Filtering notifications by RepoOwner: $RepoOwner" | Write-MyDebug -Section "selectNotifications"
            $ret = @($ret | Where-Object { $_.RepoOwner -eq "$RepoOwner" })
            $after = $ret.Count
            "Filtered notifications by RepoOwner: Filtered [$($before - $after)] Left: [$($ret.Length)]" | Write-MyDebug -Section "selectNotifications"
        }
        
        # Filter by RepoName
        if(! [string]::IsNullOrEmpty($RepoName)){
            $before = $ret.Count
            $ret = @($ret | Where-Object { $_.RepoName -like "*$RepoName*" })
            $after = $ret.Count
            "Filtered notifications by RepoName: Filtered [$($before - $after)] Left: [$($ret.Length)]" | Write-MyDebug -Section "selectNotifications"
        }
        
        # Filter by Type
        if(! [string]::IsNullOrEmpty($Type)){
            $before = $ret.Count
            $ret = @($ret | Where-Object { $_.type -eq $Type })
            $after = $ret.Count
            "Filtered notifications by Type: Filtered [$($before - $after)] Left: [$($ret.Length)]" | Write-MyDebug -Section "selectNotifications"
        }
        
        # Filter by Reason
        if(! [string]::IsNullOrEmpty($Reason)){
            $before = $ret.Count
            $ret = @($ret | Where-Object { $_.Reason -eq $Reason })
            $after = $ret.Count
            "Filtered notifications by Reason: Filtered [$($before - $after)] Left: [$($ret.Length)]" | Write-MyDebug -Section "selectNotifications"
        }
        
        # Filter by Title
        if(! [string]::IsNullOrEmpty($Title)){
            $before = $ret.Count
            $ret = @($ret | Where-Object { $_.Title -like "*$Title*" })
            $after = $ret.Count
            "Filtered notifications by Title: Filtered [$($before - $after)] Left: [$($ret.Length)]" | Write-MyDebug -Section "selectNotifications"
        }
        
        # Return the full list
        "Returning $($ret.Length) notifications." | Write-MyDebug -Section "selectNotifications"
        return $ret
    }

} Export-ModuleMember -Function Select-Notification -Alias wn