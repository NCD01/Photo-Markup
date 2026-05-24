param(
    [ValidateSet("major", "minor")]
    [string]$Bump = "minor",

    [ValidateSet("Feature", "Fix", "Refactor", "Documentation", "Logging", "Structural")]
    [string]$Type = "Documentation",

    [string]$Owner = "Documentation Maintainers",
    [string]$Author = $env:GITHUB_ACTOR,
    [string]$Reason = "Automated version bump.",
    [string[]]$Changes = @("Updated release version."),
    [string[]]$ValidationEvidence = @("Automated version bump script: PASS"),
    [string[]]$RollbackNotes = @("Revert the version bump commit and delete the matching tag."),
    [string]$Date = (Get-Date -Format "yyyy-MM-dd")
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$versionPath = Join-Path $repoRoot "VERSION"
$appConstantsPath = Join-Path $repoRoot "app\\lib\\core\\constants\\app_constants.dart"
$changelogPath = Join-Path $repoRoot "System\\Documentation\\CHANGELOG.md"
$releaseNotesPath = Join-Path $repoRoot "System\\Documentation\\RELEASE_NOTES.md"

if (-not (Test-Path $versionPath)) {
    throw "VERSION file is missing."
}

$currentVersion = (Get-Content -Raw $versionPath).Trim()
if ($currentVersion -notmatch "^v(?<major>\d+)\.(?<minor>\d+)$") {
    throw "Version '$currentVersion' does not match required format vX.Y."
}

$major = [int]$Matches.major
$minor = [int]$Matches.minor

if ($Bump -eq "major") {
    $major += 1
    $minor = 0
} else {
    $minor += 1
}

$newVersion = "v$major.$minor"
Set-Content -Path $versionPath -Value "$newVersion`n" -NoNewline

if (-not (Test-Path $appConstantsPath)) {
    throw "App constants file is missing: $appConstantsPath"
}

$appConstantsRaw = Get-Content -Raw $appConstantsPath
$updatedAppConstants = [regex]::Replace(
    $appConstantsRaw,
    "static const String appVersion = 'v\d+\.\d+';",
    "static const String appVersion = '$newVersion';",
    1
)

if ($updatedAppConstants -eq $appConstantsRaw) {
    throw "Could not update AppConstants.appVersion in $appConstantsPath"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($appConstantsPath, $updatedAppConstants, $utf8NoBom)

if (-not $Author) {
    $Author = $env:USERNAME
}
if (-not $Author) {
    $Author = "Unknown"
}

function Convert-ToBulletList {
    param([string[]]$Items)
    return (($Items | ForEach-Object { "  - $_" }) -join "`n")
}

$changeBlock = @"

## $newVersion - $Date
- Owner: $Owner
- Author: $Author
- Type: $Type
- Reason: $Reason
- Changes:
$(Convert-ToBulletList $Changes)
- Validation Evidence:
$(Convert-ToBulletList $ValidationEvidence)
- Rollback Notes:
$(Convert-ToBulletList $RollbackNotes)
"@

$releaseBlock = @"

## $newVersion - $Date

Linked changelog entries:
- `$newVersion - $Date`

Scope:
$(Convert-ToBulletList $Changes)

Validation:
$(Convert-ToBulletList $ValidationEvidence)

Rollback:
$(Convert-ToBulletList $RollbackNotes)

Migration Notes:
- Add migration notes here before release if this is a breaking change.
"@

Add-Content -Path $changelogPath -Value $changeBlock
Add-Content -Path $releaseNotesPath -Value $releaseBlock

Write-Output $newVersion
