function Get-IBSNUser {
    <#
    .SYNOPSIS
        Obtem um usuário.
    .DESCRIPTION
        Obtem um Usuário.
    .PARAMETER ID
        Especifica a Identidade do usuário a ser buscada.
        O ID pode ser: SysID, UserName, DisplayName.
    .PARAMETER Query
        Especifica o critério de busca.
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

    if($PSBoundParameters.ContainsKey('ID')){
        $Filtro = "sys_id=$ID^ORuser_name=$ID^ORname=$ID"
    }
    if($PSBoundParameters.ContainsKey('Query')){
        $Filtro = $Query
    }   

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