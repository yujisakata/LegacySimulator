[CmdletBinding()]
param(
    [switch]$ReferenceOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$testRoot = Join-Path $repoRoot 'test\v03'
$casePath = Join-Path $testRoot 'cases\medical_cases.csv'
$cases = Import-Csv -LiteralPath $casePath

function Pad-Exact {
    param([AllowEmptyString()][string]$Value, [int]$Length)
    if ($null -eq $Value) { $Value = '' }
    if ($Value.Length -gt $Length) {
        throw "Value '$Value' exceeds fixed length $Length."
    }
    return $Value.PadRight($Length, ' ')
}

function Pad-Numeric {
    param([AllowEmptyString()][string]$Value, [int]$Length)
    if ([string]::IsNullOrEmpty($Value)) { $Value = '0' }
    if ($Value.Length -gt $Length) {
        throw "Numeric value '$Value' exceeds fixed length $Length."
    }
    return $Value.PadLeft($Length, '0')
}

function New-ApplicationRecord {
    param($Case)
    $record = (
        (Pad-Exact $Case.AppNumber 10) +
        (Pad-Exact $Case.ApplicationDate 8) +
        (Pad-Exact $Case.DisclosureDate 8) +
        (Pad-Exact $Case.PremiumDate 8) +
        (Pad-Exact $Case.ReceiptDate 8) +
        (Pad-Exact $Case.ProcessDate 8) +
        (Pad-Exact $Case.DeficiencyDate 8) +
        (Pad-Numeric $Case.Age 2) +
        (Pad-Numeric $Case.Amount 8) +
        (Pad-Exact $Case.Product 2) +
        (Pad-Exact $Case.DocumentComplete 1) +
        (Pad-Exact $Case.MedicalClass 1) +
        (Pad-Exact $Case.ManagerDecision 1) +
        (Pad-Exact $Case.Withdrawal 1) +
        (Pad-Exact $Case.ReservedData 46)
    )
    if ($record.Length -ne 120) {
        throw "$($Case.CaseId): input length is not 120."
    }
    return $record
}

function New-ExpectedRecord {
    param($Case)
    $record = (
        (Pad-Exact $Case.AppNumber 10) +
        (Pad-Exact $Case.ExpectedCode 2) +
        (Pad-Exact $Case.ExpectedApproval 1) +
        (Pad-Exact $Case.ExpectedReason 3) +
        (Pad-Exact $Case.ExpectedResponsibility 8) +
        (Pad-Exact $Case.ProcessDate 8) +
        (Pad-Exact $Case.ReceiptDate 8) +
        (' ' * 40)
    )
    if ($record.Length -ne 80) {
        throw "$($Case.CaseId): expected length is not 80."
    }
    return $record
}

$inputRecords = @($cases | ForEach-Object {
    New-ApplicationRecord $_
})
$expectedRecords = @($cases | ForEach-Object {
    New-ExpectedRecord $_
})

Write-Host "V3 reference fixtures verified: $($cases.Count) cases."

if ($ReferenceOnly) {
    Write-Host 'COBOL execution skipped by -ReferenceOnly.'
    exit 0
}

$workDirectory = Join-Path ([System.IO.Path]::GetTempPath()) (
    'legacy-simulator-v3-' + [guid]::NewGuid().ToString('N')
)
New-Item -ItemType Directory -Path $workDirectory | Out-Null

try {
    $buildScript = Join-Path $PSScriptRoot 'build-v03.ps1'
    & $buildScript -OutputDirectory $workDirectory

    Set-Content -LiteralPath (
        Join-Path $workDirectory 'MEDICAL.DAT'
    ) -Value $inputRecords -Encoding ascii

    $env:COB_LS_FIXED = 'TRUE'
    $oldLocation = Get-Location
    try {
        Set-Location $workDirectory
        $runningOnWindows = (
            [System.Environment]::OSVersion.Platform -eq
            [System.PlatformID]::Win32NT
        )
        $executableName = if ($runningOnWindows) {
            'MDASSESS.exe'
        }
        else {
            'MDASSESS'
        }
        & (Join-Path $workDirectory $executableName)
        if ($LASTEXITCODE -ne 0) {
            throw "MDASSESS returned $LASTEXITCODE."
        }
    }
    finally {
        Set-Location $oldLocation
    }

    $actualRecords = @(Get-Content -LiteralPath (
        Join-Path $workDirectory 'MEDASSESS.DAT'
    ))
    if ($actualRecords.Count -ne $expectedRecords.Count) {
        throw 'COBOL output record count differs from declarations.'
    }

    for ($index = 0; $index -lt $actualRecords.Count; $index++) {
        if ($actualRecords[$index] -cne $expectedRecords[$index]) {
            $expectedVisible = $expectedRecords[$index].Replace(' ', '·')
            $actualVisible = $actualRecords[$index].Replace(' ', '·')
            Write-Host "Expected: $expectedVisible"
            Write-Host "Actual  : $actualVisible"
            throw "COBOL output mismatch: $($cases[$index].CaseId)."
        }
    }

    Write-Host "V3 COBOL comparison passed: $($cases.Count) records."
}
finally {
    if (Test-Path -LiteralPath $workDirectory) {
        Remove-Item -LiteralPath $workDirectory -Recurse -Force
    }
}

