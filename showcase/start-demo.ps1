[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [switch]$NoBrowser
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$showcaseRoot = $PSScriptRoot
$runtimeRoot = Join-Path $showcaseRoot '.runtime'
$logRoot = Join-Path $runtimeRoot 'logs'
$appUrl = 'http://127.0.0.1:3000'
$apiHealthUrl = 'http://127.0.0.1:4311/health'

New-Item -ItemType Directory -Path $logRoot -Force | Out-Null

function Wait-ForEndpoint {
    param([string]$Uri, [int]$Seconds = 25)
    $deadline = [DateTime]::UtcNow.AddSeconds($Seconds)
    do {
        try {
            $response = Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
                return $true
            }
        }
        catch {
            Start-Sleep -Milliseconds 350
        }
    } while ([DateTime]::UtcNow -lt $deadline)
    return $false
}

function Get-ListenerProcessId {
    param([int]$Port)
    $pattern = "^\s*TCP\s+127\.0\.0\.1:$Port\s+.*LISTENING\s+(\d+)\s*$"
    $match = netstat -ano -p tcp | Select-String -Pattern $pattern |
        Select-Object -First 1
    if ($match) {
        return [int]$match.Matches[0].Groups[1].Value
    }
    return $null
}

Write-Host '1/4 ワークスペースの実物証拠を更新しています…'
& (Join-Path $showcaseRoot 'scripts\generate-demo-data.ps1')

if (-not $SkipBuild) {
    Write-Host '2/4 デモ画面をビルドしています…'
    Push-Location $showcaseRoot
    try {
        & npm.cmd run build
        if ($LASTEXITCODE -ne 0) {
            throw "デモ画面のビルドが終了コード $LASTEXITCODE を返しました。"
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host '2/4 ビルドを省略しました。'
}

Write-Host '3/4 ローカル検証APIを確認しています…'
if (-not (Wait-ForEndpoint -Uri $apiHealthUrl -Seconds 1)) {
    $python = (Get-Command python -ErrorAction Stop).Source
    Start-Process -FilePath $python `
        -ArgumentList @('-u', (Join-Path $showcaseRoot 'local_api.py')) `
        -WorkingDirectory $showcaseRoot `
        -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $logRoot 'api.out.log') `
        -RedirectStandardError (Join-Path $logRoot 'api.err.log') | Out-Null
    if (-not (Wait-ForEndpoint -Uri $apiHealthUrl)) {
        throw "ローカル検証APIを確認できません。ログ: $logRoot"
    }
    $apiProcessId = Get-ListenerProcessId -Port 4311
    if (-not $apiProcessId) { throw '検証APIのプロセスIDを確認できません。' }
    Set-Content -LiteralPath (Join-Path $runtimeRoot 'api.pid') `
        -Value $apiProcessId -Encoding ascii
}

Write-Host '4/4 デモ画面を確認しています…'
if (-not (Wait-ForEndpoint -Uri $appUrl -Seconds 1)) {
    Start-Process -FilePath 'npm.cmd' `
        -ArgumentList @('run', 'start', '--', '--hostname', '127.0.0.1', '--port', '3000') `
        -WorkingDirectory $showcaseRoot `
        -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $logRoot 'app.out.log') `
        -RedirectStandardError (Join-Path $logRoot 'app.err.log') | Out-Null
    if (-not (Wait-ForEndpoint -Uri $appUrl)) {
        throw "デモ画面を確認できません。ログ: $logRoot"
    }
    $appProcessId = Get-ListenerProcessId -Port 3000
    if (-not $appProcessId) { throw 'デモ画面のプロセスIDを確認できません。' }
    Set-Content -LiteralPath (Join-Path $runtimeRoot 'app.pid') `
        -Value $appProcessId -Encoding ascii
}

Write-Host "Legacy Evolution デモを起動しました: $appUrl"
Write-Host "終了する場合: .\showcase\stop-demo.ps1"
if (-not $NoBrowser) {
    Start-Process $appUrl
}
