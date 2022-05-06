function New-IBSNRequest {
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
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true)]
        [string]$CatalogItemID,
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Variables
    )
    
    $Body = @{sysparm_quantity=1;variables=$Variables} | ConvertTo-Json
    Invoke-IBSNRestAPI -URI https://itaipudev.service-now.com/api/sn_sc/servicecatalog/items/$CatalogItemID/order_now -Body $Body -Method POST
}