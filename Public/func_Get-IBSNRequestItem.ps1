function Get-IBSNRequestItem {
    <#
    .SYNOPSIS
        Obtem um ou mais items de uma determinada Requisição de Serviço.
    .DESCRIPTION
        Um Item de Requisição de serviço (RITM) é o objeto contido dentro da Requisição de Serviço na relação (N x 1). Cada RITM representa um Item de Catálogo solicitado pelo usuário.    
    .PARAMETER ID
        Especifica o SysID do item de Requisição.
    .PARAMETER Request
        Especifica a Request onde o Item de Requisição se encontra.
    .PARAMETER Query
        Especifica uma Query com o critério de busca...
    .EXAMPLE
        Get-IBSNRequestItem -ID xxxxxxxxxxxxxxx

        --
        Obtem o RequestItem cujo SysID é especificado.
    #>
    [CmdletBinding(DefaultParameterSetName='SET0')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$ID,

        [Parameter(Mandatory=$true,ParameterSetName='SET3')]
        [string]$Request,

        [Parameter(Mandatory=$true,ParameterSetName='SET4')]
        [string]$Query
    )

    $RestEndpoint = "api/now/table/sc_req_item"
    $BaseURI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint"

    if($PSBoundParameters.ContainsKey('ID')){
        $URI = "$BaseURI`?sysparm_query=sys_id%3D$ID%5EORnumber%3D$ID&sysparm_limit=1"
    }
    if($PSBoundParameters.ContainsKey('Request')){
        $Req = Get-IBSNRequest -ID $Request
        $URI = "$BaseURI`?sysparm_query=request%3D$($Req.sys_id)&sysparm_limit=1"
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