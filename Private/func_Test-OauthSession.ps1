function Test-OauthSession {
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