function Get-IBSNCatalogCategory {
    <#
    .SYNOPSIS
        Obtem a categoria de um Catálogo.
    .DESCRIPTION
        Obtem a categoria de um Catálogo.
        Caso não seja especificado, retorna todas as cetegorias em um determinado catálogo.
    .PARAMETER Catalog
        Especifica um objeto Catálogo ou seu SysID.
    .PARAMETER ID
        Especifica o SysID de uma categoria.
    .OUTPUTS
        Retorna um objeto PSCustomObject do tipo IBSNCatalogCategory.
    .EXAMPLE
        Get-IBSNCatalog | Get-IBSNCatalogCategory

        --
        Retorna todas as categorias de todos os catalogos.
    .EXAMPLE
        Get-IBSNCatalogCategory -Catalog xxxxxxxxxxx

        --
        Retorna todas as categorias do catalogo especificado.
    .EXAMPLE
        Get-IBSNCatalogCategory -ID xxxxxxxxxxx

        --
        Retorna a Categoria cujo SysID é especificado.
    #>
    [CmdletBinding(DefaultParameterSetName='SET1')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [String]$ID,

        [ValidateScript({
                if ($_ -is [string]){
                    return $true
                }
                elseif ($_.psobject.typenames -contains "IBSNCatalog") {
                    return $true
                }
                else{
                    return $false
                }
            },ErrorMessage = "Por favor, informe um objeto do tipo IBSNCatalog"
        )]
        [Parameter(Mandatory=$true,ParameterSetName='SET2',ValueFromPipeline=$true)]
        [System.Object]$Catalog
    )

    $RestEndpoint1 = "api/sn_sc/servicecatalog/catalogs"    # Obtem categorias por um catalago especifico
    $RestEndpoint2 = "api/sn_sc/servicecatalog/categories"  # Obtem uma categoria especifica

    if($PSBoundParameters.ContainsKey('ID')){
        $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint2/$ID`?sysparm_limit=1"
    }
    if ($PSBoundParameters.ContainsKey('Catalog')) {
        if ($Catalog.psobject.typenames -contains "IBSNCatalog"){
            $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint1/$($Catalog.sys_id)/categories`?sysparm_limit=10000"
        }
        else{
            $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint1/$Catalog/categories`?sysparm_limit=10000"
        }       
    }

    try {
        $Json = $(Invoke-IBSNRestAPI -URI $URI -Method GET -ErrorAction Stop).Result
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNCatalogCategory")}; $Json  # Define a saida como um objeto do tipo IBSNCatalog
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}