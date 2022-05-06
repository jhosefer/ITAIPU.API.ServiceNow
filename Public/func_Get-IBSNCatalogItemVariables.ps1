function Get-IBSNCatalogItemVariables {
    <#
    .SYNOPSIS
        Obtém a lista de variaveis de um Item do Catalogo de serviço.
    .DESCRIPTION
        Para consumir algum item do catalogo o usuário precisa fornecer algums dados que podem ser mandatórios ou opcionais.
        Este comando fornece de antemão todos os pré-requisitos para consumir um determinado item de catalogo.
    .PARAMETER ID
        Especifica o ID do Item do catalogo.
    #>
    [CmdletBinding(DefaultParameterSetName='SET0')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$ID
    )

    $CatalogItem = Get-IBSNCatalogItem -ID $ID

    $Conteiners = $CatalogItem.variables | Where-Object {$_.friendly_type -like 'container*'}
    $Variables = $CatalogItem.variables | Where-Object {$_.friendly_type -notlike 'container*'}
    if ($Conteiners){ $Variables = $Conteiners.Children + $Variables}
    $Variables | Select-Object name,label,mandatory,type,friendly_type,help_text,@{N='choices';E={$_.choices.value}}
}