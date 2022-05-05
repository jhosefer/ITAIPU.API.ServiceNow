function Test-OauthSession {
    <#
    .SYNOPSIS
        Valida se a sessão com a Rest API ainda é valida.
    .DESCRIPTION
        Valida se o token de acesso está valido ou se já expirou. Em caso de expiração, esta função utiliza o Refresh Token para solicitar um novo token de acesso.
    .OUTPUTS
        Retorna Verdadeiro se o Token está valido, ou falso se há algum problema com a sessão.
    #>
 
    if($ModuleControlFlags.AccessToken){
        if($ModuleControlFlags.ExpirationDate -gt $(Get-Date)){
            return $true
        }
        else{
            Write-Warning "[$($ModuleControlFlags.InstanceName.toUpper())] Renovando sessão com a instância."
            try {
                New-OauthAccessToken -GrantType refresh_token
                return $true
            }
            catch {
                Write-Error "$($_.Exception.Message)"
                return $false
            }
        }
    }
    else{
        return $false
    }
}