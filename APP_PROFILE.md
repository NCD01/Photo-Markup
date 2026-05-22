# App Profile

Document Path: `C:\apps\NCD_Photo_Markup\APP_PROFILE.md`
Version: `v0.1`
Pack File Version: `v1.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Store project-specific facts for NCD Photo Markup governance and validation.
Changes: Updated for Phase 1A Flutter shell in app/ and validated command paths.

## Quick Rules
- Keep this file current as source of truth for commands, paths, and validation.
- Do not use Control Center versioning.
- Use two-part versions only: `v0.x`.

## Required Contract
| Field | Value |
|---|---|
| App Name | `NCD Photo Markup` |
| App Purpose | `Touch-first field photo markup app for internal/client annotation workflows with separate editable markup data and exported outputs.` |
| Product Owner | `NCD / M` |
| Technical Owner | `NCD / M` |
| Primary Repo | `C:\apps\NCD_Photo_Markup` |
| Primary Branch | `master` |
| Primary Workspace Path | `C:\apps\NCD_Photo_Markup` |
| Target Platforms | `Windows tablet first; Android (Samsung tablet) later` |
| Main Stack | `Flutter` |
| Package Manager | `pub` |
| Data Classification | `Internal` |
| Production Data Allowed Locally | `Restricted` |
| Release Owner | `NCD / M` |
| Temporary Work Root | `C:\apps\NCD_Photo_Markup\.agent_temp` |
| Screenshots Temp Folder | `C:\apps\NCD_Photo_Markup\.agent_temp\screenshots` |
| Diagnostics Temp Folder | `C:\apps\NCD_Photo_Markup\.agent_temp\diagnostics` |
| Source Control Ignore Rule | `Yes (.agent_temp/ ignored)` |
| Minimum Window Size | `1024x768` |
| Desktop Focus Requirement | `YES` |

## Required Commands
| Purpose | Command | Expected Result |
|---|---|---|
| Dependency install | `cd app && flutter pub get` | `Dependencies restored` |
| Static analysis/lint | `cd app && flutter analyze` | `No blocking issues` |
| Unit tests | `cd app && flutter test` | `Tests pass` |
| Integration tests | `Not configured yet` | `NOT_RUN` |
| Build/package | `cd app && flutter build windows --debug` | `Debug Windows build succeeds` |
| Runtime startup smoke test | `cd app && flutter run -d windows --debug --no-resident` | `App launches and syncs files to Windows` |
| Runtime log review | `Review flutter run/build terminal output` | `No blocking runtime errors found` |
| Visual QA capture | `Capture screenshots to .agent_temp/screenshots` | `Evidence captured for UI changes` |
| Responsive layout validation | `Manual resize/maximized checks` | `Controls visible and usable` |
| Link/placeholders check | `rg "<[A-Z0-9_\\-/| ]+>" APP_PROFILE.md PROJECT_DOCUMENTATION.md README.md CHANGELOG.md MASTER_GUIDELINE.md AGENT_BASELINE.md Operations\*.md UI_STANDARDS.md FORM_DEFINITIONS.md` | `No unresolved placeholders` |

## Runtime Startup Smoke Test
### Required Startup Proof
| Item | Value |
|---|---|
| Launch command or method | `cd app && flutter run -d windows --debug --no-resident` |
| Target platform/device | `Windows touchscreen tablet (primary)` |
| Expected first screen/scene/route | `Main markup workspace shell` |
| Expected startup log message | `None required` |
| Required startup assets/files | `Flutter shell assets from app/` |
| Required startup services | `None in Phase 1A` |
| Log source to review | `Flutter run console logs` |
| Blocking error patterns | `Unhandled Exception; EXCEPTION CAUGHT; missing asset; missing file; failed assertion; startup crash` |
| Screenshot/log evidence required | `Yes` |

### Green-Light Requirement
Runtime startup validation is mandatory once runtime code exists and when startup-affecting areas change.

## Visual QA Requirements
| Item | Value |
|---|---|
| Visual QA required for UI/layout/gameplay changes | `YES` |
| Screenshot folder | `C:\apps\NCD_Photo_Markup\.agent_temp\screenshots` |
| Debug overlay available | `N/A (to be defined with app tooling)` |
| Debug overlay screenshot required when | `Canvas placement/alignment checks are introduced` |
| Normal player-view screenshot required when | `Any user-visible UI change` |
| Owner screenshot approval required before commit | `WHEN_REQUESTED` |

## Responsive Layout Validation
Expected scaling strategy:
- `RESPONSIVE_REFLOW`

## Desktop Window Requirements
- App must support resize and touch-friendly controls.
- Required content must remain visible at documented minimum size.

## Temporary Artifact Folders
| Temp Artifact Type | Required Folder |
|---|---|
| Scratch root | `C:\apps\NCD_Photo_Markup\.agent_temp` |
| Screenshots | `C:\apps\NCD_Photo_Markup\.agent_temp\screenshots` |
| Diagnostics/log copies | `C:\apps\NCD_Photo_Markup\.agent_temp\diagnostics` |
| Scratch/generated files | `C:\apps\NCD_Photo_Markup\.agent_temp\scratch` |

Source control rule:
- `C:\apps\NCD_Photo_Markup\.agent_temp\` is ignored by default.

## Environment Map
| Environment | URL/Path | Data Used | Owner | Notes |
|---|---|---|---|---|
| Local | `C:\apps\NCD_Photo_Markup` | `Internal` | `NCD / M` | `Primary development environment` |
| Test | `N/A` | `N/A` | `NCD / M` | `Not defined yet` |
| Production | `N/A` | `N/A` | `NCD / M` | `Not defined yet` |

## Documentation Map
| Document | Canonical Path | Notes |
|---|---|---|
| Master Guideline | `C:\apps\NCD_Photo_Markup\MASTER_GUIDELINE.md` | `Primary governance entry` |
| Changelog | `C:\apps\NCD_Photo_Markup\CHANGELOG.md` | `Project version history` |
| Decision Log | `C:\apps\NCD_Photo_Markup\Operations\DECISION_LOG.md` | `Architecture/policy decisions` |
| Validation Matrix | `C:\apps\NCD_Photo_Markup\Operations\VALIDATION_MATRIX.md` | `Validation tracking` |
| Runtime Startup Smoke Test | `C:\apps\NCD_Photo_Markup\Operations\RUNTIME_STARTUP_SMOKE_TEST.md` | `Startup evidence` |
| Release Checklist | `C:\apps\NCD_Photo_Markup\Operations\CHECKLIST_RELEASE_READINESS.md` | `Release gate checklist` |

## Agent Output Preferences
- Concise summaries required: `YES`
- Raw log/file dumps allowed by default: `NO`
- If evidence is missing, agent should: `STATE_UNKNOWN`
- Assumptions allowed without labeling: `NO`
- Governance may be bypassed for speed: `NO`
- Required closeout style: `BRIEF_STATUS_WITH_EVIDENCE`

Project-specific communication notes:
- `Keep status concise and evidence-based.`
- `No commits/pushes without explicit approval from M.`

## Verification Gate
- [x] App ownership and paths are complete.
- [x] Commands are real and current.
- [x] Runtime startup smoke test is defined.
- [x] Visual QA requirements are defined.
- [x] Responsive layout validation requirements are defined.
- [x] Desktop window requirements are defined.
- [x] Temporary artifact folders are defined and ignored by source control.
- [x] Blocking runtime error patterns are defined.
- [x] Data classification is set.
- [x] Environment map is complete.
- [x] Documentation map points to real files.

## v1.5 Coordination and Documentation Sources
| Field | Value |
|---|---|
| Master Coordination Source | `C:\apps\NCD_Photo_Markup\Operations\CODER_COORDINATION.md` |
| Active Workstreams | `Single-coder bootstrap (expand when multiple coders are active)` |
| UI Standards Document | `C:\apps\NCD_Photo_Markup\UI_STANDARDS.md` |
| UI Standards Selection Form | `C:\apps\NCD_Photo_Markup\Templates\UI_Module\UI_STANDARDS_SELECTION_FORM_TEMPLATE.md` |
| Form Definitions Document | `C:\apps\NCD_Photo_Markup\FORM_DEFINITIONS.md` |
| TODO Register | `C:\apps\NCD_Photo_Markup\Operations\TODO_REGISTER.md` |
| Live Data Commit Rule | `No live data yet; define before data files are introduced` |
| Runtime/UI State Files | `To be defined once runtime/state files exist` |
| Required Data Backup Scope | `To be defined before data/config commits` |

