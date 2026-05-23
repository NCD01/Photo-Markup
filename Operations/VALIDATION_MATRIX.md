# Validation Matrix

Document Path: `C:\apps\NCD_Photo_Markup\Operations\VALIDATION_MATRIX.md`
Version: `v0.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Track required validation activities and outcomes.
Changes: Recorded Phase 1B image import validation results.

## Validation Matrix
| ID | Validation | Command/Method | Trigger | Pass Criteria | Owner | Status | Evidence Path |
|---|---|---|---|---|---|---|---|
| `VAL-001` | Dependency Restore | `cd app && flutter pub get` | Dependencies change | Dependencies restore successfully | `NCD / M` | `PASS` | `Terminal output 2026-05-22` |
| `VAL-002` | Static Analysis | `cd app && flutter analyze` | Code/config changes | No blocking analysis/lint issues | `NCD / M` | `PASS` | `Terminal output 2026-05-22` |
| `VAL-003` | Automated Tests | `cd app && flutter test` | Behavior changes | Tests pass | `NCD / M` | `PASS` | `Terminal output 2026-05-22` |
| `VAL-004` | Build/Package | `cd app && flutter build windows --debug` | Build/runtime/dependency changes | Build succeeds | `NCD / M` | `PASS` | `app/build/windows/x64/runner/Debug/ncd_photo_markup.exe` |
| `VAL-005` | Runtime Startup Smoke Test | `cd app && flutter run -d windows --debug --no-resident` | Startup/routing/assets changes | App launches and reaches expected shell | `NCD / M` | `PASS` | `Terminal output 2026-05-22` |
| `VAL-006` | Runtime Log Review | `Review run/build terminal output` | Startup test is run | No blocking runtime errors found | `NCD / M` | `PASS` | `No blocking runtime errors shown` |
| `VAL-007` | Privacy/Redaction | `Manual review` | Data/log/screenshot changes | No sensitive data exposure in captured evidence | `NCD / M` | `PASS` | `phase1b_loaded_image.png uses generated sample image` |
| `VAL-008` | Docs/Changelog | `Manual review` | Any versioned change | Docs/changelog aligned | `NCD / M` | `PASS` | `Phase 1B docs updated` |
| `VAL-009` | Visual QA | `Runtime screenshot` | UI visible changes | Loaded image visible in canvas | `NCD / M` | `PASS` | `.agent_temp/screenshots/phase1b_loaded_image.png` |
| `VAL-010` | Responsive Layout | `Manual runtime observation` | Layout/resize changes | Content visible and usable | `NCD / M` | `PASS` | `Shell and image area render correctly` |
| `VAL-011` | Temporary Artifact Review | `Folder review (.agent_temp)` | Temp files created | Temp files in approved folder | `NCD / M` | `PASS` | `.agent_temp/screenshots + .agent_temp/scratch` |
| `VAL-012` | Manual Picker Cancel/Select Flow | Interactive: open app, cancel picker, reopen picker, select JPG/PNG | Image import flow changes | Cancel is graceful and selected image displays via picker | `NCD / M` | `NOT_VALIDATED` | `Automation blocked by OS SendKeys access denied; owner interactive pass required` |
| `VAL-013` | Android Runtime/Device Behavior | Android device/emulator runtime test | Platform behavior changes | App launches and imports image on Android | `NCD / M` | `NOT_VALIDATED` | `Not executed in this phase` |

