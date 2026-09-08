[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$casePath = Join-Path $repoRoot 'test\v05\cases\inquiry_cases.csv'
$sourceRoot = Join-Path $repoRoot 'implementation\v05'
$cases = Import-Csv -LiteralPath $casePath

foreach ($case in $cases) {
    if ($case.input.Length -ne 40) { throw "$($case.case_id): 入力長が40ではありません" }
    $status = $case.input.Substring(10, 2).Trim()
    $amountText = $case.input.Substring(12, 10).Trim()
    $asOf = [datetime]::ParseExact($case.input.Substring(22, 8), 'yyyyMMdd', $null).ToString('yyyy-MM-dd')
    $actualStatus = if ($status) { $status } else { '<NULL>' }
    $actualAmount = if ($amountText) { [decimal]$amountText } else { '<NULL>' }
    if ([string]$actualStatus -ne $case.expected_status -or [string]$actualAmount -ne $case.expected_amount -or $asOf -ne $case.expected_as_of) {
        throw "$($case.case_id): 変換結果が期待値と一致しません"
    }
}

$javaText = (Get-ChildItem -LiteralPath (Join-Path $sourceRoot 'java') -Recurse -Filter '*.java' | Get-Content -Raw) -join "`n"
$sqlText = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'sql\inquiry_schema.sql')
foreach ($marker in @('V5-ADD-001', 'V5-ADD-002', 'V5-ADD-003')) {
    if ($javaText -notmatch [regex]::Escape($marker)) { throw "変更識別コメント $marker がありません" }
}
$daoText = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'java\com\legacysimulator\v05\JdbcInquiryDao.java')
if ($daoText -match '(?i)\b(update|insert|delete)\b' -or $daoText -notmatch 'setReadOnly\(true\)') {
    throw 'Web照会DAOの参照専用制約が確認できません'
}
if ($javaText -match '(?i)CONTRACT_MASTER') { throw 'Java実装がCOBOL契約原簿を直接参照しています' }
if ($javaText -notmatch 'INSERT INTO INQUIRY_SNAPSHOT') { throw '夜間取込が照会用複製DBを対象にしていません' }

$javac = Get-Command javac -ErrorAction SilentlyContinue
if ($javac) {
    Write-Host "V5 JDK detected: $($javac.Source)"
} else {
    Write-Host 'V5 Java compiler not found: reference conversion and source constraints were verified.'
}
Write-Host "V5 tests passed: $($cases.Count) conversion cases."
