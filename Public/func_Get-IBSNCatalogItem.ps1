function Get-IBSNCatalogItem {
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
                elseif ($_.psobject.typenames -contains "IBSNCatalogCategory") {
                    return $true
                }
                else{
                    return $false
                }
            },ErrorMessage = "Por favor, informe um objeto do tipo IBSNCatalogCategory"
        )]
        [Parameter(Mandatory=$true,ParameterSetName='SET2',ValueFromPipeline=$true)]
        [System.Object]$Category
    )

    $RestEndpoint = "api/sn_sc/servicecatalog/items"
    $BaseURI = "$($ModuleControlFlags.InstanceURI)/$RestEndpoint"

    if($PSBoundParameters.ContainsKey('ID')){
        $URI = "$BaseURI/$ID`?sysparm_limit=1"
    }
    elseif ($PSBoundParameters.ContainsKey('Category')) {
        if ($Category.psobject.typenames -contains "IBSNCatalogCategory"){
            $URI = "$BaseURI`?sysparm_category=$($Category.sys_id)&sysparm_limit=10000"
        }
        else{
            $URI = "$BaseURI`?sysparm_category=$Category&sysparm_limit=10000"
        }
    }
    else {
        $URI = "$BaseURI`?sysparm_limit=10000"
    }
    
    try {
        $Json = $(Invoke-IBSNRestAPI -URI $URI -Method GET -ErrorAction Stop).Result
        $Json | ForEach-Object{$_.psobject.TypeNames.Insert(0, "IBSNCatalogItem")}; $Json  # Define a saida como um objeto do tipo IBSNCatalogItem
    }
    catch{
        Write-Error "$($_.Exception.Message)"
    }
}