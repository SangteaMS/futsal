$ErrorActionPreference = 'Stop'
$tomcat = Join-Path $PSScriptRoot '.runtime\apache-tomcat-10.1.61'
$launcher = Join-Path $tomcat 'bin\catalina.bat'
if (-not (Test-Path -LiteralPath $launcher)) { throw 'Tomcat is missing from .runtime. See README.md.' }

try {
    $response = Invoke-WebRequest 'http://localhost:8080/futsal-finder/login' -UseBasicParsing -TimeoutSec 3
    if ($response.StatusCode -eq 200) {
        Write-Host 'Futsal Finder is already running at http://localhost:8080/futsal-finder/'
        exit 0
    }
} catch { }

$securePassword = Read-Host 'MySQL root password' -AsSecureString
$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
try {
    $env:DB_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
    $env:DB_USER = 'root'
    $env:JAVA_HOME = 'C:\Program Files\Java\jdk-23'
    $env:CATALINA_HOME = $tomcat
    $env:CATALINA_BASE = $tomcat
    Start-Process -FilePath $launcher -ArgumentList 'run' -WindowStyle Hidden | Out-Null
} finally {
    $env:DB_PASSWORD = $null
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
}

for ($attempt = 0; $attempt -lt 30; $attempt++) {
    Start-Sleep -Seconds 1
    try {
        $response = Invoke-WebRequest 'http://localhost:8080/futsal-finder/login' -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            Write-Host 'Futsal Finder is running at http://localhost:8080/futsal-finder/'
            exit 0
        }
    } catch { }
}
throw 'Tomcat did not respond within 30 seconds. Check .runtime\apache-tomcat-10.1.61\logs.'
