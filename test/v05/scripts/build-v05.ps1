[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$buildRoot=Join-Path $repoRoot 'build\v05'
$deps=Join-Path $buildRoot 'deps'
$java=(Get-Command java -ErrorAction Stop).Source
$required=@('ecj-3.26.0.jar','tomcat-embed-core-9.0.121.jar','h2-2.2.224.jar','javax.annotation-api-1.3.2.jar')
foreach($name in $required) { if(-not (Test-Path -LiteralPath (Join-Path $deps $name))) { throw "Missing dependency $name. Run prepare-dependencies.ps1 first." } }
$lock=Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot '..\dependencies.lock.json') | ConvertFrom-Json
foreach($item in $lock) {
    if((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $deps $item.file)).Hash.ToLowerInvariant() -ne $item.sha256) { throw "Dependency checksum mismatch: $($item.file)" }
}
$classes=Join-Path $buildRoot 'classes'
New-Item -ItemType Directory -Force $classes | Out-Null
$sourceRoots=@((Join-Path $repoRoot 'implementation\v05\java'),(Join-Path $repoRoot 'test\v05\java'))
$sources=@($sourceRoots | ForEach-Object { Get-ChildItem -LiteralPath $_ -Recurse -Filter '*.java' | ForEach-Object { $_.FullName } })
$classpath=($required | ForEach-Object { Join-Path $deps $_ }) -join [IO.Path]::PathSeparator
& $java -jar (Join-Path $deps 'ecj-3.26.0.jar') -8 -proc:none -encoding UTF-8 -classpath $classpath -d $classes $sources
if($LASTEXITCODE -ne 0) { throw 'V5 Java compilation failed' }
Write-Output 'V5 Java compilation PASS'

