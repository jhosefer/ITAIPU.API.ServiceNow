function Get-IBSNServiceRequest {
    <#
    .SYNOPSIS
        Obtem uma Solicitação de Serviço.
    .DESCRIPTION
        A solicitação de serviço pode ser obtida pelo seu Ticket, Numero de Requisição ou uma Query. 
        Em caso de Querys, vários tickets podem ser retornados.
    .PARAMETER Ticket
        Especifica o Ticket da Solicitação de serviço.
    .PARAMETER Request
        Especifica o numero da requisição de serviço.
        A relação da requisição de serviço com a Solicitação de serviço é sempre de 1 para 1. 
    .PARAMETER Query
        Especifica uma Query com o critério de busca..
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding(DefaultParameterSetName='SET0')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$Ticket,

        [Parameter(Mandatory=$true,ParameterSetName='SET2')]
        [string]$Request,

        [Parameter(Mandatory=$true,ParameterSetName='SET3')]
        [string]$Query
    )

    $RestEndpoint = "api/now/table/sc_req_item"
    $BaseURI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint"

    if($PSBoundParameters.ContainsKey('Ticket')){
        $URI = "$BaseURI`?sysparm_query=number%3D$Ticket&sysparm_limit=1"
    }
    if($PSBoundParameters.ContainsKey('Request')){
        $URI = "$BaseURI`?sysparm_query=request_numbe%3D$Request&sysparm_limit=1"
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