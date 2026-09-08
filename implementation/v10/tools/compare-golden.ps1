[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ExpectedPath,
    [Parameter(Mandatory)][string]$ActualPath,
    [Parameter(Mandatory)][ValidatePattern('^V(0[1-9]|10)$')][string]$SourceVersion,
    [Parameter(Mandatory)][string]$OutputPath
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'KnowledgeRecovery.psm1') -Force

# V10-ADD-009: 空白を含む固定長レコードを大文字小文字も含め完全一致で比較する。
$expected = @(Get-Content -LiteralPath $ExpectedPath)
$actual = @(Get-Content -LiteralPath $ActualPath)
$differences = @(Compare-GoldenRecords -Expected $expected -Actual $actual)
$result = [ordered]@{
    schemaVersion = 1
    # V10-FIX-001 ADD: 比較結果だけから根拠Versionと入出力を追跡可能にする。
    sourceVersion = $SourceVersion
    expectedPath = (Resolve-Path -LiteralPath $ExpectedPath).Path
    actualPath = (Resolve-Path -LiteralPath $ActualPath).Path
    expectedSha256 = (Get-FileHash -LiteralPath $ExpectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
    actualSha256 = (Get-FileHash -LiteralPath $ActualPath -Algorithm SHA256).Hash.ToLowerInvariant()
    expectedCount = $expected.Count
    actualCount = $actual.Count
    matched = $differences.Count -eq 0
    differenceCount = $differences.Count
    differences = $differences
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
$result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Host "V10 golden comparison: matched=$($result.matched), differences=$($differences.Count)"
