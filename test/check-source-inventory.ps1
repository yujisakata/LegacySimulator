[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$extensions = @('.cbl','.cpy','.jcl','.java','.sql','.xml','.ps1','.psm1')
$minimumFiles = @{ v04=5; v05=10; v06=12; v07=12; v08=15; v09=15; v10=10 }
$minimumLines = @{ v04=300; v05=300; v06=280; v07=200; v08=280; v09=260; v10=250 }

foreach ($version in 4..10) {
    $id = 'v{0:00}' -f $version
    $files = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot "implementation\$id") -Recurse -File |
        Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() })
    $lineCount = 0
    foreach ($file in $files) { $lineCount += @(Get-Content -LiteralPath $file.FullName).Count }
    if ($files.Count -lt $minimumFiles[$id]) {
        throw "$($id.ToUpperInvariant()): 実装資産数 $($files.Count) が下限 $($minimumFiles[$id]) 未満です"
    }
    if ($lineCount -lt $minimumLines[$id]) {
        throw "$($id.ToUpperInvariant()): 実装行数 $lineCount が下限 $($minimumLines[$id]) 未満です"
    }
    Write-Host "$($id.ToUpperInvariant()) source inventory: $($files.Count) files / $lineCount lines."
}

