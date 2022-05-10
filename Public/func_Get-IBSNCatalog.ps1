function Get-IBSNCatalog {
    <#
    .SYNOPSIS
        Obtem um Catálogo de Serviços.
    .DESCRIPTION
        Obtem um Catálogo de Serviços.
        Caso não seja especificado, retorna todos os catálogos publicados na Instância.
    .PARAMETER ID
        Especifica o SysID do Catálogo.
    .OUTPUTS
        Retorna um PSCustomObject do tipo IBSNCatalog.
    #>
    [CmdletBinding(DefaultParameterSetName='SET0')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1',ValueFromPipeline=$true)]
        [string]$ID
    )

    $RestEndpoint = "api/sn_sc/servicecatalog/catalogs"

    if ($PSBoundParameters.ContainsKey('ID')){
        $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndPoint/$ID`?sysparm_limit=1"
    }
    else {
        $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndPoint`?sysparm_limit=10000"
    }

    try { 
        $Json = $(Invoke-IBSNRestAPI -URI $URI -Method GET -ErrorAction Stop).Result
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNCatalog")}; $Json  # Define a saida como um objeto do tipo IBSNCatalog
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}