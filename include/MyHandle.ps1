Set-MyInvokeCommandAlias -Alias GetGhHandle -Command 'gh api user --jq ".login"'

function Get-MyHandle{
    [CmdletBinding()]
    param(
        [Parameter()][switch]$Force
    )

    if($script:me -and -not $Force){
        return $script:me
    }

    $user = Invoke-MyCommand -Command GetGhHandle

    $script:me = $user

    return $user
}