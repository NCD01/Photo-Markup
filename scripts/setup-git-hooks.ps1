param()

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Not a git repository: $repoRoot"
}

git config core.hooksPath "Governance/.githooks"
Write-Host "Configured core.hooksPath=Governance/.githooks"
