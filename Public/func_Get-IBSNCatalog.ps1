function Get-IBSNCatalog {
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
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='SET1',ValueFromPipeline=$true)]
        [string]$ID
    )

    $RestEndpoint = "api/sn_sc/servicecatalog/catalogs"

    if ($PSBoundParameters.ContainsKey('ID')){
        $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndPoint/$ID`?sysparm_limit=1"
    }
    else {
        $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndPoint`?sysparm_limit=10000"
    }
    
    try {
        $Json = $(Invoke-IBSNRestAPI -URI $URI -Method GET -ErrorAction Stop).Result
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNCatalog")}; $Json  # Define a saida como um objeto do tipo IBSNCatalog
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}