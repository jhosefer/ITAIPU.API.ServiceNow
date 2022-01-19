function New-OauthAccessToken {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .PARAMETER Name
        Specifies the file name.
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None. You cannot pipe objects to Add-Extension.
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('password','refresh_token')]
        [string]$GrantType
    )
    
    $RestEndpoint = "/oauth_token.do"

    if ($GrantType -eq 'password'){
        $Body = @{
            grant_type = $GrantType
            username = $ModuleControlFlags.Username
            password = $ModuleControlFlags.Password
            client_id = $ModuleControlFlags.ClientID
            client_secret =$ModuleControlFlags.ClientSecret
        }
    }
    else {
        $Body = @{
            grant_type = $GrantType
            client_id = $ModuleControlFlags.ClientID
            client_secret =$ModuleControlFlags.ClientSecret
            refresh_token = $ModuleControlFlags.RefreshToken
        }
    }

    $Token = Invoke-RestMethod -Uri "$($ModuleControlFlags.InstanceURI)/$RestEndpoint" -Body $Body -ContentType "application/x-www-form-urlencoded" -Method Post
    if ($Token) {
        $ModuleControlFlags.AccessToken = $Token.access_token
        $ModuleControlFlags.RefreshToken = $Token.refresh_token
        $ModuleControlFlags.ExpirationDate = (Get-date).AddSeconds($Token.expires_in)
    }

}