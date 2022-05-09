function New-IBSNServiceRequest {
    <#
    .SYNOPSIS
        Cria uma nova Solicitação de Serviço.
    .DESCRIPTION
        Cria uma nova Requisição e solicitação de serviço.
    .PARAMETER Values
        Especifica os argumentos necessários do Item do catálogo para iniciar a requisição.
        Os valores podem ser consultados com Get-IBSNCatalogItemVariables
    .EXAMPLE
        Get-IBSNCatalogItemVariables -ID a2e9bd0adb11f410ba509f3bf396190a | ft
        $values =  @{question_req_for_id='34d5a7ed1b930d58aeff20afe54bcbb9';question_service_type='recertification_id';question_description='Solicitação genérica'}
        New-IBSNServiceRequest -CatalogItemID a2e9bd0adb11f410ba509f3bf396190a -Variables $values

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
    
    $Body = @{sysparm_quantity=1;variables=$Variables} | ConvertTo-Json
    $Out = Invoke-IBSNRestAPI -URI https://itaipudev.service-now.com/api/sn_sc/servicecatalog/items/$CatalogItemID/order_now -Body $Body -Method POST
    if ($Result){
        Get-IBSNServiceRequest -Request $Out.Result.number
    }
}