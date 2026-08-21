[CmdletBinding()]
param(
    [switch]$ReferenceOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$testRoot = Join-Path $repoRoot 'test\v01'
$casePath = Join-Path $testRoot 'cases\assessment_cases.csv'
$expectedPath = Join-Path $testRoot 'expected\ASSESSMENT.DAT'
$cases = Import-Csv -LiteralPath $casePath

function Pad-Exact {
    param([AllowEmptyString()][string]$Value, [int]$Length)
    if ($null -eq $Value) { $Value = '' }
    if ($Value.Length -gt $Length) {
        throw "Value '$Value' exceeds fixed length $Length."
    }
    return $Value.PadRight($Length, ' ')
}

function New-ApplicationRecord {
    param($Case)
    $record =
        (Pad-Exact $Case.AppNumber 10) +
        (Pad-Exact $Case.ApplicationDate 8) +
        (Pad-Exact $Case.DisclosureDate 8) +
        (Pad-Exact $Case.PremiumDate 8) +
        (Pad-Exact $Case.ReceiptDate 8) +
        (Pad-Exact $Case.ProcessDate 8) +
        (Pad-Exact $Case.DeficiencyDate 8) +
        $Case.Age.PadLeft(2, '0') +
        $Case.Amount.PadLeft(8, '0') +
        (Pad-Exact $Case.Product 2) +
        (Pad-Exact $Case.DocumentComplete 1) +
        (Pad-Exact $Case.MedicalClass 1) +
        (Pad-Exact $Case.ManagerDecision 1) +
        (Pad-Exact $Case.Withdrawal 1) +
        (' ' * 46)
    if ($record.Length -ne 120) {
        throw "$($Case.CaseId): input record length is $($record.Length)."
    }
    return $record
}

function New-ExpectedRecord {
    param($Case)
    $record =
        (Pad-Exact $Case.AppNumber 10) +
        (Pad-Exact $Case.ExpectedCode 2) +
        (Pad-Exact $Case.ExpectedApproval 1) +
        (Pad-Exact $Case.ExpectedReason 3) +
        (Pad-Exact $Case.ExpectedResponsibility 8) +
        (Pad-Exact $Case.ProcessDate 8) +
        (Pad-Exact $Case.ReceiptDate 8) +
        (' ' * 40)
    if ($record.Length -ne 80) {
        throw "$($Case.CaseId): expected record length is $($record.Length)."
    }
    return $record
}

$inputRecords = @($cases | ForEach-Object { New-ApplicationRecord $_ })
$declaredRecords = @($cases | ForEach-Object { New-ExpectedRecord $_ })
$checkedInExpected = @(Get-Content -LiteralPath $expectedPath)

if ($declaredRecords.Count -ne $checkedInExpected.Count) {
    throw 'Golden file record count differs from case declarations.'
}

for ($index = 0; $index -lt $declaredRecords.Count; $index++) {
    if ($declaredRecords[$index] -cne $checkedInExpected[$index]) {
        throw "Golden declaration mismatch at record $($index + 1)."
    }
    if ($checkedInExpected[$index].Length -ne 80) {
        throw "Golden record $($index + 1) is not 80 characters."
    }
}

Write-Host "Reference fixtures verified: $($cases.Count) cases."

if ($ReferenceOnly) {
    Write-Host 'COBOL execution skipped by -ReferenceOnly.'
    exit 0
}

$compiler = Get-Command cobc -ErrorAction SilentlyContinue
if (-not $compiler) {
    $knownCompilerPaths = @(
        'C:\msys64\ucrt64\bin\cobc.exe',
        'C:\msys64\mingw64\bin\cobc.exe'
    )
    $compilerPath = $knownCompilerPaths |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1
    if ($compilerPath) {
        $compilerDirectory = Split-Path -Parent $compilerPath
        $env:Path = "$compilerDirectory;$env:Path"
        $compiler = Get-Command cobc -ErrorAction SilentlyContinue
    }
}
if (-not $compiler) {
    throw 'GnuCOBOL compiler (cobc) was not found. Use -ReferenceOnly for fixture validation.'
}

$workDirectory = Join-Path ([System.IO.Path]::GetTempPath()) `
    ("legacy-simulator-v1-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $workDirectory | Out-Null

try {
    $buildScript = Join-Path $PSScriptRoot 'build-v01.ps1'
    & $buildScript -OutputDirectory $workDirectory

    $inputPath = Join-Path $workDirectory 'APPLICATION.DAT'
    Set-Content -LiteralPath $inputPath -Value $inputRecords -Encoding ascii

    # V1インターフェースは固定長。GnuCOBOLのLINE SEQUENTIALで
    # 末尾空白を保持する。
    $env:COB_LS_FIXED = 'TRUE'

    $oldLocation = Get-Location
    try {
        Set-Location $workDirectory
        $runningOnWindows = [System.Environment]::OSVersion.Platform -eq `
            [System.PlatformID]::Win32NT
        $executableName = if ($runningOnWindows) {
            'NBASSESS.exe'
        }
        else {
            'NBASSESS'
        }
        $executable = Join-Path $workDirectory $executableName
        & $executable
        if ($LASTEXITCODE -ne 0) {
            throw "NBASSESS returned $LASTEXITCODE."
        }
    }
    finally {
        Set-Location $oldLocation
    }

    $actualPath = Join-Path $workDirectory 'ASSESSMENT.DAT'
    $actualRecords = @(Get-Content -LiteralPath $actualPath)
    if ($actualRecords.Count -ne $checkedInExpected.Count) {
        throw 'COBOL output record count differs from the golden file.'
    }

    for ($index = 0; $index -lt $actualRecords.Count; $index++) {
        if ($actualRecords[$index] -cne $checkedInExpected[$index]) {
            $caseId = $cases[$index].CaseId
            $expectedVisible = $checkedInExpected[$index].Replace(' ', '·')
            $actualVisible = $actualRecords[$index].Replace(' ', '·')
            Write-Host "Expected[$($checkedInExpected[$index].Length)]: $expectedVisible"
            Write-Host "Actual  [$($actualRecords[$index].Length)]: $actualVisible"
            throw "COBOL output mismatch: $caseId (record $($index + 1))."
        }
    }

    Write-Host "COBOL golden comparison passed: $($cases.Count) cases."
}
finally {
    if (Test-Path -LiteralPath $workDirectory) {
        Remove-Item -LiteralPath $workDirectory -Recurse -Force
    }
}
