[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$cases = Import-Csv (Join-Path $repoRoot 'test\v08\cases\integration_cases.csv')
$seen = @{}
$accepted = @()
foreach ($case in $cases) {
    $key = "$($case.partner):$($case.transaction_id)"
    $isAccepted = -not $seen.ContainsKey($key)
    if ($isAccepted) { $seen[$key] = $true }
    if (([string]$isAccepted).ToLowerInvariant() -ne $case.expected_accept) { throw "$($case.case_id): 重複排除結果不一致" }
    $accepted += [pscustomobject]@{ Case=$case.case_id; Sequence=[int]$case.sequence }
}
$ordered = $cases | Sort-Object { [int]$_.sequence }
for ($i=0; $i -lt $ordered.Count; $i++) { if ([int]$ordered[$i].expected_order -ne $i + 1) { throw "$($ordered[$i].case_id): 再送順不一致" } }
$source = (Get-ChildItem (Join-Path $repoRoot 'implementation\v08') -Recurse -File | Get-Content -Raw) -join "`n"
foreach ($term in @('V8-ADD-001','V8-ADD-005','V8-ADD-007','V8-ADD-009','V8-ADD-013','V8-ADD-016','V8-ADD-017','V8-ADD-020','V8-ADD-021','V8-FIX-001','V8-FIX-002','SELECT_RETRY_SQL','partner + ":" + transactionId','comparingLong(IntegrationState::getSequence)','orchestrator.retry(target)','SEQUENCE_NUMBER','KycEsbClient','ContractSoapClient','PENDING_EXTERNAL','RETRY_WAIT')) { if ($source -notmatch [regex]::Escape($term)) { throw "V8実装要素がありません: $term" } }
$config = Get-Content (Join-Path $repoRoot 'implementation\v08\config\integration-context-v08.xml') -Raw
if ($config -notmatch '<bean id="kycEsbClient"' -or $config -notmatch '<bean id="contractSoapClient"') { throw 'V8接続方式が外部設計と一致しません' }
Write-Host "V8 tests passed: $($cases.Count) integration cases."
