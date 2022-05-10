#Obtem todos os arquivos de funções e classes
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\func_*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\func_*.ps1 -ErrorAction SilentlyContinue )
$Class = @( Get-ChildItem -Path $PSScriptRoot\Class\class_*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private + $Class)){
    Try{ . $import.fullname }
    Catch{ Write-Error -Message "Failed to import function $($import.fullname): $_" }
}

# A váriavel ModuleControlFlags controla o comportamento das funções e está disponível a todo o modulo
$MCF = [ordered]@{
    InstanceName = $Null
    InstanceURI = $Null         
    Credential = $Null          # Credencial do usuário
    AppCredential = $Null       # Credencial do App Oauth na instancia
    AccessToken = $Null         # Access Token Oauth
    RefreshToken = $Null        # Refresh Token Oauth
    ExpirationDate = $Null      # Data de expiração do Token Oauth
    AuthType = $Null            # Basic ou Oauth
    BasicAuthStatus = $Null     # True se a autenticação Basica foi bem sucedida
}
New-Variable -Name ModuleControlFlags -Value $MCF -Scope Script