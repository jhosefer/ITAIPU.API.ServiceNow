function Invoke-IBSNRestAPI {
    <#
    .SYNOPSIS
        Realiza uma chamada Rest API.
    .DESCRIPTION
        Realiza uma chamada Rest API
    .PARAMETER Resource
        Recurso a ser consumido na chamada rest. Deve ser escrito na forma: '/api/now/table/sc_request'
    .PARAMETER Query
        Critério de pesquisa na chamada Rest. A Sintaxe da Query pode ser consultada em https://docs.servicenow.com/bundle/rome-application-development/page/build/applications/concept/api-rest.html.
        Obs: Uma forma fácil de obter a query é realizar os filtros diretamente no ServiceNow e utilizar o recurso "copy Query".
    .PARAMETER ResultSize
        Por padrão, apenas um número fixo de elementos são retornados em cada chamada Rest. 
        Utilize o parâmetro ResultSize para especificar o número de itens que deseja. Para retornar todos os items, use: "-ResultSize Unlimited". Tenha em mente que dependendo do número de items, retornar todos os objetos pode levar bastante tempo e consumir bastante memória.
    .PARAMETER Sort
        Hashtable que Define a ordenação dos resultados. Seu argumento deve ser fornecido na forma:
             @{attribute='value';order='asc'} para resultados na ordem ascendentes;
             @{attribute='value';order='desc'} para resultados na ordem descendente;

        Caso não especificado, sempre irá retornar os dados ordenados por data de forma ascendente.       
    .PARAMETER Body
        Especifica o Corpo da chamada.
    .PARAMETER Method
        Especifica o Método.
        Os seguintes valores são possiveis: GET,POST,PUT,PATCH,DELETE
    #>
    [CmdletBinding(DefaultParameterSetName='SET0')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET0')]
        [string]$Resource,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [string]$Query,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [System.Object]$ResultSize,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [System.Collections.Hashtable]$Sort,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [System.Object]$Body,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
        [string]$Method = 'GET'
    )

    

    # Determina se a consulta irá realizar paginação.
    if ($PSBoundParameters.ContainsKey('ResultSize')){
        Test-ResultSize -ResultSize $ResultSize # Valida o ResultSize. Em caso de erro lança um Erro terminavel.
        if ($ResultSize -eq 'Unlimited' -or $ResultSize -gt $PAGE_SIZE){
            $Pagination=$true
            $Limit = $PAGE_SIZE
        }
        else { 
            $Pagination=$false
            $Limit = $ResultSize
        }
    }
    else { 
        $Pagination=$false 
        $Limit = $PAGE_SIZE
    }

    # Determina a Ordenação
    if ($PSBoundParameters.ContainsKey('Sort')){
        if (-not ($sort.ContainsKey('attribute') -and $sort.ContainsKey('order'))){
            Write-Error "Parâmetro Sort deve ser especificado na forma: @{attribute='value';order='asc|desc'}." -ErrorAction Stop
        }
        if ($Sort.order -eq 'desc'){
            $Order = "ORDERBYDESC$($Sort.attribute)"
        }
        else {
            $Order = "ORDERBY$($Sort.attribute)"
        }
    }
    else {
        # Caso não especificado, o resultado sempre será ordenando de forma ascendente pela data de criação.
        $Order = "ORDERBYsys_created_on"
    }

    # Ajusta o Filtro de pesquisa.
    if ($PSBoundParameters.ContainsKey('Query')){
        $Filtro = "$Query^$Order"
    }
    else {
        $Filtro = $Order
    }

    if (Test-ServiceNowSession){
        $headers = @{
            'Accept' = 'application/json'
            'Authorization' = "Bearer $($ModuleControlFlags.AccessToken)"
        }
        $URL =  "https://$($ModuleControlFlags.InstanceName).service-now.com$Resource`?sysparm_limit=$Limit&sysparm_query=$Filtro"

        if ($Pagination){
            $Offset = 0
            $ParcialJson = $Null
            $Json = $Null
            do {
                try {
                    if ($ModuleControlFlags.AuthType -eq 'Oauth'){
                        $ParcialJson = $(Invoke-RestMethod -Uri "$URL&sysparm_offset=$Offset" -Method $Method -Headers $headers -Body $Body -ContentType "application/json;charset=utf-8" -ErrorAction Stop).Result
                    }
                    if ($ModuleControlFlags.AuthType -eq 'Basic'){
                        $ParcialJson = $(Invoke-RestMethod -Uri "$URL&sysparm_offset=$Offset" -Method $Method -Body $Body -ContentType "application/json;charset=utf-8" -Authentication Basic -Credential $ModuleControlFlags.Credential -ErrorAction Stop).Result
                    }     
                }
                catch {
                    $httpError = $_.Exception.Response.StatusCode
                    $razao = ($_.ErrorDetails.Message | ConvertFrom-Json).Error.message
                    Write-Error "HTTP $($httpError.value__) $httpError`: $razao" -ErrorAction Stop
                }
                $Json += $ParcialJson
                $Offset += $PAGE_SIZE     
            } while ($Json.count -lt $ResultSize)
            $Json | select-object -first $ResultSize
        }
        else {
            try {
                if ($ModuleControlFlags.AuthType -eq 'Oauth'){
                    $Json = $(Invoke-RestMethod -Uri $URL -Method $Method -Headers $headers -Body $Body -ContentType "application/json;charset=utf-8" -ErrorAction Stop).Result
                }
                if ($ModuleControlFlags.AuthType -eq 'Basic'){
                    $Json = $(Invoke-RestMethod -Uri $URL -Method $Method -Body $Body -ContentType "application/json;charset=utf-8" -Authentication Basic -Credential $ModuleControlFlags.Credential -ErrorAction Stop).Result
                }     
            }
            catch{
                $httpError = $_.Exception.Response.StatusCode
                $razao = ($_.ErrorDetails.Message | ConvertFrom-Json).Error.message
                Write-Error "HTTP $($httpError.value__) $httpError`: $razao" -ErrorAction Stop
            } 
            if ($Json.count -eq $PAGE_SIZE){
                Write-Warning "Por padrão, apenas os primeiros $PAGE_SIZE elementos são retornados. Utilize o parâmetro ResultSize para especificar o número de itens que deseja. Para retornar todos os items, use: `"-ResultSize Unlimited`". Tenha em mente que dependendo do número de items, retornar todos os objetos pode levar bastante tempo e consumir bastante memória."
            }
            $Json
        }       
    }
    else {
        Write-Error "Você precisa se conectar a uma instância do ServiceNow para rodar este comando. Utilize Connect-IBServiceNow."
    }
}