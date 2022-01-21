function Get-IBSNRequest {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .PARAMETER Name
        Specifies the file name.
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None. You cannot pipe objects to Add-Extension.
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding(DefaultParameterSetName='SET0')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1')]
        [string]$Ticket,

        [Parameter(Mandatory=$true,ParameterSetName='SET2')]
        [string]$Query
    )

    $RestEndpoint = "api/now/table/sc_req_item"
    $BaseURI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint"

    if($PSBoundParameters.ContainsKey('Ticket')){
        $URI = "$BaseURI`?sysparm_query=number%3D$Ticket&sysparm_limit=1"
    }
    if($PSBoundParameters.ContainsKey('Query')){
        $URI = "$BaseURI`?sysparm_query=$Query&sysparm_limit=10000"
    }
    
    try {
        $Json = $(Invoke-IBSNRestAPI -URI $URI -Method GET -ErrorAction Stop).Result
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNRequest")}; $Json  # Define a saida como um objeto do tipo IBSNCatalogItem
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}