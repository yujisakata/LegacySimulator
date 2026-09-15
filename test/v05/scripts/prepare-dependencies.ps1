[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$directory=Join-Path $repoRoot 'build\v05\deps'
New-Item -ItemType Directory -Force $directory | Out-Null
$lock=Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot '..\dependencies.lock.json') | ConvertFrom-Json
foreach($item in $lock) {
    $target=Join-Path $directory $item.file
    if(-not (Test-Path -LiteralPath $target)) { Invoke-WebRequest -Uri $item.url -OutFile $target }
    $actual=(Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash.ToLowerInvariant()
    if($actual -ne $item.sha256) { throw "Dependency checksum mismatch: $($item.file)" }
}
Write-Output 'V5 dependency checksums PASS'
