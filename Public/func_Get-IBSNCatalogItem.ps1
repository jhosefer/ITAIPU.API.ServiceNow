function Get-IBSNCatalogItem {
    <#
    .SYNOPSIS
        Obtem um item de catálogo de serviço.
    .DESCRIPTION
        Um item de catálogo de serviço é o objeto que representa um serviço ou produto disponibilizado ao usuário. 
        O catálogo de serviço pode ter um ou mais items publicados assim como um cardápio em um restaurante.
    .PARAMETER ID
        Especifica a Identidade do Item do catálogo.
        Caso não especificado, retorna todos os Items publicados por qualquer catálogo.
    .PARAMETER CatalogID
        Especifica a Identidade do Catálogo do qual se deve obter os itens.
        Caso não especificado, retorna todos os Items publicados por qualquer catálogo.
    .PARAMETER CategoryID
        Especifica a Identidade da Categoria do Catálogo do qual se deve obter os itens.
        O ID pode ser: SysID ou o ID do Catálogo (Neste caso retorna todos os items deste catálogo).
    .PARAMETER ResultSize
        Por padrão, apenas um número fixo de elementos são retornados em cada chamada Rest. 
        Utilize o parâmetro ResultSize para especificar o número de itens que deseja. Para retornar todos os items, use: "-ResultSize Unlimited". Tenha em mente que dependendo do número de items, retornar todos os objetos pode levar bastante tempo e consumir bastante memória.
    .EXAMPLE
        Get-IBSNCatalogItem -ID xxxx

        --
        Obtem o Item de catalogo cujo Sys_id é especificado.
    .EXAMPLE
        Get-IBSNCatalogItem -CategoryID xxxxxxxxx

        --
        Obtem todos os Item de catalogo cujo categoria é especificada.
    #>
    [CmdletBinding(DefaultParameterSetName='SET2')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='SET1')]
        [string]$ID,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName='SET2')]
        [string]$CatalogID,

        [Parameter(Mandatory=$false,Position=2,ParameterSetName='SET2')]
        [string]$CategoryID,

        [Parameter(Mandatory=$false,Position=3,ParameterSetName='SET2')]
        [System.Object]$ResultSize
    )

    $Endpoint = "/api/sn_sc/servicecatalog/items"

    $Resource = ($PSBoundParameters.ContainsKey('ID')) ? "$Endpoint/$ID" : $Endpoint
    
    if ($PSBoundParameters.ContainsKey('CatalogID')){
        $Parms += "sysparm_catalog=$CatalogID"
    }
    if ($PSBoundParameters.ContainsKey('CategoryID')){
        $Parms += "&sysparm_category=$CategoryID"
    }

    try {
        $Json = Invoke-IBSNRestAPI -Resource $Resource -AdditionalSysParms $Parms -Query $Filtro -Sort $Sort -ResultSize $ResultSize
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNCatalogItem")}; $Json  # Define a saida como um objeto do tipo IBSNUser
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}