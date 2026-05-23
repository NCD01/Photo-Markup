# NCD Photo Markup

Document Path: `C:\apps\NCD_Photo_Markup\README.md`
Version: `v0.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Lean root repo map and quick start for the standalone Flutter app.
Changes: Added governance tunable-constants references and scripts/version governance map.

## Repo Map
- `app/`: Flutter runtime app (Windows-first currently).
- `System/Documentation/`: project-level working docs.
- `Governance/`: governance and policy documents.
- `Operations/`: operational logs, validation, and checklist docs.
- `Templates/`: reusable documentation templates.
- `scripts/`: governance hook/version scripts.
- `.agent_temp/`: ignored temporary artifacts.
- `VERSION`: repo version file for push-hook/version governance.

## Key Documents
- `System/Documentation/APP_PROFILE.md`
- `System/Documentation/PROJECT_DOCUMENTATION.md`
- `System/Documentation/CHANGELOG.md`
- `System/Documentation/UI_STANDARDS.md`
- `System/Documentation/UI_STANDARDS_SELECTION_FORM.md`
- `Governance/MASTER_GUIDELINE.md`
- `Governance/AGENT_BASELINE.md`
- `Governance/CODE_FILE_STRUCTURE_POLICY.md`
- `Governance/Language_Addendums/DART_FLUTTER_ADDENDUM.md`
- `Governance/Examples/CONSTANT_BLOCKS_EXAMPLE.md`
- `Operations/VALIDATION_MATRIX.md`
- `Operations/TODO_REGISTER.md`

## Run and Validate
From `C:\apps\NCD_Photo_Markup\app`:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build windows --debug`
- `flutter run -d windows --debug --no-resident`

## Governance Commands
- `powershell -ExecutionPolicy Bypass -File scripts/setup-git-hooks.ps1`
- `powershell -ExecutionPolicy Bypass -File scripts/bump-version.ps1 -Bump minor -Reason "<reason>"`

## Version Rules
- Current version: `v0.3`
- Use two-part versions only (`v0.1`, `v0.2`, `v0.3`, `v0.4`, ...)
- Do not bump version before owner validation/approval.
