#Obtem todos os arquivos de funções e classes
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\func_*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\func_*.ps1 -ErrorAction SilentlyContinue )
$Class = @( Get-ChildItem -Path $PSScriptRoot\Class\class_*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private + $Class)){
    Try{ . $import.fullname }
    Catch{ Write-Error -Message "Failed to import function $($import.fullname): $_" }
}
