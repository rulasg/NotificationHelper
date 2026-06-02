
class ValidReasons : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $g = Get-Notification
        $ret = $g | Select-Object -ExpandProperty Reason -Unique
        return $ret
    }
}

class ValidType : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $g = Get-Notification
        $ret = $g | Select-Object -ExpandProperty type -Unique
        return $ret
    }
}

class ValidSort : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return @('Id', 'type', 'Reason', 'UnRead', 'Title', 'RepoName', 'RepoOwner', 'Updated')
    }
}

function Show-Notifications {
    [CmdletBinding()]
    [alias('sn')]
    param(
        [Parameter(ValueFromPipelineByPropertyName,ValueFromPipeline, Position = 0)][string]$Id,
        [Parameter()][string]$Url,
        [Parameter()][string]$Title,
        [Parameter()][ValidateSet([ValidType])][string]$Type,
        [Parameter()][ValidateSet([ValidReasons])][string]$Reason,


        [Parameter()][ValidateSet([ValidSort])][string[]]$Sort = 'Updated',

        [Parameter()][switch]$IncludeUnRead,
        [Parameter()][string]$RepoName,
        [Parameter()][string]$RepoOwner,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$PassThru

    )

    process {

        
        # Default is show ownly the unread
        
        $list = @(getNotification -Id $Id | Select-Notification -Url $Url -Title $Title -Type $Type -Reason $Reason -IncludeUnRead:$IncludeUnRead -Force:$Force -RepoName $RepoName -RepoOwner $RepoOwner)
        
        "Listing [$($list.Length)] notifications." | Write-MyDebug -Section "Show-Notifications"
        
        $list = $list | Sort-Object $sort
        
        if($PassThru){
            return [PsCustomObject]$list
        }
        
        $list | Select-Object Id, type, Reason, UnRead, Title, RepoName, RepoOwner, Updated | Format-Table -AutoSize
    }

} Export-ModuleMember -Function Show-Notifications -Alias sn