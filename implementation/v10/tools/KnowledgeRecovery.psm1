Set-StrictMode -Version Latest

# V10-ADD-004: CSVの真偽値を同じ規則で解釈する。
function Convert-ToEvidenceBoolean {
    param([AllowNull()][string]$Value)
    return [string]::Equals($Value, 'true', [System.StringComparison]::OrdinalIgnoreCase)
}

# V10-ADD-005: 証拠種別ごとの重みと反証上限を一か所で管理する。
function Get-EvidenceAssessment {
    param([Parameter(Mandatory)]$Row)
    $evidence = [ordered]@{
        requirement = Convert-ToEvidenceBoolean $Row.requirement_evidence
        design = Convert-ToEvidenceBoolean $Row.design_evidence
        code = Convert-ToEvidenceBoolean $Row.code_evidence
        test = Convert-ToEvidenceBoolean $Row.test_evidence
    }
    $contradicted = Convert-ToEvidenceBoolean $Row.contradicted
    $score = 0.0
    if ($evidence.requirement) { $score += 0.2 }
    if ($evidence.design) { $score += 0.2 }
    if ($evidence.code) { $score += 0.3 }
    if ($evidence.test) { $score += 0.3 }
    if ($contradicted -and $score -gt 0.5) { $score = 0.5 }
    $score = [Math]::Round($score, 2)
    [pscustomobject]@{
        Confidence = $score
        Status = if ($contradicted -or $score -lt 0.8) { 'PENDING' } else { 'APPROVED_CANDIDATE' }
        Contradicted = $contradicted
        Evidence = $evidence
    }
}

# V10-ADD-006: 資産自体を証拠として識別できるようSHA-256を付与する。
function Get-ArtifactEvidence {
    param(
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][System.IO.FileInfo]$File
    )
    $relative = $File.FullName.Substring($RepositoryRoot.Length).TrimStart('\','/').Replace('\','/')
    $version = if ($relative -match '(?i)/(v\d{2})/') { $Matches[1].ToUpperInvariant() } else { 'SHARED' }
    $kind = if ($relative.StartsWith('specification/')) { 'specification' }
        elseif ($relative.StartsWith('implementation/')) { 'implementation' }
        elseif ($relative.StartsWith('test/')) { 'test' }
        else { 'supporting' }
    [ordered]@{
        path = $relative
        version = $version
        kind = $kind
        bytes = $File.Length
        sha256 = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

# V10-ADD-007: ゴールデン比較結果をレコード単位で保持する。
function Compare-GoldenRecords {
    param([string[]]$Expected, [string[]]$Actual)
    $maximum = [Math]::Max($Expected.Count, $Actual.Count)
    $differences = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $maximum; $index++) {
        $expectedValue = if ($index -lt $Expected.Count) { $Expected[$index] } else { $null }
        $actualValue = if ($index -lt $Actual.Count) { $Actual[$index] } else { $null }
        if ($expectedValue -cne $actualValue) {
            $differences.Add([ordered]@{ recordNumber=$index + 1; expected=$expectedValue; actual=$actualValue })
        }
    }
    return $differences
}

Export-ModuleMember -Function Convert-ToEvidenceBoolean,Get-EvidenceAssessment,Get-ArtifactEvidence,Compare-GoldenRecords

