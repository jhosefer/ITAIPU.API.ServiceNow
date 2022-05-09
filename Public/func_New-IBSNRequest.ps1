function New-IBSNRequest {
    <#
    .SYNOPSIS
        Cria uma nova Requisição de Serviço.
    .DESCRIPTION
        Cria uma nova Requisição de serviço.
    .PARAMETER Variables
        Especifica as variáveis de criação da Requisição.
        As variaveis representam os dados mínimos necessários para iniciar um processo de Requisição de serviço e podem ser consultadas com a função Get-IBSNCatalogItemVariables
    .EXAMPLE
        Get-IBSNCatalogItemVariables -ID a2e9bd0adb11f410ba509f3bf396190a | ft
        $values =  @{question_req_for_id='34d5a7ed1b930d58aeff20afe54bcbb9';question_service_type='recertification_id';question_description='Solicitação genérica'}
        New-IBSNRequest -CatalogItemID a2e9bd0adb11f410ba509f3bf396190a -Variables $values

        --
        Primeiramente, obtem as variaveis necessárias para um determinado Item do catalogo. Em seguida, as variaveis são especificadas via HashTable e a partir dai solicita-se a requisão.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true)]
        [string]$CatalogItemID,
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Variables
    )
    
    $RestEndpoint = "api/sn_sc/servicecatalog/items/$CatalogItemID/order_now"
    $BaseURI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint"
    $Body = @{sysparm_quantity=1;variables=$Variables} | ConvertTo-Json

    $Out = $(Invoke-IBSNRestAPI -URI $BaseURI -Method POST -Body $Body -ErrorAction Stop).Result
    Get-IBSNRequest -ID $Out.sys_id
}