function Connect-IBSN {
    <#
    .SYNOPSIS
        Abre uma nova sessão com o ServiceNow Rest API.
    .DESCRIPTION
        A sessão é aberta utilizando o 'OAuth authorization code grant flow' no qual exige uma OAuth application no ServiceNow autorizada a realizar as requisições.
        Para maiores detalhes, consulte https://docs.servicenow.com/bundle/rome-platform-administration/page/administer/security/concept/c_OAuthApplications.html
    .PARAMETER InstanceName
        Especifica o nome da Instancia.
    .PARAMETER Credential
        Especifica as credenciais do usuário.
    .PARAMETER AppCredential
        Especifica as credenciais da aplicação Oauth.
    .EXAMPLE
        Connect-IBSN -InstanceName instancia -Username usuario -Password senha -ClientID ID -ClientSecret segredo
    #>
    [CmdletBinding(DefaultParameterSetName='SET1')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$InstanceName,

        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [System.Management.Automation.PSCredential]$AppCredential
    )

    if (Test-OauthSession){
        Write-Warning "Você já está conectado com à instância $($ModuleControlFlags.InstanceName.toUpper())."
    }
    else{
        $ModuleControlFlags.InstanceName = $InstanceName
        $ModuleControlFlags.InstanceURI = "https://$InstanceName.service-now.com"
        $ModuleControlFlags.Credential = $Credential
        $ModuleControlFlags.AppCredential = $AppCredential
        try {
            New-OauthAccessToken -GrantType "password"
        }
        catch {
            Write-Error "$($_.Exception.Message)" -ErrorAction Stop
        }
        Write-Host "[$($ModuleControlFlags.InstanceName.toUpper())] Sessão aberta aberta com sucesso." -ForegroundColor Green
    }
}