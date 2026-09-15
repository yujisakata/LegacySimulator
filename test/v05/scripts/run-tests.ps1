[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$buildRoot=Join-Path $repoRoot 'build\v05'
& (Join-Path $PSScriptRoot 'build-v05.ps1')
& (Join-Path $repoRoot 'test\v04\scripts\build-v04.ps1')
$run=Join-Path $buildRoot ('run-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $run | Out-Null
$fixture=Join-Path $run 'v4'
& python (Join-Path $PSScriptRoot 'prepare_v4_fixture.py') $fixture
if($LASTEXITCODE -ne 0) { throw 'V4 integration fixture failed' }
$classpath=(Join-Path $buildRoot 'classes')+';'+(Join-Path $buildRoot 'deps\*')
& java -cp $classpath V5IntegrationTest $repoRoot $run $fixture
if($LASTEXITCODE -ne 0) { throw 'V5 Java/JDBC/HTTP verification failed' }
Copy-Item -LiteralPath (Join-Path $run 'result.json') -Destination (Join-Path $buildRoot 'result.json')
Set-Content -LiteralPath (Join-Path $buildRoot 'last-run.txt') -Value $run -Encoding utf8
Write-Output "V5 results: $run"
