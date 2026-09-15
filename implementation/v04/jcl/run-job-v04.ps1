[CmdletBinding()]
param([Parameter(Mandatory)][string]$WorkDirectory)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$workPath = (Resolve-Path -LiteralPath $WorkDirectory).Path
foreach ($name in @('APPLICATION.DAT','MEDICAL.DAT','REGDATE.DAT')) {
    if (-not (Test-Path -LiteralPath (Join-Path $workPath $name) -PathType Leaf)) {
        throw "Input file is missing: $name"
    }
}
$binPath = Join-Path $repoRoot 'build\v04'
& (Join-Path $repoRoot 'test\v04\scripts\build-v04.ps1') -OutputDirectory $binPath
$previousFixed = $env:COB_LS_FIXED
$env:COB_LS_FIXED = 'TRUE'
Push-Location $workPath
try {
    foreach ($program in @('NBASSESS.exe','MDASSESS.exe')) {
        & (Join-Path $binPath $program)
        if ($LASTEXITCODE -ne 0) {
            throw "$program failed: $LASTEXITCODE. Outputs are not a completed job result."
        }
    }
} finally {
    Pop-Location
    $env:COB_LS_FIXED = $previousFixed
}
