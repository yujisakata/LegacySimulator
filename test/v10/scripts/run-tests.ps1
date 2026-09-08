[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$tool = Join-Path $repoRoot 'implementation\v10\tools\recover-knowledge.ps1'
$input = Join-Path $repoRoot 'implementation\v10\evidence\knowledge_edges.csv'
$expected = Import-Csv (Join-Path $repoRoot 'test\v10\cases\expected_confidence.csv')
$work = Join-Path ([System.IO.Path]::GetTempPath()) ("legacy-v10-" + [guid]::NewGuid().ToString('N'))
$output = Join-Path $work 'knowledge_edges.json'
try {
    & $tool -InputPath $input -OutputPath $output
    $actual = Get-Content -Raw -LiteralPath $output | ConvertFrom-Json
    foreach ($case in $expected) {
        $edge = $actual.edges | Where-Object edgeId -eq $case.edge_id
        if ($null -eq $edge -or [decimal]$edge.confidence -ne [decimal]$case.expected_confidence -or $edge.status -ne $case.expected_status) {
            throw "$($case.edge_id): 確信度または状態が期待値と一致しません"
        }
    }
    $pending = $actual.edges | Where-Object status -eq 'PENDING'
    if ($pending.Count -ne 1 -or -not $pending[0].contradicted) { throw '反証ありエッジのレビュー状態が不正です' }
    $inventory = Join-Path $work 'inventory.json'
    & (Join-Path $repoRoot 'implementation\v10\tools\scan-artifacts.ps1') -RepositoryRoot $repoRoot -OutputPath $inventory
    $inventoryData = Get-Content -Raw -LiteralPath $inventory | ConvertFrom-Json
    foreach ($version in 1..10) {
        $versionId = 'V{0:00}' -f $version
        if (-not ($inventoryData.byVersion.version -contains $versionId)) { throw "資産棚卸しに $versionId がありません" }
    }
    $goldenExpected = Join-Path $work 'expected.dat'
    $goldenActual = Join-Path $work 'actual.dat'
    Set-Content -LiteralPath $goldenExpected -Value @('ABC  ','XYZ  ') -Encoding ascii
    Set-Content -LiteralPath $goldenActual -Value @('ABC  ','XYz  ') -Encoding ascii
    $comparison = Join-Path $work 'comparison.json'
    & (Join-Path $repoRoot 'implementation\v10\tools\compare-golden.ps1') -ExpectedPath $goldenExpected -ActualPath $goldenActual -SourceVersion V03 -OutputPath $comparison
    $comparisonData = Get-Content -Raw -LiteralPath $comparison | ConvertFrom-Json
    if ($comparisonData.matched -or $comparisonData.differenceCount -ne 1) { throw 'ゴールデン差分検出が期待値と一致しません' }
    if ($comparisonData.sourceVersion -ne 'V03' -or -not $comparisonData.expectedSha256 -or -not $comparisonData.actualSha256) { throw 'ゴールデン比較の根拠Versionまたは入力証跡がありません' }
    foreach ($version in 1..9) {
        $versionId = 'V{0}' -f $version
        if (-not ($actual.edges.version -contains $versionId)) { throw "知識エッジに $versionId の証拠がありません" }
    }
    $source = (Get-ChildItem (Join-Path $repoRoot 'implementation\v10') -Recurse -File | Get-Content -Raw) -join "`n"
    foreach ($term in @('V10-ADD-001','V10-ADD-003','V10-ADD-005','V10-ADD-008','V10-ADD-009','V10-ADD-010','V10-ADD-013','V10-ADD-015','V10-FIX-001','sourceVersion','expectedSha256','actualSha256','APPROVED_CANDIDATE','contradicted')) { if ($source -notmatch [regex]::Escape($term)) { throw "V10実装要素がありません: $term" } }
    Write-Host "V10 tests passed: $($expected.Count) evidence edges."
} finally {
    if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force }
}
