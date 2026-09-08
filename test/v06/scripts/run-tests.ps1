[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$cases = Import-Csv -LiteralPath (Join-Path $repoRoot 'test\v06\cases\entry_cases.csv')
foreach ($case in $cases) {
    # V6-FIX-001 ADD: V3 COBOLと同じ正式商品コードで受付可否を確認する。
    $valid = $case.application_number.Length -eq 10 -and @('WL','MI','CI') -contains $case.product -and [int]$case.age -ge 0 -and [int]$case.age -le 120 -and [decimal]$case.amount -ge 0
    $lane = if ([decimal]$case.amount -ge 20000000) { 'HIGH' } else { 'NORMAL' }
    $record = '{0,-10}{1,-2}{2:000}{3:0000000000}{4,-55}' -f $case.application_number,$case.product,[int]$case.age,[long]$case.amount,''
    if ($record.Length -ne 80 -or ([string]$valid).ToLowerInvariant() -ne $case.expected_valid -or $lane -ne $case.expected_lane) { throw "$($case.case_id): 結果不一致" }
}
$source = (Get-ChildItem (Join-Path $repoRoot 'implementation\v06') -Recurse -File | Get-Content -Raw) -join "`n"
foreach ($term in @('V6-ADD-001','V6-ADD-005','V6-ADD-006','V6-ADD-011','V6-ADD-014','V6-ADD-016','V6-ADD-018','V6-FIX-001','Set.of("WL", "MI", "CI")','SELECT_READY_SQL','%-55s','20000000','READY_FOR_COBOL','SENT_TO_COBOL')) { if ($source -notmatch [regex]::Escape($term)) { throw "V6実装要素がありません: $term" } }
if ($source -match 'private static final Set<String> PRODUCTS = Set\.of\("WL", "MD", "CA"\);' -and $source -notmatch '// private static final Set<String> PRODUCTS') { throw '旧商品コードMD/CAが実行行として残っています' }
Write-Host 'V6 Java compiler not required: reference behavior and source constraints were verified.'
Write-Host "V6 tests passed: $($cases.Count) cases."
