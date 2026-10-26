$ErrorActionPreference = 'Stop'
$tomcat = Join-Path $PSScriptRoot '.runtime\apache-tomcat-10.1.61'
$launcher = Join-Path $tomcat 'bin\shutdown.bat'
if (-not (Test-Path -LiteralPath $launcher)) { throw 'Tomcat is missing from .runtime.' }
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-23'
$env:CATALINA_HOME = $tomcat
$env:CATALINA_BASE = $tomcat
& $launcher
