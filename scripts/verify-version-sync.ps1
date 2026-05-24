param()

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$versionPath = Join-Path $repoRoot "VERSION"
$appConstantsPath = Join-Path $repoRoot "app\\lib\\core\\constants\\app_constants.dart"

if (-not (Test-Path $versionPath)) {
    throw "VERSION file is missing."
}

if (-not (Test-Path $appConstantsPath)) {
    throw "App constants file is missing: $appConstantsPath"
}

$versionValue = (Get-Content -Raw $versionPath).Trim()
if ($versionValue -notmatch "^v\d+\.\d+$") {
    throw "VERSION value '$versionValue' is not in vX.Y format."
}

$appConstantsRaw = Get-Content -Raw $appConstantsPath
$match = [regex]::Match(
    $appConstantsRaw,
    "static const String appVersion = '(v\d+\.\d+)';"
)

if (-not $match.Success) {
    throw "Could not parse AppConstants.appVersion in $appConstantsPath"
}

$appVersionValue = $match.Groups[1].Value
if ($appVersionValue -ne $versionValue) {
    throw "Version drift detected. VERSION='$versionValue' but AppConstants.appVersion='$appVersionValue'."
}

Write-Output "PASS: VERSION and AppConstants.appVersion are in sync at $versionValue."
