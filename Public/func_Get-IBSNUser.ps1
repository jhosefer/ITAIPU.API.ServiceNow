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

        [Parameter(Mandatory=$true,ParameterSetName='SET3')]
        [string]$Query
    )

    $RestEndpoint = "api/now/table/sys_user"
    $BaseURI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint"

    if($PSBoundParameters.ContainsKey('ID')){
        $URI = "$BaseURI`?sysparm_query=sys_id=$ID^ORuser_name=$ID^ORname=$ID&sysparm_limit=1"
    }
    if($PSBoundParameters.ContainsKey('Query')){
        $URI = "$BaseURI`?sysparm_query=$Query&sysparm_limit=10000"
    }

    try {
        $Json = $(Invoke-IBSNRestAPI -URI $URI -Method GET -ErrorAction Stop).Result
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNUser")}; $Json  # Define a saida como um objeto do tipo IBSNUser
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}