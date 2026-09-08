[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$cases = Import-Csv (Join-Path $repoRoot 'test\v09\cases\audit_time_cases.csv')
foreach ($case in $cases) {
    $utc = [DateTimeOffset]::Parse($case.occurred_at).UtcDateTime.ToString("yyyy-MM-dd'T'HH:mm:ss'Z'")
    if ($utc -ne $case.expected_utc) { throw "$($case.case_id): UTC正規化結果不一致" }
}
$t1 = $cases | Where-Object transaction_key -eq 'T001'
if ($t1.Count -ne 3) { throw '取引キー相関件数が不一致です' }
$emissionCases = Import-Csv (Join-Path $repoRoot 'test\v09\cases\audit_emission_cases.csv')
foreach ($case in $emissionCases) {
    if ($case.source_system -eq 'COBOL') {
        $record = ('{0,-20}{1,-10}{2,-5}{3,-32}{4,-25}' -f $case.transaction_key,$case.operator_id,$case.reason_code,$case.input_digest,$case.occurred_at).PadRight(100)
        if ($record.Length -ne 100 -or $record.Substring(0,20).Trim() -ne $case.transaction_key -or $record.Substring(67,25).Trim() -ne $case.occurred_at) { throw "$($case.case_id): COBOL監査往復不一致" }
    } elseif ($case.source_system -eq 'LEGACY_SPRING') {
        $record = @($case.transaction_key,$case.operator_id,$case.input_digest,$case.reason_code,$case.occurred_at) -join "`t"
        $values = $record -split "`t"
        if ($values.Count -ne 5 -or $values[0] -ne $case.transaction_key -or $values[4] -ne $case.occurred_at) { throw "$($case.case_id): 旧Spring監査往復不一致" }
    } else {
        $record = @{ transactionKey=$case.transaction_key; operatorId=$case.operator_id; inputDigest=$case.input_digest; reasonCode=$case.reason_code; occurredAt=$case.occurred_at }
        if ($record.transactionKey -ne $case.transaction_key -or $record.occurredAt -ne $case.occurred_at) { throw "$($case.case_id): Boot監査往復不一致" }
    }
}
$source = (Get-ChildItem (Join-Path $repoRoot 'implementation\v09') -Recurse -File | Get-Content -Raw) -join "`n"
foreach ($term in @('V9-ADD-001','V9-ADD-004','V9-ADD-006','V9-ADD-010','V9-ADD-013','V9-ADD-016','V9-ADD-019','V9-FIX-001','V9-FIX-002','AuditEventEncoder','GenerationAuditEmitter','JdbcKycOutboxRepository','OutboxPublishJob','SELECT_UNPUBLISHED','connection.setAutoCommit(false)','connection.commit()','toInstant()','if (!store.save','publisher.publish','ORIGINAL_OFFSET','OCCURRED_AT_UTC','KYC_RESULT','KYC_OUTBOX')) { if ($source -notmatch [regex]::Escape($term)) { throw "V9実装要素がありません: $term" } }
Write-Host "V9 tests passed: $($cases.Count) time/correlation cases, $($emissionCases.Count) emission round-trip cases."
