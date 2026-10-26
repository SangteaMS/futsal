$ErrorActionPreference = 'Stop'
$tomcat = Join-Path $PSScriptRoot '.runtime\apache-tomcat-10.1.61'
$war = Join-Path $PSScriptRoot 'target\futsal-finder.war'
if (-not (Test-Path -LiteralPath $tomcat)) { throw 'Tomcat is missing from .runtime.' }
if (-not (Test-Path -LiteralPath $war)) { throw 'Build the WAR with Maven first.' }

$tomcatRoot = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $tomcat).Path)
$webapps = Join-Path $tomcatRoot 'webapps'
$exploded = [IO.Path]::GetFullPath((Join-Path $webapps 'futsal-finder'))
$workRoot = Join-Path $tomcatRoot 'work\Catalina\localhost'
$jspCache = [IO.Path]::GetFullPath((Join-Path $workRoot 'futsal-finder'))
if (-not $exploded.StartsWith($tomcatRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected webapp path.' }
if (-not $jspCache.StartsWith($tomcatRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected JSP cache path.' }

# Tomcat must be stopped first. These are generated deployment and JSP cache directories.
if (Test-Path -LiteralPath $exploded) { Remove-Item -LiteralPath $exploded -Recurse -Force }
if (Test-Path -LiteralPath $jspCache) { Remove-Item -LiteralPath $jspCache -Recurse -Force }
Copy-Item -LiteralPath $war -Destination (Join-Path $webapps 'futsal-finder.war') -Force
Write-Host 'WAR deployed. Start Tomcat with .\start-local.ps1.'
