function Invoke-IBSNRestAPI {
    <#
    .SYNOPSIS
        Realiza uma chamada Rest API ao Service Now.
    .DESCRIPTION
        Realiza uma chamada Rest API ao Service Now.
    .PARAMETER Resource
        Recurso a ser consumido na chamada rest. Deve ser escrito na forma: '/api/now/table/sc_request'
    .PARAMETER URI
        Diferentemente do Parâmetro Resource, neste parâmetro você deve especificar a URI completa incluido a query.  
    .PARAMETER Query
        Critério de pesquisa na chamada Rest. A Sintaxe da Query pode ser consultada em https://docs.servicenow.com/bundle/rome-application-development/page/build/applications/concept/api-rest.html.
        Obs: Uma forma fácil de obter a query é realizar os filtros diretamente no ServiceNow e utilizar o recurso "copy Query".
    .PARAMETER AdditionalSysParms
        Especifica parametros adicionais.
        Algumas API's possuem parametros adicionais que poderão ser fornecidos, exemplo: sysparm_category.
        Os parametros devem ser especificados como string na forma chave=valor.
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
    .PARAMETER Body
        Especifica a URI completa.
    .PARAMETER Method
        Especifica o Método. Padrão: GET
        Os seguintes valores são possiveis: GET,POST,PUT,PATCH,DELETE
    .EXAMPLE
        Invoke-IBSNRestAPI -URI https://instance.service-now.com/api/now/table/sys_user/f5d96ba41b9478100ff06350f54bcbb4

        --
        Realiza uma chamada Rest especificando a URI completa do recurso.
    .EXAMPLE
        Invoke-IBSNRestAPI -Resource "/api/now/table/sc_request" -Query "cat_item=d94e1127db373c10467d5c4bf39619e2" -ResultSize 10 -Sort @{attribute='sys_created_on';order='desc'}

        --
        Realiza uma chamada Rest especificando utilizando o método GET para obter os dados da tabela sc_request.
        Apenas os 10 primeiros resultados são retornados ordenados de forma descendente pelo atributo sys_created_on.
    #>
    [CmdletBinding(DefaultParameterSetName='SET0')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [System.Uri]$URI,

        [Parameter(Mandatory=$true,ParameterSetName='SET0')]
        [ValidateScript({
            $_.StartsWith('/') -and -not $_.EndsWith('/')
            },
            ErrorMessage = "Argumento deve ser especificado na forma '/path/to/resource'."
        )]
        [string]$Resource,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string]$Query,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string]$AdditionalSysParms,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [System.Object]$ResultSize,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [System.Collections.Hashtable]$Sort,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [Parameter(Mandatory=$false,ParameterSetName='SET1')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [System.Object]$Body,

        [Parameter(Mandatory=$false,ParameterSetName='SET0')]
        [Parameter(Mandatory=$false,ParameterSetName='SET1')]
        [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
        [string]$Method = 'GET'
    )

    if (-not $(Test-ServiceNowSession)){
        Write-Error "Você precisa se conectar a uma instância do ServiceNow para rodar este comando. Utilize Connect-IBServiceNow." -ErrorAction Stop
    }
    else {
        
        # Valida a URI fornecida pelo Usuário
        if ($PSCmdlet.ParameterSetName -eq 'SET1' -and ($URI.Authority -ne "$($ModuleControlFlags.InstanceName).service-now.com")){
            Write-Error "URI informada não corresponde a instância $($ModuleControlFlags.InstanceName) conectada." -ErrorAction Stop
        }
        
        # Determina se a consulta irá realizar paginação.
        if ($PSBoundParameters.ContainsKey('ResultSize') -and ($Null -ne $ResultSize)){
            Test-ResultSize -ResultSize $ResultSize # Valida o ResultSize. Em caso de erro lança um Erro terminal.
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
        if ($PSBoundParameters.ContainsKey('Sort') -and ($Null -ne $Sort)){
            if (-not ($Sort.ContainsKey('attribute') -and $Sort.ContainsKey('order'))){
                Write-Error "Parâmetro Sort deve ser especificado com as chaves attribute e order. Exemplo: @{attribute='value';order='desc|asc'}" -ErrorAction Stop
            }
            $Order = ($Sort.order -eq 'desc') ? "ORDERBYDESC$($Sort.attribute)" : "ORDERBY$($Sort.attribute)"
        }
        else {
            # Caso não especificado, o resultado sempre será ordenando de forma ascendente pela data de criação.
            $Order = "ORDERBYsys_created_on"
        }

        # Ajusta o Filtro de pesquisa.
        $Filtro =  ($PSBoundParameters.ContainsKey('Query')-and ($Null -ne $Query)) ? "$Query^$Order" : $Order

        # Definição do Header e URL
        $headers = @{
            'Accept' = 'application/json'
            'Authorization' = "Bearer $($ModuleControlFlags.AccessToken)"
        }
        $URL =  "https://$($ModuleControlFlags.InstanceName).service-now.com$Resource`?$AdditionalSysParms&sysparm_limit=$Limit&sysparm_query=$Filtro"

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
        else { # Pagination = $false
            $NewURL = $PSCmdlet.ParameterSetName -eq 'SET1' ? $URI : $URL
            try {
                if ($ModuleControlFlags.AuthType -eq 'Oauth'){
                    $Json = $(Invoke-RestMethod -Uri $NewURL -Method $Method -Headers $headers -Body $Body -ContentType "application/json;charset=utf-8" -ErrorAction Stop).Result
                }
                if ($ModuleControlFlags.AuthType -eq 'Basic'){
                    $Json = $(Invoke-RestMethod -Uri $NewURL -Method $Method -Body $Body -ContentType "application/json;charset=utf-8" -Authentication Basic -Credential $ModuleControlFlags.Credential -ErrorAction Stop).Result
                }     
            }
            catch{
                $httpError = $_.Exception.Response.StatusCode
                $ErrorMessage = ($_.ErrorDetails.Message | Test-Json -ErrorAction SilentlyContinue) ? ($_.ErrorDetails.Message | ConvertFrom-Json).Error.message : $_.ErrorDetails.Message
                Write-Error "HTTP $($httpError.value__) $httpError`: $ErrorMessage" -ErrorAction Stop
            } 
            if ($Json.count -eq $PAGE_SIZE){
                Write-Warning "Por padrão, apenas os primeiros $PAGE_SIZE elementos são retornados. Utilize o parâmetro ResultSize para especificar o número de itens que deseja. Para retornar todos os items, use: `"-ResultSize Unlimited`". Tenha em mente que dependendo do número de items, retornar todos os objetos pode levar bastante tempo e consumir bastante memória."
            }
            $Json
        }
    }       
}