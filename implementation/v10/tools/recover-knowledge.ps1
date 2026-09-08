[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InputPath,
    [Parameter(Mandatory)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'KnowledgeRecovery.psm1') -Force

# V10-ADD-003: 複数証拠を独立に採点し、内訳を保持する。
$edges = foreach ($row in (Import-Csv -LiteralPath $InputPath)) {
    $assessment = Get-EvidenceAssessment -Row $row
    [ordered]@{
        edgeId = $row.edge_id
        fromArtifact = $row.from_artifact
        toArtifact = $row.to_artifact
        version = $row.version
        confidence = $assessment.Confidence
        status = $assessment.Status
        contradicted = $assessment.Contradicted
        evidence = $assessment.Evidence
    }
}

$result = [ordered]@{
    schemaVersion = 1
    generatedBy = 'V10 knowledge recovery reference implementation'
    edges = @($edges)
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
$result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Host "V10 knowledge edges generated: $(@($edges).Count) -> $OutputPath"
