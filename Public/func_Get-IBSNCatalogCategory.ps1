function Get-IBSNCatalogCategory {
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
        [string]$ID,

        [ValidateScript({
                if ($_ -is [string]){
                    return $true
                }
                elseif ($_.psobject.typenames -contains "IBSNCatalog") {
                    return $true
                }
                else{
                    return $false
                }
            },ErrorMessage = "Por favor, informe um objeto do tipo IBSNCatalog"
        )]
        [Parameter(Mandatory=$true,ParameterSetName='SET2',ValueFromPipeline=$true)]
        [System.Object]$Catalog
    )

    $RestEndpoint1 = "api/sn_sc/servicecatalog/catalogs"    # Obtem categorias por um catalago especifico
    $RestEndpoint2 = "api/sn_sc/servicecatalog/categories"  # Obtem uma categoria especifica

    if($PSBoundParameters.ContainsKey('ID')){
        $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint2/$ID`?sysparm_limit=1"
    }
    if ($PSBoundParameters.ContainsKey('Catalog')) {
        if ($Catalog.psobject.typenames -contains "IBSNCatalog"){
            $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint1/$($Catalog.sys_id)/categories`?sysparm_limit=10000"
        }
        else{
            $URI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint1/$Catalog/categories`?sysparm_limit=10000"
        }       
    }

    try {
        $Json = $(Invoke-IBSNRestAPI -URI $URI -Method GET -ErrorAction Stop).Result
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNCatalogCategory")}; $Json  # Define a saida como um objeto do tipo IBSNCatalog
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}