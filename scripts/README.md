# Scripts

Document Path: `C:\apps\NCD_Photo_Markup\scripts\README.md`
Version: `v0.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-24`
Purpose: Governance support scripts for hooks and version bump workflow.

## Files
- `setup-git-hooks.ps1`: sets `core.hooksPath` to `Governance/.githooks`.
- `bump-version.ps1`: performs governed `VERSION` bump, updates `AppConstants.appVersion`, and appends release docs in `System/Documentation/`.
- `verify-version-sync.ps1`: verifies `VERSION` exactly matches `AppConstants.appVersion`.

## Required Usage
- Hook setup:
  - `powershell -ExecutionPolicy Bypass -File scripts/setup-git-hooks.ps1`
- Version bump before approved push:
  - `powershell -ExecutionPolicy Bypass -File scripts/bump-version.ps1 -Bump minor -Reason "<reason>"`
- Version sync guard (run during validation):
  - `powershell -ExecutionPolicy Bypass -File scripts/verify-version-sync.ps1`
