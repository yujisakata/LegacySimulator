[CmdletBinding()]
param([string]$OutputDirectory)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $repoRoot 'build\v04' }
$compiler = Get-Command cobc -ErrorAction SilentlyContinue
$compilerPath = if ($compiler) { $compiler.Source } else { $null }
if (-not $compilerPath) {
    $compilerPath = @('C:\msys64\ucrt64\bin\cobc.exe','C:\msys64\mingw64\bin\cobc.exe') |
        Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (-not $compilerPath) { throw 'GnuCOBOL compiler (cobc) was not found.' }
$compilerDirectory = Split-Path -Parent $compilerPath
$gnuCobolRoot = Split-Path -Parent $compilerDirectory
$env:Path = "$compilerDirectory;$env:Path"
$env:COB_CONFIG_DIR = Join-Path $gnuCobolRoot 'share\gnucobol\config'
$env:COB_COPY_DIR = Join-Path $gnuCobolRoot 'share\gnucobol\copy'
$env:COB_LIBRARY_PATH = Join-Path $gnuCobolRoot 'lib\gnucobol'
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$copyDirectory = Join-Path $repoRoot 'implementation\v04\copybook'
$targets = @(
    @{ Name='RGASSESS.exe'; Source='implementation\v04\batch\RGASSESS.cbl' },
    @{ Name='RGENTRY.exe'; Source='implementation\v04\online\RGENTRY.cbl' }
)
foreach ($item in $targets) {
    $target = Join-Path $OutputDirectory $item.Name
    & $compilerPath -x -fixed -I $copyDirectory -o $target (Join-Path $repoRoot $item.Source)
    if ($LASTEXITCODE -ne 0) { throw "V4 COBOL compilation failed: $($item.Name)" }
}
Write-Host "V4 COBOL programs built in: $OutputDirectory"
