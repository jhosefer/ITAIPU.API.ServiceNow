function Get-IBSNGroup {
    <#
    .SYNOPSIS
        Obtem um Grupo do Service Now.
    .DESCRIPTION
        Obtem um Grupo do Service Now.
    .PARAMETER ID
        Especifica a Identidade do Grupo.
        O ID pode ser: SysID ou Name.
    .PARAMETER Query
        Critério de pesquisa na chamada Rest. A Sintaxe da Query pode ser consultada em https://docs.servicenow.com/bundle/rome-application-development/page/build/applications/concept/api-rest.html.
        Obs: Uma forma fácil de obter a query é realizar os filtros diretamente no ServiceNow e utilizar o recurso "copy Query".
    .PARAMETER ResultSize
        Por padrão, apenas um número fixo de elementos são retornados em cada chamada Rest. 
        Utilize o parâmetro ResultSize para especificar o número de itens que deseja. Para retornar todos os items, use: "-ResultSize Unlimited". Tenha em mente que dependendo do número de items, retornar todos os objetos pode levar bastante tempo e consumir bastante memória.
    .EXAMPLE
        Get-IBSNGroup GroupName

        --
        Obtem o grupo pelo Nome.
    .EXAMPLE
        Get-IBSNgroup -Query "sys_created_on.user_name=user@domain.com" -ResultSize 10

        --
        Obtem os 10 primeiros Grupos criados pelo usuário user@domain.com;
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

    $Endpoint = "/api/now/table/sys_user_group"
    $Filtro = ($PSBoundParameters.ContainsKey('ID')) ? "sys_id=$ID^ORname=$ID" : $Query
  
    try {
        $Json = Invoke-IBSNRestAPI -Resource $Endpoint -Query $Filtro -Sort $Sort -ResultSize $ResultSize
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNGroup")}; $Json
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}