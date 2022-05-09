function Get-IBSNRequestItem {
    <#
    .SYNOPSIS
        Obtem um ou mais items de uma determinada Requisição de Serviço.
    .DESCRIPTION
        Um Item de Requisição de serviço (RITM) é o objeto contido dentro da Requisição de Serviço na relação (N x 1). Cada RITM representa um Item de Catálogo solicitado pelo usuário.    
    .PARAMETER ID
        Especifica o SysID do item de Requisição.
    .PARAMETER Number
        Especifica o numero (Ticket) do Item de Requisição.
    .PARAMETER Query
        Especifica uma Query com o critério de busca...
    .EXAMPLE
        Get-IBSNRequestItem -ID xxxxxxxxxxxxxxx

        --
        Obtem o RequestItem cujo SysID é especificado.
    .EXAMPLE
        Get-IBSNRequestItem -Number SS0000000

        ---
        Obtem o RequestItem cujo Ticket é especificado.
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

    $RestEndpoint = "api/now/table/sc_req_item"
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
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNRequestItem")}; $Json  # Define a saida como um objeto do tipo IBSNRequestItem
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}