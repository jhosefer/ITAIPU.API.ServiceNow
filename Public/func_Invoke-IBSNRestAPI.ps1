function Invoke-IBSNRestAPI {
    <#
    .SYNOPSIS
        Realiza uma chamada Rest API.
    .DESCRIPTION
        Realiza uma chamada Rest API
    .PARAMETER URI
        Especifica o recurso a ser consumido na chamada.
    .PARAMETER Body
        Especifica o Corpo da chamada.
    .PARAMETER Method
        Especifica o Método.
        Os seguintes valores são possiveis: GET,POST,PUT,PATCH,DELETE
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

    if (Test-ServiceNowSession){
        switch ($ModuleControlFlags.AuthType) {
            'Oauth' {
                $headers = @{
                    'Accept' = 'application/json'
                    'Authorization' = "Bearer $($ModuleControlFlags.AccessToken)"
                }
                try {
                    Invoke-RestMethod -Uri $URI -Method $Method -Headers $headers -Body $Body -ContentType "application/json;charset=utf-8" -ErrorAction Stop
                }
                catch{
                    $httpError = $_.Exception.Response.StatusCode
                    $razao = ($_.ErrorDetails.Message | ConvertFrom-Json).Error.message
                    Write-Error "HTTP $($httpError.value__) $httpError`: $razao" -ErrorAction Stop
                }   
                break 
            }
            'Basic' {
                try {
                    Invoke-RestMethod -Uri $URI -Method $Method -Body $Body -ContentType "application/json;charset=utf-8" -Authentication Basic -Credential $ModuleControlFlags.Credential -ErrorAction Stop
                }
                catch {
                    $httpError = $_.Exception.Response.StatusCode
                    $razao = ($_.ErrorDetails.Message | ConvertFrom-Json).Error.message
                    Write-Error "HTTP $($httpError.value__) $httpError`: $razao" -ErrorAction Stop
                }
                break
            }
            Default {}
        }
    }
    else {
        Write-Error "Você precisa se conectar a uma instância do ServiceNow para rodar este comando. Utilize Connect-IBServiceNow."
    }
}