# Project Documentation

Document Path: `C:\apps\NCD_Photo_Markup\PROJECT_DOCUMENTATION.md`
Version: `v0.2`
Pack File Version: `v1.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Canonical project runtime, architecture, and behavior record.
Changes: Added Phase 1B image import behavior and validation notes.

## Quick Rules
- Keep architecture aligned to implementation.
- Keep non-Open toolbar actions as placeholders until approved.

## Required Contract
Required sections are present and updated through Phase 1B.

## Overview
- App Name: `NCD Photo Markup`
- Purpose: `Touch-first field photo markup app with separate editable markup data and export outputs.`
- Primary Users: `Field operators, internal reviewers, client-facing report producers`
- Supported Platforms: `Windows tablet first; Android later`

## Runtime Architecture
| Subsystem | Responsibility | Source Path | Owner |
|---|---|---|---|
| UI | `Shell screen, image import/open flow, canvas display, toolbar placeholders` | `app/lib/main.dart` | `NCD / M` |
| API | `Not implemented` | `app/lib (planned)` | `NCD / M` |
| Engine | `Not implemented` | `app/lib (planned)` | `NCD / M` |
| Data | `No persistence yet; runtime-only selected file path` | `app/lib/main.dart` | `NCD / M` |

## Core Features
| Feature | Behavior | Primary Module | Test Evidence |
|---|---|---|---|
| `Open Photo` | `Opens Windows-compatible file picker and loads image into canvas` | `app/lib/main.dart` | `flutter analyze/test/build + runtime smoke` |
| `Canvas Image Display` | `Shows selected image centered with BoxFit.contain (no default cropping)` | `app/lib/main.dart` | `Loaded-image screenshot` |
| `Cancel Handling` | `Picker cancel leaves state stable and no crash` | `app/lib/main.dart` | `Runtime automation attempt + no runtime errors` |
| `Other Toolbar Buttons` | `Remain placeholders with no markup behavior` | `app/lib/main.dart` | `Code review + runtime observation` |

## Data and Persistence Boundaries
- Canonical data source: `User-selected local image file path at runtime`
- Local cache policy: `None in Phase 1B`
- Migration policy: `N/A`
- Backup/recovery policy: `N/A`

## Logging and Error Controls
- Log schema: `Governance/LOGGING_AND_ERROR_POLICY.md`
- Error handling: `Shows field-safe load message for unsupported/unreadable images`
- User-safe error behavior: `Could not open this image. Please choose a JPG or PNG file.`

## Privacy and Sensitive Data Controls
- Data classification: `Internal`
- Redaction rules: `Screenshots/logs should avoid sensitive project photos`
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
| `flutter run -d windows --debug --no-resident` | `Startup smoke` | `App launches` |

## Known Risks and Deferred Items
| ID | Risk/Item | Owner | Target Date | Notes |
|---|---|---|---|---|
| `RISK-001` | `Markup tools not implemented yet` | `NCD / M` | `Phase 1C+` | `Intentional` |
| `RISK-002` | `Android runtime behavior not validated` | `NCD / M` | `Later phase` | `Intentional` |
| `RISK-003` | `Manual picker cancel/select steps not fully automatable in this environment` | `Codex` | `Next interactive validation` | `OS SendKeys blocked` |

## Visual and Runtime Behavior
- App bar shows `NCD Photo Markup` and `v0.2`.
- If no image loaded, canvas shows: `Open or import a photo to start marking it up.`
- Open Photo launches picker for `jpg`, `jpeg`, `png`, `webp`.
- Loaded photo is displayed in-canvas with preserved aspect ratio and contain fit.
- Loaded-photo indicator shows selected file name.
- Unsupported/unreadable image shows field-safe error message.
