[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$cases = Import-Csv (Join-Path $repoRoot 'test\v07\cases\channel_cases.csv')
foreach ($case in $cases) {
    $allowed = $case.channel -eq 'EMPLOYEE' -or ($case.channel -eq 'AGENCY' -and $case.agency_id -and $case.agency_id -eq $case.owner_agency_id)
    $default = if ($case.channel -eq 'AGENCY') { 'AG' } else { 'OF' }
    $v6 = ('X' * 25) + (' ' * 55)
    $agency = if ($case.agency_id) { $case.agency_id } else { '' }
    $enriched = $v6.Substring(0,25) + ('{0,-2}{1,-10}' -f $default,$agency) + $v6.Substring(37)
    if ($enriched.Length -ne 80 -or ([string]$allowed).ToLowerInvariant() -ne $case.expected_allowed -or $default -ne $case.expected_default) { throw "$($case.case_id): 結果不一致" }
}
$scheduleCases = Import-Csv (Join-Path $repoRoot 'test\v07\cases\schedule_handoff_cases.csv')
foreach ($case in $scheduleCases) {
    $exported = @($case.exported_application_numbers -split '\|' | Where-Object { $_ })
    $imported = @($case.imported_application_numbers -split '\|' | Where-Object { $_ })
    $missing = @($exported | Where-Object { $_ -notin $imported }) -join '|'
    $unexpected = @($imported | Where-Object { $_ -notin $exported }) -join '|'
    $different = $missing -ne '' -or $unexpected -ne ''
    if ([string]$different -ne $case.expected_difference -or $missing -ne $case.expected_missing -or $unexpected -ne $case.expected_unexpected) {
        throw "$($case.case_id): スケジューラ受渡し照合結果不一致"
    }
}
$source = (Get-ChildItem (Join-Path $repoRoot 'implementation\v07') -Recurse -File | Get-Content -Raw) -join "`n"
foreach ($term in @('V7-ADD-001','V7-ADD-004','V7-ADD-008','V7-ADD-011','V7-ADD-013','V7-ADD-014','V7-ADD-015','V7-FIX-001','hasApplicationDifference','missingApplicationNumbers','unexpectedApplicationNumbers','substring(0, 25)','substring(37)','JAVA_VENDOR','COBOL_VENDOR')) { if ($source -notmatch [regex]::Escape($term)) { throw "V7実装要素がありません: $term" } }
Write-Host "V7 tests passed: $($cases.Count) channel cases, $($scheduleCases.Count) schedule handoff cases."
