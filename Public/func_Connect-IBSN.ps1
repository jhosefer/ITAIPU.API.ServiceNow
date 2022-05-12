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

        [Parameter(Mandatory=$false,ParameterSetName='SET1')]
        [System.Management.Automation.PSCredential]$AppCredential
    )

    $ModuleControlFlags.InstanceName = $InstanceName
    $ModuleControlFlags.Credential = $Credential

    if (Test-ServiceNowSession){
        Write-Warning "Você já está conectado com à instância $($ModuleControlFlags.InstanceName.toUpper())."
    }
    else {
        if ($PSBoundParameters.ContainsKey('AppCredential')){            
            $ModuleControlFlags.AppCredential = $AppCredential
            $ModuleControlFlags.AuthType = 'Oauth'
            try {
                New-OauthAccessToken -GrantType "password"
            }
            catch {
                Write-Error "$($_.Exception.Message)" -ErrorAction Stop
            }
            Write-Host "[$($ModuleControlFlags.InstanceName.toUpper())] Sessão aberta aberta com sucesso." -ForegroundColor Green

        }
        else {           
            $RestEndpoint = "api/now/table/incident`?sysparm_limit=1"  # Testa as credenciais com um Get simples na tabela Incident.
            try {
                $Response = Invoke-WebRequest -Uri "https://$($ModuleControlFlags.InstanceName).service-now.com/$RestEndpoint" -ContentType "application/x-www-form-urlencoded" -Method Get -Authentication Basic -Credential $ModuleControlFlags.Credential
            }
            catch {
                Write-Error "$($_.Exception.Message)" -ErrorAction Stop
            }
            if ($Response.StatusCode -eq '200'){
                $ModuleControlFlags.BasicAuthStatus = $true
                $ModuleControlFlags.AuthType = 'Basic'
                Write-Host "[$($ModuleControlFlags.InstanceName.toUpper())] Sessão aberta aberta com sucesso." -ForegroundColor Green
            }
        }
    }
}