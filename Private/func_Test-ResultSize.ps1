function Test-ResultSize {
    <#
    .SYNOPSIS
        Realiza a validação do parâmetro ResultSize
    .DESCRIPTION
        O parametro ResultSize é utilizado para definir a quantidade de itens retornados em uma busca.
        Ele deve ser um inteiro ou necessáriamente a string "Unlimited".
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true)]
        [System.Object]$ResultSize
    )

    if ( @('String','Int32') -notcontains $ResultSize.GetType().Name) {
        Write-Error "Especifique o número de items ou Unlimited para obter todos." -ErrorAction Stop
    }
    else {
        if ($ResultSize -is [string] -and $ResultSize -ne 'Unlimited'){
            Write-Error "Especifique o número de items ou Unlimited para obter todos." -ErrorAction Stop
        }
        else {
            return  # Necessáriamente é um [int] ou se for [string] é igual "Unlimited"
        }
    }
}