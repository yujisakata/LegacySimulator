[CmdletBinding()]
param([switch]$ReferenceOnly)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$outputDirectory = Join-Path $repoRoot 'build\v04'
$verify = Join-Path $PSScriptRoot 'verify_v04.py'
if ($ReferenceOnly) {
    & python $verify --bin $outputDirectory --reference-only
} else {
    & (Join-Path $PSScriptRoot 'build-v04.ps1') -OutputDirectory $outputDirectory
    & python $verify --bin $outputDirectory
}
if ($LASTEXITCODE -ne 0) { throw "V4 verification failed: $LASTEXITCODE" }
