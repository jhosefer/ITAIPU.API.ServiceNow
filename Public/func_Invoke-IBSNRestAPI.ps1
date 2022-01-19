function Invoke-IBSNRestAPI {
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
        [string]$URI,

        [Parameter(Mandatory=$false)]
        [System.Object]$Body,

        [Parameter(Mandatory=$false)]
        [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
        [string]$Method = 'GET'
    )
    
    if (Test-OauthSession){
        $headers = @{
            'Accept' = 'application/json'
            'Content-Type' = "application/json"
            'Authorization' = "Bearer $($ModuleControlFlags.AccessToken)"
        }
        try {
            Invoke-RestMethod -Uri $URI -Method $Method -Headers $headers -Body $Body -ErrorAction Stop
        }
        catch{
            $httpError = $_.Exception.Response.StatusCode
            $razao = ($_.ErrorDetails.Message | ConvertFrom-Json).Error.message
            Write-Error "HTTP $($httpError.value__) $httpError`: $razao" -ErrorAction Stop
        }   
    }
    else {
        Write-Error "Você precisa se conectar a uma instância do ServiceNow para rodar este comando. Utilize Connect-IBServiceNow."
    }
}