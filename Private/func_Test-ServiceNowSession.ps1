function Test-ServiceNowSession {
    <#
    .SYNOPSIS
        Valida se a sessão com a Rest API ainda é valida.
    .DESCRIPTION
        Em caso de autenticação básica o teste é realizado com uma consulta simples em uma tabela.
        Caso a autenticação seja Oauth, verifica se o token está valido ou expirado. Em caso de expiração, esta função utiliza o Refresh Token para solicitar um novo token de acesso.
    .OUTPUTS
        Retorna Verdadeiro se a sessão é valida, ou falso se há algum problema com a sessão.
    #>

    switch ($ModuleControlFlags.AuthType) {
        'Oauth' {
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
            break 
        }
        'Basic' {
            return $ModuleControlFlags.BasicAuthStatus
        }
        $Null {
            return $false
        }
        Default {}
    }
}