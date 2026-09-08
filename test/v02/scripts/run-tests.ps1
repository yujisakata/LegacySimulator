[CmdletBinding()]
param(
    [switch]$ReferenceOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$v1TestRoot = Join-Path $repoRoot 'test\v01'
$v2TestRoot = Join-Path $repoRoot 'test\v02'
$v1Cases = Import-Csv -LiteralPath (
    Join-Path $v1TestRoot 'cases\assessment_cases.csv'
)
$v1Golden = @(Get-Content -LiteralPath (
    Join-Path $v1TestRoot 'expected\ASSESSMENT.DAT'
))
$v2Cases = Import-Csv -LiteralPath (
    Join-Path $v2TestRoot 'cases\rider_cases.csv'
)

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

function New-MainInput {
    param($Case)
    return (
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
        (Pad-Exact $Case.Withdrawal 1)
    )
}

function New-V1-CompatibleInput {
    param($Case)
    return (New-MainInput $Case) + (' ' * 46)
}

function New-V2Input {
    param($Case)
    return (
        (New-MainInput $Case) +
        (Pad-Exact $Case.AdCode 2) +
        (Pad-Numeric $Case.AdAmount 8) +
        (Pad-Exact $Case.AdDecision 1) +
        (Pad-Exact $Case.HiCode 2) +
        (Pad-Numeric $Case.HiBenefit 6) +
        (Pad-Exact $Case.HiDecision 1) +
        (' ' * 26)
    )
}

function New-No-RiderResultTail {
    return (
        'N' + 'N' + '000' + '00000000' +
        'N' + 'N' + '000' + '000000' + (' ' * 16)
    )
}

function New-V2Expected {
    param($Case)
    return (
        (Pad-Exact $Case.AppNumber 10) +
        (Pad-Exact $Case.ExpectedCode 2) +
        (Pad-Exact $Case.ExpectedApproval 1) +
        (Pad-Exact $Case.ExpectedReason 3) +
        (Pad-Exact $Case.ExpectedResponsibility 8) +
        (Pad-Exact $Case.ProcessDate 8) +
        (Pad-Exact $Case.ReceiptDate 8) +
        (Pad-Exact $Case.ExpectedAdResult 1) +
        (Pad-Exact $Case.ExpectedAdApproval 1) +
        (Pad-Exact $Case.ExpectedAdReason 3) +
        (Pad-Numeric $Case.ExpectedAdAmount 8) +
        (Pad-Exact $Case.ExpectedHiResult 1) +
        (Pad-Exact $Case.ExpectedHiApproval 1) +
        (Pad-Exact $Case.ExpectedHiReason 3) +
        (Pad-Numeric $Case.ExpectedHiBenefit 6) +
        (' ' * 16)
    )
}

$inputRecords = [System.Collections.Generic.List[string]]::new()
$expectedRecords = [System.Collections.Generic.List[string]]::new()
$caseIds = [System.Collections.Generic.List[string]]::new()

for ($index = 0; $index -lt $v1Cases.Count; $index++) {
    $inputRecords.Add((New-V1-CompatibleInput $v1Cases[$index]))
    $expectedRecords.Add(
        $v1Golden[$index].Substring(0, 40) +
        (New-No-RiderResultTail)
    )
    $caseIds.Add("COMPAT-$($v1Cases[$index].CaseId)")
}

foreach ($case in $v2Cases) {
    $inputRecords.Add((New-V2Input $case))
    $expectedRecords.Add((New-V2Expected $case))
    $caseIds.Add($case.CaseId)
}

for ($index = 0; $index -lt $inputRecords.Count; $index++) {
    if ($inputRecords[$index].Length -ne 120) {
        throw "$($caseIds[$index]): input length is not 120."
    }
    if ($expectedRecords[$index].Length -ne 80) {
        throw "$($caseIds[$index]): expected length is not 80."
    }
}

Write-Host (
    "Reference fixtures verified: {0} V1 compatibility + {1} V2 cases." -f
    $v1Cases.Count, $v2Cases.Count
)

if ($ReferenceOnly) {
    Write-Host 'COBOL execution skipped by -ReferenceOnly.'
    exit 0
}

$workDirectory = Join-Path ([System.IO.Path]::GetTempPath()) (
    'legacy-simulator-v2-' + [guid]::NewGuid().ToString('N')
)
New-Item -ItemType Directory -Path $workDirectory | Out-Null

try {
    $buildScript = Join-Path $PSScriptRoot 'build-v02.ps1'
    & $buildScript -OutputDirectory $workDirectory

    $inputPath = Join-Path $workDirectory 'APPLICATION.DAT'
    Set-Content -LiteralPath $inputPath -Value $inputRecords -Encoding ascii

    $env:COB_LS_FIXED = 'TRUE'
    $oldLocation = Get-Location
    try {
        Set-Location $workDirectory
        $runningOnWindows = (
            [System.Environment]::OSVersion.Platform -eq
            [System.PlatformID]::Win32NT
        )
        $executableName = if ($runningOnWindows) {
            'NBASSESS.exe'
        }
        else {
            'NBASSESS'
        }
        & (Join-Path $workDirectory $executableName)
        if ($LASTEXITCODE -ne 0) {
            throw "NBASSESS returned $LASTEXITCODE."
        }
    }
    finally {
        Set-Location $oldLocation
    }

    $actualRecords = @(Get-Content -LiteralPath (
        Join-Path $workDirectory 'ASSESSMENT.DAT'
    ))
    if ($actualRecords.Count -ne $expectedRecords.Count) {
        throw 'COBOL output record count differs from declarations.'
    }

    for ($index = 0; $index -lt $actualRecords.Count; $index++) {
        if ($index -lt $v1Cases.Count) {
            if ($actualRecords[$index].Substring(0, 40) -cne
                $v1Golden[$index].Substring(0, 40)) {
                throw (
                    'V1 main-contract compatibility mismatch: ' +
                    $caseIds[$index]
                )
            }
        }
        if ($actualRecords[$index] -cne $expectedRecords[$index]) {
            $expectedVisible = $expectedRecords[$index].Replace(' ', '·')
            $actualVisible = $actualRecords[$index].Replace(' ', '·')
            Write-Host "Expected: $expectedVisible"
            Write-Host "Actual  : $actualVisible"
            throw "COBOL output mismatch: $($caseIds[$index])."
        }
    }

    Write-Host (
        "V2 COBOL comparison passed: {0} records." -f
        $actualRecords.Count
    )
}
finally {
    if (Test-Path -LiteralPath $workDirectory) {
        Remove-Item -LiteralPath $workDirectory -Recurse -Force
    }
}
