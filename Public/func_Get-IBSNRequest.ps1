function Get-IBSNRequest {
    <#
    .SYNOPSIS
        Obtem uma ou mais Requisições de serviço.
    .DESCRIPTION
        A Requisição de Serviço representa o carrinho de compras do Catalógo de serviços.
        Vários items do catálogo podem ser adicionado numa mesma Requisição de Serviço para atender um determinado cliente.

        Cada Item da Requisição de Serviço obtem um número e pode ser tratado de forma individual.
        Para obter informações de cada Item do carrinho (Request) utilize o comando Get-IBSNRequestItem.
    .PARAMETER Number
        Especifica o Numero (out Ticket) da Requisição de Serviço.
    .PARAMETER ID
        Especifica o SysID da requisição de Serviço.
    .PARAMETER Query
        Especifica uma Query com o critério de busca..
    .EXAMPLE
        Get-IBSNRequest -ID xxxxxxxxxxxxxxx

        --
        Obtem o ServiceRequest cujo SysID é especificado.
    .EXAMPLE
        Get-IBSNRequest -Number REQ00000

        ---
        Obtem o ServiceRequest cujo Ticket é especificado.
    #>
    [CmdletBinding(DefaultParameterSetName='SET0')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$ID,

        [Parameter(Mandatory=$true,ParameterSetName='SET2')]
        [string]$Number,

        [Parameter(Mandatory=$true,ParameterSetName='SET3')]
        [string]$Query
    )

    $RestEndpoint = "api/now/table/sc_request"
    $BaseURI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint"

    if($PSBoundParameters.ContainsKey('ID')){
        $URI = "$BaseURI`?sysparm_query=sys_id%3D$ID&sysparm_limit=1"
    }
    if($PSBoundParameters.ContainsKey('Number')){
        $URI = "$BaseURI`?sysparm_query=number%3D$Number&sysparm_limit=1"
    }
    if($PSBoundParameters.ContainsKey('Query')){
        $URI = "$BaseURI`?sysparm_query=$Query&sysparm_limit=10000"
    }

    try {
        $Json = $(Invoke-IBSNRestAPI -URI $URI -Method GET -ErrorAction Stop).Result
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNRequest")}; $Json  # Define a saida como um objeto do tipo IBSNCatalogItem
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}