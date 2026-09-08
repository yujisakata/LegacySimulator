[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$runtimeRoot = Join-Path $PSScriptRoot '.runtime'

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

$targets = @(
    @{ Name = 'app'; Port = 3000; ProcessNames = @('node') },
    @{ Name = 'api'; Port = 4311; ProcessNames = @('python') }
)

foreach ($target in $targets) {
    $pidPath = Join-Path $runtimeRoot "$($target.Name).pid"
    if (-not (Test-Path -LiteralPath $pidPath)) {
        continue
    }

    $recordedProcessId = [int](Get-Content -LiteralPath $pidPath -Raw)
    $listenerProcessId = Get-ListenerProcessId -Port $target.Port
    $process = Get-Process -Id $recordedProcessId -ErrorAction SilentlyContinue
    $isExpectedProcess = $process -and (
        $target.ProcessNames -contains $process.ProcessName
    )

    if ($listenerProcessId -eq $recordedProcessId -and $isExpectedProcess) {
        Stop-Process -Id $recordedProcessId
        Write-Host "$($target.Name) を停止しました (PID $recordedProcessId)。"
    }
    else {
        Write-Host "$($target.Name) の記録済みPIDは、対象ポートのデモプロセスではありません。"
    }
    Remove-Item -LiteralPath $pidPath -Force
}
