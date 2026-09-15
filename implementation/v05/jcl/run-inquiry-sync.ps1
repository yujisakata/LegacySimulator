[CmdletBinding()]
param(
 [Parameter(Mandatory)][string]$V4InputDirectory,
 [Parameter(Mandatory)][string]$SnapshotDirectory,
 [Parameter(Mandatory)][string]$AsOf,
 [Parameter(Mandatory)][string]$BusinessDate
)
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
& (Join-Path $repoRoot 'test\v05\scripts\build-v05.ps1')
$inputPath=(Resolve-Path -LiteralPath $V4InputDirectory).Path
$classpath=(Join-Path $repoRoot 'build\v05\classes')+';'+(Join-Path $repoRoot 'build\v05\deps\*')
$files=@('APPLICATION.DAT','ASSESSMENT.DAT','MEDICAL.DAT','MEDASSESS.DAT') | ForEach-Object { Join-Path $inputPath $_ }
& java -cp $classpath com.legacysimulator.v05.SnapshotExportJob $files $AsOf $SnapshotDirectory
if($LASTEXITCODE -ne 0) { throw 'V5 snapshot export failed; publication skipped' }
& java -cp $classpath com.legacysimulator.v05.SnapshotImportJob $SnapshotDirectory $BusinessDate
if($LASTEXITCODE -ne 0) { throw 'V5 snapshot import failed; review the job log' }
Write-Output 'V5 snapshot job completed'
