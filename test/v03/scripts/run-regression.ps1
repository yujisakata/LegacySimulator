[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path

Write-Host '2026年追加検証: V1全19件'
& (Join-Path $repoRoot 'test\v01\scripts\run-tests.ps1')

Write-Host '2026年追加検証: V2互換・特約全53件'
& (Join-Path $repoRoot 'test\v02\scripts\run-tests.ps1')

Write-Host 'V3リリース範囲: 医療系商品全32件'
& (Join-Path $repoRoot 'test\v03\scripts\run-tests.ps1')

Write-Host 'V1～V3回帰検証が完了しました。'

