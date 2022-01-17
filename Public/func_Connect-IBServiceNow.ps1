function Connect-IBServiceNow {
    <#
    .SYNOPSIS
        Abre uma sessão com a Microsoft Graph API
    .DESCRIPTION
        Abre uma sessão com a Microsoft Graph API
        Para utilizar esta função, é necessário que uma aplicação já esteja registrada no tenant com as devidas permissões.
    .PARAMETER TenantID
        Especifica o identificador do Tenant
    .PARAMETER ClientID
        Especifica o identificador da aplicação.
    .PARAMETER ClientSecret
        Especifica o o segredo da aplicação.
    .PARAMETER ClientCert
        Especifica o certificado da aplicação.
    .PARAMETER Interactive
        Especifica se a conexão deverá ser aberta em modo interativo.
    .PARAMETER ClientCertThumbprint
        Especifica o thumbprint do certificado da aplicação. 
    .EXAMPLE
        New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -Subject "myname" -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeyExportPolicy NonExportable -KeySpec Signature | Export-Certificate -FilePath ~\Downloads\Certificate.cer
        Connect-IBEWS -TenantId "xxx" -ClientID 'yyy' -ClientCertThumbPrint '1234'

        Neste exemplo, é criado um certificado autoassinado na máquina. Este certificado é configurado na Aplicação no Azure AD afim de utilizá-lo na autenticação.

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