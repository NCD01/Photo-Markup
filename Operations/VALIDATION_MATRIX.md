# Validation Matrix

Document Path: `C:\apps\NCD_Photo_Markup\Operations\VALIDATION_MATRIX.md`
Version: `v0.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Track required validation activities and outcomes.
Changes: Added governance v1.7 tunable-constants adoption checks and centralized-constants verification gate evidence.

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
| `VAL-014` | Governance Source Sync | `cd C:\Games\Governance && git pull origin main` | Governance update requested | Governance source updates cleanly | `NCD / M` | `PASS` | `Already up to date on main (bdd94db)` |
| `VAL-015` | Hook Setup | `powershell -ExecutionPolicy Bypass -File scripts/setup-git-hooks.ps1` | Governance hook updates | `core.hooksPath` points to required hook directory | `NCD / M` | `PASS` | `Configured core.hooksPath=Governance/.githooks` |
| `VAL-016` | Root Lean Structure | `Get-ChildItem -Force` + expected/forbidden path checks | Structure cleanup updates | Root contains only approved folders/files | `NCD / M` | `PASS` | `Root: app/Governance/Operations/System/Templates/scripts/.agent_temp + .gitignore/README.md/VERSION` |
| `VAL-017` | File Move Existence | `Test-Path` checks for moved docs/templates | Lean-root doc moves | All required moved files exist at target paths | `NCD / M` | `PASS` | `All required targets found` |
| `VAL-018` | Link/Path Reference Check | `rg` path scan across root/governance/system/operations/templates | Path moves or governance sync | References align with moved locations | `NCD / M` | `PASS` | `Stale references corrected (pack/checklist/template row)` |
| `VAL-019` | Placeholder Scan (Project Docs) | `rg` placeholder scan on project docs | Doc updates | No unresolved project placeholders remain | `NCD / M` | `PASS` | `Only instructional `<VERSION>` mention remains in manifest body text` |
| `VAL-020` | Temp Ignore Rule | `git check-ignore -v .agent_temp ...` | Temp artifact usage | `.agent_temp` paths ignored | `NCD / M` | `PASS` | `.gitignore:1 .agent_temp/` |
| `VAL-021` | Static Analysis (Recheck) | `cd app && flutter analyze` | Structure/governance updates near app repo | No blocking analysis issues | `NCD / M` | `PASS` | `No issues found (2026-05-22)` |
| `VAL-022` | Automated Tests (Recheck) | `cd app && flutter test` | Structure/governance updates near app repo | Tests pass | `NCD / M` | `PASS` | `All tests passed (2026-05-22)` |
| `VAL-023` | Windows Build (Recheck) | `cd app && flutter build windows --debug` | Structure/governance updates near app repo | Build succeeds | `NCD / M` | `PASS` | `Built build/windows/x64/runner/Debug/ncd_photo_markup.exe (2026-05-22)` |
| `VAL-024` | Startup Smoke (Recheck) | `cd app && flutter run -d windows --debug --no-resident` | Structure/governance updates near app repo | App launches without blocking startup errors | `NCD / M` | `PASS` | `Launch + sync succeeded (2026-05-22)` |
| `VAL-025` | Tunable Constants Centralization | `Manual code review + rg scans for tunable literals in app/lib/main.dart` | Governance/code-structure updates | Tunable values are centralized and editable without hunting through logic | `NCD / M` | `PASS` | `app/lib/core/constants/app_constants.dart + main.dart references` |
| `VAL-026` | Flutter Tunable Constants Gate | `Manual review against Governance/CODE_FILE_STRUCTURE_POLICY.md and Governance/Language_Addendums/DART_FLUTTER_ADDENDUM.md` | Flutter UI code touched | Tunable Flutter/Dart values are centralized in constants/config blocks | `NCD / M` | `PASS` | `Governance policies synced + constants grouped by domain` |
| `VAL-027` | Remaining Repeated Literals Review | `Manual review of app/lib/main.dart` | Tunable extraction pass complete | Remaining repeats are intentional one-off/deferred and documented | `NCD / M` | `PASS` | `Intentional inline Flutter style/framework one-offs documented in PROJECT_DOCUMENTATION` |
| `VAL-028` | Governance Source Version Alignment | `Manual check of C:\Games\Governance\VERSION and owner-requested baseline` | Governance sync update requested | Source version and requested baseline are reconciled or tracked | `NCD / M` | `NOT_VALIDATED` | `Source VERSION is v1.8 while request said effective v1.7; tracked in TODO-008` |


