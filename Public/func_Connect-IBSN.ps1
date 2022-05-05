function Connect-IBSN {
    <#
    .SYNOPSIS
        Abre uma nova sessão com o ServiceNow Rest API.
    .DESCRIPTION
        A sessão é aberta utilizando o 'OAuth authorization code grant flow' no qual exige uma OAuth application no ServiceNow autorizada a realizar as requisições.
        Para maiores detalhes, consulte https://docs.servicenow.com/bundle/rome-platform-administration/page/administer/security/concept/c_OAuthApplications.html
    .PARAMETER InstanceName
        Especifica o nome da Instancia.
    .PARAMETER ClientID
        Especifica o Cliente ID do Oauth Application.
    .PARAMETER ClientSecret
        Especifica o Secret do Oauth Application.
    .PARAMETER Username
        Especifica o Username autorizado a realizar a autenticação na API.
    .PARAMETER Password
        Especifica a senha do usuário.
    .EXAMPLE
        Connect-IBSN -InstanceName instancia -Username usuario -Password senha -ClientID ID -ClientSecret segredo
    #>
    [CmdletBinding(DefaultParameterSetName='SET1')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$InstanceName,

        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$ClientID,

        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$ClientSecret,

        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$Username,

        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$Password
    )

    if (Test-OauthSession){
        Write-Warning "Você já está conectado com à instância $($ModuleControlFlags.InstanceName.toUpper())."
    }
    else{
        $ModuleControlFlags.InstanceName = $InstanceName
        $ModuleControlFlags.InstanceURI = "https://$InstanceName.service-now.com"
        $ModuleControlFlags.ClientID = $ClientID
        $ModuleControlFlags.ClientSecret = $ClientSecret
        $ModuleControlFlags.Username = $Username
        $ModuleControlFlags.Password = $Password

        try {
            New-OauthAccessToken -GrantType "password"
        }
        catch {
            Write-Error "$($_.Exception.Message)" -ErrorAction Stop
        }
        Write-Host "[$($ModuleControlFlags.InstanceName.toUpper())] Sessão aberta aberta com sucesso." -ForegroundColor Green
    }
}