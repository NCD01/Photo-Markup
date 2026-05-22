# Validation Matrix

Document Path: `C:\apps\NCD_Photo_Markup\Operations\VALIDATION_MATRIX.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Track required validation activities and outcomes.
Changes: Recorded Phase 1A Flutter shell validation results.

## Validation Matrix
| ID | Validation | Command/Method | Trigger | Pass Criteria | Owner | Status | Evidence Path |
|---|---|---|---|---|---|---|---|
| `VAL-001` | Dependency Restore | `cd app && flutter pub get` | Dependencies change | Dependencies restore successfully | `NCD / M` | `PASS` | `Terminal output 2026-05-22` |
| `VAL-002` | Static Analysis | `cd app && flutter analyze` | Code/config changes | No blocking analysis/lint issues | `NCD / M` | `PASS` | `Terminal output 2026-05-22` |
| `VAL-003` | Automated Tests | `cd app && flutter test` | Behavior changes | Tests pass | `NCD / M` | `PASS` | `Terminal output 2026-05-22` |
| `VAL-004` | Build/Package | `cd app && flutter build windows --debug` | Build/runtime/dependency changes | Build succeeds | `NCD / M` | `PASS` | `app/build/windows/x64/runner/Debug/ncd_photo_markup.exe` |
| `VAL-005` | Runtime Startup Smoke Test | `cd app && flutter run -d windows --debug --no-resident` | Startup/routing/assets changes | App launches and reaches expected shell | `NCD / M` | `PASS` | `Terminal output 2026-05-22` |
| `VAL-006` | Runtime Log Review | `Review flutter run console output` | Startup test is run | No blocking runtime errors found | `NCD / M` | `PASS` | `No runtime errors shown in run/build logs` |
| `VAL-007` | Privacy/Redaction | `Manual review` | Data/log/screenshot changes | No sensitive data exposure | `NCD / M` | `PASS` | `Phase 1A screenshot contains shell only` |
| `VAL-008` | Docs/Changelog | `Manual review` | Any versioned change | Docs/changelog aligned | `NCD / M` | `PASS` | `Updated Phase 1A docs` |
| `VAL-009` | Visual QA | `Startup screenshot` | UI visible changes | Screenshot proves shell layout | `NCD / M` | `PASS` | `.agent_temp/screenshots/phase1a_shell_startup.png` |
| `VAL-010` | Responsive Layout | `Manual review during startup` | Layout/resize changes | Primary content visible and usable | `NCD / M` | `PASS` | `Shell renders with visible canvas and toolbar` |
| `VAL-011` | Temporary Artifact Review | `Folder review (.agent_temp)` | Temp files created | Temp files in approved folder | `NCD / M` | `PASS` | `.agent_temp/screenshots/phase1a_shell_startup.png` |
