function Get-IBSNUser {
    <#
    .SYNOPSIS
        Obtem um usuário ServiceNow.
    .DESCRIPTION
        Obtem um Usuário ServiceNow.
    .PARAMETER ID
        Especifica a Identidade do usuário a ser buscada.
        O ID pode ser: SysID, UserName, DisplayName.
    .PARAMETER Query
        Critério de pesquisa na chamada Rest. A Sintaxe da Query pode ser consultada em https://docs.servicenow.com/bundle/rome-application-development/page/build/applications/concept/api-rest.html.
        Obs: Uma forma fácil de obter a query é realizar os filtros diretamente no ServiceNow e utilizar o recurso "copy Query".
    .PARAMETER ResultSize
        Por padrão, apenas um número fixo de elementos são retornados em cada chamada Rest. 
        Utilize o parâmetro ResultSize para especificar o número de itens que deseja. Para retornar todos os items, use: "-ResultSize Unlimited". Tenha em mente que dependendo do número de items, retornar todos os objetos pode levar bastante tempo e consumir bastante memória.
    .EXAMPLE
        Get-IBSNUser -ID user@domain.com
    #>

    [CmdletBinding(DefaultParameterSetName='SET1')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$ID,

        [Parameter(Mandatory=$true,ParameterSetName='SET2')]
        [string]$Query,

        [Parameter(Mandatory=$false,ParameterSetName='SET1')]
        [Parameter(Mandatory=$false,ParameterSetName='SET2')]
        [System.Object]$ResultSize
    )

    $Endpoint = "/api/now/table/sys_user"
    $Filtro = $PSCmdlet.ParameterSetName -eq 'SET1' ? "sys_id=$ID^ORuser_name=$ID^ORname=$ID" : $Query
  
    try {
        if($PSBoundParameters.ContainsKey('ResultSize')){
            $Json = Invoke-IBSNRestAPI -Resource $Endpoint -Query $Filtro -ResultSize $ResultSize
        }
        else {
            $Json = Invoke-IBSNRestAPI -Resource $Endpoint -Query $Filtro
        }
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNUser")}; $Json  # Define a saida como um objeto do tipo IBSNUser
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}