[CmdletBinding()]
param([switch]$ReferenceOnly)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$cases = Import-Csv -LiteralPath (Join-Path $repoRoot 'test\v04\cases\regulatory_cases.csv')

function Pad([string]$Value, [int]$Length) { return $Value.PadRight($Length, ' ') }
$inputRecords = @($cases | ForEach-Object {
    (Pad $_.AppNumber 10) + $_.ReceiptDate + $_.DisclosureDate +
    $_.Redisclosure + $_.OldAnswer + $_.NewAnswer + (' ' * 51)
})
$expectedRecords = @($cases | ForEach-Object {
    (Pad $_.AppNumber 10) + $_.ExpectedRule + $_.ExpectedCode +
    $_.ExpectedReason + $_.ExpectedAppliedDate + (' ' * 14)
})
for ($index = 0; $index -lt $cases.Count; $index++) {
    if ($inputRecords[$index].Length -ne 80) { throw "$($cases[$index].CaseId): input length error." }
    if ($expectedRecords[$index].Length -ne 40) { throw "$($cases[$index].CaseId): output length error." }
}
Write-Host "V4 reference fixtures verified: $($cases.Count) cases."
if ($ReferenceOnly) { exit 0 }

$workDirectory = Join-Path ([IO.Path]::GetTempPath()) ('legacy-simulator-v4-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $workDirectory | Out-Null
try {
    & (Join-Path $PSScriptRoot 'build-v04.ps1') -OutputDirectory $workDirectory
    foreach ($program in @('RGASSESS.exe','RGENTRY.exe')) {
        if (-not (Test-Path -LiteralPath (Join-Path $workDirectory $program))) {
            throw "V4 build output was not found: $program"
        }
    }
    Set-Content -LiteralPath (Join-Path $workDirectory 'DISCLOSE.DAT') -Value $inputRecords -Encoding ascii
    $env:COB_LS_FIXED = 'TRUE'
    Push-Location $workDirectory
    try { & (Join-Path $workDirectory 'RGASSESS.exe') } finally { Pop-Location }
    if ($LASTEXITCODE -ne 0) { throw "RGASSESS returned $LASTEXITCODE." }
    $actual = @(Get-Content -LiteralPath (Join-Path $workDirectory 'RGRESULT.DAT'))
    for ($index = 0; $index -lt $expectedRecords.Count; $index++) {
        if ($actual[$index] -cne $expectedRecords[$index]) { throw "V4 mismatch: $($cases[$index].CaseId)" }
    }
    Write-Host "V4 COBOL comparison passed: $($actual.Count) records."
}
finally {
    if (Test-Path -LiteralPath $workDirectory) { Remove-Item -LiteralPath $workDirectory -Recurse -Force }
}
