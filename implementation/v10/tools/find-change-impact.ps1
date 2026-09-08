[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RepositoryRoot,
    [Parameter(Mandatory)][string]$SearchText,
    [Parameter(Mandatory)][string]$OutputPath
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$extensions = @('.md','.yml','.yaml','.cbl','.cpy','.jcl','.java','.ps1','.sql','.xml','.csv')
$matches = [System.Collections.Generic.List[object]]::new()

# V10-ADD-010: 要件ID・変更番号・項目名を全世代横断で検索し、候補エッジを作る。
foreach ($file in (Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object Extension -in $extensions)) {
    $lineNumber = 0
    foreach ($line in (Get-Content -LiteralPath $file.FullName)) {
        $lineNumber++
        if ($line.IndexOf($SearchText, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $matches.Add([ordered]@{
                path=$file.FullName.Substring($root.Length).TrimStart('\','/').Replace('\','/')
                line=$lineNumber
                text=$line.Trim()
                confidence='candidate'
            })
        }
    }
}
$result = [ordered]@{ schemaVersion=1; query=$SearchText; matchCount=$matches.Count; matches=$matches }
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
$result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Host "V10 impact candidates generated: $($matches.Count) -> $OutputPath"

