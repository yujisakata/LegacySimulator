[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Write-Host '===== SOURCE INVENTORY ====='
& (Join-Path $repoRoot 'test\check-source-inventory.ps1')

foreach ($version in 1..10) {
    $versionId = 'v{0:00}' -f $version
    $script = Join-Path $repoRoot "test\$versionId\scripts\run-tests.ps1"
    if (-not (Test-Path -LiteralPath $script)) { throw "テストスクリプトがありません: $versionId" }
    Write-Host "===== $($versionId.ToUpperInvariant()) ====="
    & $script
}

Write-Host 'V1～V10の全Version検証が完了しました。'
