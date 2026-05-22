# Project Documentation

Document Path: `C:\apps\NCD_Photo_Markup\PROJECT_DOCUMENTATION.md`
Version: `v0.1`
Pack File Version: `v1.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Canonical project runtime, architecture, and behavior record.
Changes: Created initial architecture and deferred-item baseline for pre-code phase.

## Quick Rules
- Keep architecture sections aligned with real implementation.
- Update this file when subsystem responsibilities or behavior contracts change.

## Required Contract
Required sections are present and initialized for Phase 0.

## Overview
- App Name: `NCD Photo Markup`
- Purpose: `Touch-first field photo markup app with separate editable markup data and export outputs.`
- Primary Users: `Field operators, internal reviewers, client-facing report producers`
- Supported Platforms: `Windows tablet first; Android (Samsung tablet) later`

## Runtime Architecture
| Subsystem | Responsibility | Source Path | Owner |
|---|---|---|---|
| UI | `Touch-first markup workflow and controls` | `lib/ui (planned)` | `NCD / M` |
| API | `Future integration adapters (none in Phase 0)` | `lib/integration (planned)` | `NCD / M` |
| Engine | `Markup model, tool behavior, undo/redo, export pipeline` | `lib/engine (planned)` | `NCD / M` |
| Data | `Editable markup persistence separate from original image and exports` | `lib/data (planned)` | `NCD / M` |

## Core Features
| Feature | Behavior | Primary Module | Test Evidence |
|---|---|---|---|
| `Phase 0 Bootstrap` | `Governance/docs baseline exists before feature code` | `Documentation` | `Manual doc review` |
| `Dimension Line Tool (MVP)` | `Deferred` | `Planned` | `Not validated` |
| `Arrow Tool (MVP)` | `Deferred` | `Planned` | `Not validated` |

## Data and Persistence Boundaries
- Canonical data source: `App-local project files (future definition)`
- Local cache policy: `To be defined during implementation`
- Migration policy: `To be defined before schema versioning`
- Backup/recovery policy: `Editable markup and exports treated as separate artifacts`

## Logging and Error Controls
- Log schema: `Governance/LOGGING_AND_ERROR_POLICY.md`
- Error code domain(s): `To be defined with runtime code`
- User-safe error behavior: `No raw stack traces in user-facing messages`

## Privacy and Sensitive Data Controls
- Data classification: `Internal`
- Redaction rules: `No sensitive data in screenshots/logs unless approved`
- Production data local-use policy: `Restricted`

## Governance and Release Artifacts
- `APP_PROFILE.md`
- `MASTER_GUIDELINE.md`
- `AGENT_BASELINE.md`
- `Operations/VALIDATION_MATRIX.md`
- `Operations/DECISION_LOG.md`
- `CHANGELOG.md`

## Verification Commands
| Command | Purpose | Expected Result |
|---|---|---|
| `flutter pub get` | `Dependency install` | `Dependencies restored` |
| `flutter analyze` | `Static analysis` | `No blocking issues` |
| `flutter test` | `Unit tests` | `Tests pass` |
| `flutter build windows --debug` | `Windows debug build` | `Build succeeds` |

## Known Risks and Deferred Items
| ID | Risk/Item | Owner | Target Date | Notes |
|---|---|---|---|---|
| `RISK-001` | `No runtime code exists yet; validation limited to doc/bootstrap` | `NCD / M` | `N/A` | `Expected for Phase 0` |
| `RISK-002` | `Android support deferred until after Windows-first baseline` | `NCD / M` | `N/A` | `Intentional sequencing` |

## Visual and Runtime Behavior
Phase 0 only: no app runtime/UI implementation exists yet. Visual/runtime behavior definitions will be expanded in Phase 1.
