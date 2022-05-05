function New-OauthAccessToken {
    <#
    .SYNOPSIS
        Obtem um novo Token Oauth2
    .DESCRIPTION
        Para realizar a autenticação utilizando o Authorization Code Grant Flow é necessário primeiro obter um token OAuth.
        Este token por sua vez é utilizado para realizar todas as requisições à API em vez de fornecer as credenciais de usuário e senha.

        O token pode ser do tipo Access Token ou Refresh token.
    .LINK
        https://docs.servicenow.com/bundle/rome-platform-administration/page/administer/security/concept/c_OAuthApplications.html
    .PARAMETER GrantType
        Especifica o método de autenticação utilizada para obter um novo Access Token.
            - password: Utiliza as credenciais de username/passowrd para realizar a primeira autenticação. Em caso de sucesso obtem um Access Token e um Refresh Token.
            - refresh_token: Utiliza o Refresh Token para obter um novo Access Token. Neste caso, as credenciais não são mais necessárias.
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