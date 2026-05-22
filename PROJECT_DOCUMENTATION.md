# Project Documentation

Document Path: `C:\apps\NCD_Photo_Markup\PROJECT_DOCUMENTATION.md`
Version: `v0.1`
Pack File Version: `v1.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Canonical project runtime, architecture, and behavior record.
Changes: Added Phase 1A Flutter shell architecture and validation scope.

## Quick Rules
- Keep architecture aligned to implementation.
- Keep shell UI touch-friendly and tool behavior placeholders-only until approved.

## Required Contract
Required sections are present and updated for Phase 1A.

## Overview
- App Name: `NCD Photo Markup`
- Purpose: `Touch-first field photo markup app with separate editable markup data and export outputs.`
- Primary Users: `Field operators, internal reviewers, client-facing report producers`
- Supported Platforms: `Windows tablet first; Android later`

## Runtime Architecture
| Subsystem | Responsibility | Source Path | Owner |
|---|---|---|---|
| UI | `Shell screen with app bar, canvas placeholder, and touch toolbar placeholders` | `app/lib/main.dart` | `NCD / M` |
| API | `Not implemented in Phase 1A` | `app/lib (planned)` | `NCD / M` |
| Engine | `Not implemented in Phase 1A` | `app/lib (planned)` | `NCD / M` |
| Data | `Not implemented in Phase 1A` | `app/lib (planned)` | `NCD / M` |

## Core Features
| Feature | Behavior | Primary Module | Test Evidence |
|---|---|---|---|
| `Phase 0 Bootstrap` | `Governance/docs baseline exists` | `Documentation` | `Manual doc review` |
| `Phase 1A App Shell` | `Renders top bar, empty canvas placeholder, bottom touch toolbar placeholders` | `app/lib/main.dart` | `flutter test` |
| `Open/Tool/Save/Export Buttons` | `Visible placeholders only; no markup behavior` | `app/lib/main.dart` | `Manual visual QA screenshot` |

## Data and Persistence Boundaries
- Canonical data source: `Not implemented in Phase 1A`
- Local cache policy: `Not implemented in Phase 1A`
- Migration policy: `Not implemented in Phase 1A`
- Backup/recovery policy: `Not implemented in Phase 1A`

## Logging and Error Controls
- Log schema: `Governance/LOGGING_AND_ERROR_POLICY.md`
- Error code domain(s): `Not implemented in Phase 1A`
- User-safe error behavior: `No stack traces surfaced in UI placeholders`

## Privacy and Sensitive Data Controls
- Data classification: `Internal`
- Redaction rules: `Screenshots and logs must avoid sensitive content`
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
| `flutter test` | `Widget tests` | `Tests pass` |
| `flutter build windows --debug` | `Windows debug build` | `Build succeeds` |
| `flutter run -d windows --debug --no-resident` | `Startup smoke test` | `App launches and syncs files` |

## Known Risks and Deferred Items
| ID | Risk/Item | Owner | Target Date | Notes |
|---|---|---|---|---|
| `RISK-001` | `No real markup behavior yet` | `NCD / M` | `Phase 1B+` | `Intentional` |
| `RISK-002` | `Android-specific polish deferred` | `NCD / M` | `Later phase` | `Intentional` |

## Visual and Runtime Behavior
- App bar shows `NCD Photo Markup` and `v0.1`.
- Main area is a large canvas placeholder with message: `Open or import a photo to start marking it up.`
- Bottom toolbar exposes placeholder buttons for the approved MVP tools/actions only.
