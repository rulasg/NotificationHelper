function Resolve-Notification {
    [CmdletBinding()]
    [alias('rn')]
    param (
        [parameter(ValueFromPipeline, Position=0)][object]$Notification,
        [parameter()][switch]$MarkAsDone
    )

    begin {
        $methord = if($MarkAsDone) { "DELETE" } else { "PATCH" }
    }

    process {

        $url = $Notification.threadUrl

        Write-Verbose -Message "Resolving notification with id [$($Notification.id)] using method [$methord] on url [$url] ..."
        
        $response = gh api --method $methord $url
        
        return $response
    }
} Export-ModuleMember -Function Resolve-Notification -Alias rn