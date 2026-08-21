[CmdletBinding()]
param(
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$implementationRoot = Join-Path $repoRoot 'implementation\v01'
$copybookDirectory = Join-Path $implementationRoot 'copybook'

if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $repoRoot 'build\v01'
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
        $compiler = Get-Item -LiteralPath $compilerPath
    }
}
if (-not $compiler) {
    throw 'GnuCOBOL compiler (cobc) was not found on PATH.'
}

# MSYS2版cobc.exeを通常のPowerShellから呼ぶための環境設定。
$compilerDirectory = Split-Path -Parent $compiler.Source
$gnuCobolRoot = Split-Path -Parent $compilerDirectory
$configDirectory = Join-Path $gnuCobolRoot 'share\gnucobol\config'
$copyDirectory = Join-Path $gnuCobolRoot 'share\gnucobol\copy'
$libraryDirectory = Join-Path $gnuCobolRoot 'lib\gnucobol'
if (Test-Path -LiteralPath $configDirectory) {
    $env:Path = "$compilerDirectory;$env:Path"
    $env:COB_CONFIG_DIR = $configDirectory
    $env:COB_COPY_DIR = $copyDirectory
    $env:COB_LIBRARY_PATH = $libraryDirectory
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$programs = @(
    @{ Name = 'NBASSESS'; Source = 'batch\NBASSESS.cbl' },
    @{ Name = 'NBENTRY'; Source = 'online\NBENTRY.cbl' }
)

foreach ($program in $programs) {
    $source = Join-Path $implementationRoot $program.Source
    $runningOnWindows = [System.Environment]::OSVersion.Platform -eq `
        [System.PlatformID]::Win32NT
    $targetName = if ($runningOnWindows) {
        "$($program.Name).exe"
    }
    else {
        $program.Name
    }
    $target = Join-Path $OutputDirectory $targetName
    & $compiler.Source -x -fixed -I $copybookDirectory -o $target $source
    if ($LASTEXITCODE -ne 0) {
        throw "COBOL compilation failed: $($program.Name)"
    }
}

Write-Host "V1 COBOL programs built in: $OutputDirectory"
