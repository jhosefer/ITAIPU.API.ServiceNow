function Get-IBSNRequestItem {
    <#
    .SYNOPSIS
        Obtem um item de Requisição de Serviço. 
    .DESCRIPTION
        Um Item de Requisição de serviço (RITM) é um componente da Requisição de Serviço na relação (N x 1), isto é, uma Requisição de Serviço pode ter vários Items. (Similar ao Carrinho de compras)
	    Cada RITM representa um Item de Catálogo solicitado pelo usuário.
    .PARAMETER ID
        Especifica a Identidade do Item de Requisição.
        O ID pode ser: SysID, Number ou RequestNumber.
    .PARAMETER Query
        Critério de pesquisa na chamada Rest. A Sintaxe da Query pode ser consultada em https://docs.servicenow.com/bundle/rome-application-development/page/build/applications/concept/api-rest.html.
        Obs: Uma forma fácil de obter a query é realizar os filtros diretamente no ServiceNow e utilizar o recurso "copy Query".
    .PARAMETER ResultSize
        Por padrão, apenas um número fixo de elementos são retornados em cada chamada Rest. 
        Utilize o parâmetro ResultSize para especificar o número de itens que deseja. Para retornar todos os items, use: "-ResultSize Unlimited". Tenha em mente que dependendo do número de items, retornar todos os objetos pode levar bastante tempo e consumir bastante memória.
    .EXAMPLE
        Get-IBSNUser -ID user@domain.com
    #>
    [CmdletBinding(DefaultParameterSetName='SET1')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$false,Position=0,ParameterSetName='SET1')]
        [string]$ID,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName='SET2')]
        [string]$Query,

        [Parameter(Mandatory=$false,Position=2,ParameterSetName='SET2')]
        [ValidateScript({
            ($_.ContainsKey('attribute') -and $_.ContainsKey('order'))
            },
            ErrorMessage = "Parâmetro deve ser especificado com as seguintes chaves: attribute='value' e order='asc|desc'"
        )]
        [Hashtable]$Sort,

        [Parameter(Mandatory=$false,Position=3,ParameterSetName='SET1')]
        [Parameter(Mandatory=$false,Position=3,ParameterSetName='SET2')]
        [System.Object]$ResultSize
    )

    $Endpoint = "/api/now/table/sc_req_item"
    $Filtro = ($PSBoundParameters.ContainsKey('ID')) ? "sys_id=$ID^ORnumber=$ID^ORrequest.number=$ID" : $Query
  
    try {
        $Json = Invoke-IBSNRestAPI -Resource $Endpoint -Query $Filtro -Sort $Sort -ResultSize $ResultSize
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNRequestItem")}; $Json  # Define a saida como um objeto do tipo IBSNUser
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}