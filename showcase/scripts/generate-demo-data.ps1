[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$showcaseRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$repoRoot = (Resolve-Path (Join-Path $showcaseRoot '..')).Path
$manifestPath = Join-Path $showcaseRoot 'evidence.manifest.json'
$outputPath = Join-Path $showcaseRoot 'public\demo-data.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw |
    ConvertFrom-Json

foreach ($version in $manifest.versions) {
    foreach ($evidence in $version.evidence) {
        $relativePath = $evidence.path -replace '/', '\'
        $filePath = Join-Path $repoRoot $relativePath
        if (-not (Test-Path -LiteralPath $filePath)) {
            throw "Evidence file was not found: $($evidence.path)"
        }
        $allLines = @(Get-Content -LiteralPath $filePath)
        $start = [Math]::Max(1, [int]$evidence.start)
        $end = [Math]::Min($allLines.Count, [int]$evidence.end)
        $renderedLines = [System.Collections.Generic.List[object]]::new()
        for ($lineNumber = $start; $lineNumber -le $end; $lineNumber++) {
            $renderedLines.Add([ordered]@{
                number = $lineNumber
                text = $allLines[$lineNumber - 1]
            })
        }
        $evidence | Add-Member -NotePropertyName lines -NotePropertyValue $renderedLines
        $evidence | Add-Member -NotePropertyName actualEnd -NotePropertyValue $end
        $codeExtensions = @('.cbl', '.cpy', '.jcl', '.java', '.ps1', '.sql', '.xml')
        $viewType = if ($codeExtensions -contains [IO.Path]::GetExtension($filePath).ToLowerInvariant()) {
            'code'
        }
        else {
            'document'
        }
        $evidence | Add-Member -NotePropertyName viewType -NotePropertyValue $viewType
    }
}

$artifactCount = @(
    Get-ChildItem -LiteralPath $repoRoot -Recurse -File |
        Where-Object {
            $relative = $_.FullName.Substring($repoRoot.Length)
            $relative -notlike '*\.git\*' -and
            $relative -notlike '*\node_modules\*' -and
            $relative -notlike '*\build\*' -and
            $relative -notlike '*\.next\*' -and
            $relative -notlike '*\dist\*'
        }
).Count

$data = [ordered]@{
    generatedAt = [DateTimeOffset]::Now.ToString('yyyy-MM-ddTHH:mm:sszzz')
    repository = 'LegacySimulator'
    artifactCount = $artifactCount
    title = $manifest.title
    subtitle = $manifest.subtitle
    roadmap = $manifest.roadmap
    constraintRoadmap = $manifest.constraintRoadmap
    complexityRoadmap = $manifest.complexityRoadmap
    versions = $manifest.versions
    tests = $manifest.tests
}

$json = $data | ConvertTo-Json -Depth 12
Set-Content -LiteralPath $outputPath -Value $json -Encoding utf8
Write-Host "Demo evidence generated: $outputPath"
