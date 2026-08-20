# Scripts

Document Path: `C:\apps\NCD_Photo_Markup\scripts\README.md`
Version: `v0.4`
Owner: `NCD / M`
Last Updated By: `Claude`
Last Updated: `2026-08-20`
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

## Passing multi-item lists

`-Changes`, `-ValidationEvidence` and `-RollbackNotes` are string arrays. Run
with `-File` and comma-separated text and PowerShell hands the whole thing over
as one string, so the changelog gets a single run-on bullet. Use `-Command` and
a real array instead:

```
powershell -ExecutionPolicy Bypass -Command "& ./scripts/bump-version.ps1 -Bump minor -Type Feature -Reason 'Why' -Changes 'First change','Second change'"
```

Read the appended block in `System/Documentation/CHANGELOG.md` afterwards and
confirm it came out as separate bullets.
