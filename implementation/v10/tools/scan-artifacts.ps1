[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RepositoryRoot,
    [Parameter(Mandatory)][string]$OutputPath
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'KnowledgeRecovery.psm1') -Force
$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path

# V10-ADD-008: 生成物・依存物を除き、設計復元に用いる原資産だけを棚卸しする。
$files = Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($root.Length)
    $relative -notmatch '[\\/](\.git|node_modules|build|dist|\.next)[\\/]'
}
$artifacts = @($files | ForEach-Object { [pscustomobject](Get-ArtifactEvidence -RepositoryRoot $root -File $_) })
$byVersion = @($artifacts | Group-Object version | Sort-Object Name | ForEach-Object {
    [ordered]@{ version=$_.Name; count=$_.Count; bytes=($_.Group | Measure-Object bytes -Sum).Sum }
})
$result = [ordered]@{
    schemaVersion = 1
    repositoryRoot = $root
    artifactCount = $artifacts.Count
    byVersion = $byVersion
    artifacts = $artifacts
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
$result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Host "V10 artifact inventory generated: $($artifacts.Count) -> $OutputPath"
