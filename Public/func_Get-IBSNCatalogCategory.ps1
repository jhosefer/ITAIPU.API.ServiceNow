function Get-IBSNCatalogCategory {
    <#
    .SYNOPSIS
        Obtem a categoria de um determinado catálogo.
    .DESCRIPTION
        Obtem a categoria de um determinado catálogo.
        Caso não seja especificado, retorna todas as cetegorias presentes no catálogo especificado.
    .PARAMETER CatalogID
        Especifica o catálogo do qual se deseja obter as categorias.
        Pode ser: SysID ou Nome do Catálogo.
    .PARAMETER ID
        Especifica a Identidade da categoria a ser obtida.
        O ID pode ser: SysID ou Name.
    .PARAMETER ResultSize
        Por padrão, apenas um número fixo de elementos são retornados em cada chamada Rest. 
        Utilize o parâmetro ResultSize para especificar o número de itens que deseja. Para retornar todos os items, use: "-ResultSize Unlimited". Tenha em mente que dependendo do número de items, retornar todos os objetos pode levar bastante tempo e consumir bastante memória.
    .EXAMPLE
        Get-IBSNCatalogCategory -CatalogID xxxx

        --
        Obtem a lista de categorias do catalogo especificado.
    .EXAMPLE
        Get-IBSNCatalogCategory -ID xxxx

        --
        Obtem a categoria especificada.
    #>

    [CmdletBinding(DefaultParameterSetName='SET1')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='SET1')]
        [string]$ID,

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='SET2')]
        [string]$CatalogID,

        [Parameter(Mandatory=$false,Position=4,ParameterSetName='SET2')]
        [System.Object]$ResultSize
    )

    $Endpoint1 = "/api/sn_sc/servicecatalog/catalogs/$CatalogID/categories" 
    $Endpoint2 = "/api/sn_sc/servicecatalog/categories/$ID"             
    $Resource = ($PSBoundParameters.ContainsKey('ID')) ? $Endpoint2 : $Endpoint1
  
    try {
        $Json = Invoke-IBSNRestAPI -Resource $Resource -Query $Filtro -Sort $Sort -ResultSize $ResultSize
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNCatalogCategory")}; $Json
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}