# Project Documentation

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\PROJECT_DOCUMENTATION.md`
Version: `v0.5`
Pack File Version: `v1.7`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-23`
Purpose: Canonical project runtime, architecture, and behavior record.
Changes: Finalized Phase 1D MVP icon decision: keep current transparent v1.5-derived runtime icon and defer taskbar readability redesign.

## Quick Rules
- Keep architecture aligned to implementation.
- Keep non-approved toolbar actions as placeholders until approved.
- Structure/governance cleanup must not change runtime behavior.

## Required Contract
Required sections are present and updated through Phase 1D.

## Overview
- App Name: `NCD Photo Markup`
- Purpose: `Touch-first field photo markup app with separate editable markup data and export outputs.`
- Primary Users: `Field operators, internal reviewers, client-facing report producers`
- Supported Platforms: `Windows tablet first; Android later`

## Runtime Architecture
| Subsystem | Responsibility | Source Path | Owner |
|---|---|---|---|
| UI | `Shell screen, image import/open flow, canvas display, toolbar, and dimension overlay behavior` | `app/lib/main.dart` | `NCD / M` |
| UI Config | `Centralized tunable constants for app copy/layout/theme/import labels/extensions/markup line styling` | `app/lib/core/constants/app_constants.dart` | `NCD / M` |
| Markup Model | `Dimension line state entity and tool enum` | `app/lib/features/markup/models/` | `NCD / M` |
| Markup Widget | `Dimension lines overlay input capture and custom rendering` | `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `NCD / M` |
| Markup Utility | `Lightweight normalization for common measurement label formats` | `app/lib/features/markup/utils/dimension_label_formatter.dart` | `NCD / M` |
| API | `Not implemented` | `app/lib (planned)` | `NCD / M` |
| Engine | `Not implemented` | `app/lib (planned)` | `NCD / M` |
| Data | `No persistence yet; runtime-only selected file path` | `app/lib/main.dart` | `NCD / M` |

## Core Features
| Feature | Behavior | Primary Module | Test Evidence |
|---|---|---|---|
| `Open Photo` | `Opens Windows-compatible file picker and loads image into canvas` | `app/lib/main.dart` | `flutter analyze/test/build + runtime smoke` |
| `Canvas Image Display` | `Shows selected image centered with BoxFit.contain (no default cropping)` | `app/lib/main.dart` | `Loaded-image screenshot` |
| `Dimension Tool Selection` | `Dimension button toggles active drawing mode with visible selected state` | `app/lib/main.dart` | `Widget tests + runtime smoke` |
| `Dimension Line Draw` | `Drag on overlay creates persistent straight dimension lines above image, clamped to displayed photo bounds` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Widget test drag callbacks + runtime smoke` |
| `Dimension Label Entry` | `After line creation, opens manual label dialog with Save/Skip options` | `app/lib/main.dart` | `Runtime smoke + formatter tests` |
| `Dimension Label Render` | `Manual label appears near midpoint with readable background and bounds clamp` | `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Dimension Label Edit` | `Tap near an existing line to re-open label dialog for updates` | `app/lib/main.dart` | `Runtime smoke + code review` |
| `Undo Dimension` | `Undo removes most recently added dimension line` | `app/lib/main.dart` | `Widget tests` |
| `Cancel Handling` | `Picker cancel leaves state stable and no crash` | `app/lib/main.dart` | `Runtime automation attempt + no runtime errors` |
| `Other Toolbar Buttons` | `Remain placeholders with no markup behavior` | `app/lib/main.dart` | `Code review + widget/runtime observation` |
| `Branding Assets` | `Startup splash and app bar icon load from app-local branding assets` | `app/assets/branding/` + `app/lib/main.dart` + `app/pubspec.yaml` | `Runtime smoke + asset registration review` |
| `Windows App Icon` | `Executable/runner icon uses approved v1.5 branding source` | `app/windows/runner/resources/app_icon.ico` | `Windows build + resource replacement review` |

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
- `System/Documentation/APP_PROFILE.md`
- `Governance/MASTER_GUIDELINE.md`
- `Governance/AGENT_BASELINE.md`
- `Governance/CODE_FILE_STRUCTURE_POLICY.md`
- `Governance/Language_Addendums/DART_FLUTTER_ADDENDUM.md`
- `Operations/VALIDATION_MATRIX.md`
- `Operations/DECISION_LOG.md`
- `System/Documentation/CHANGELOG.md`

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
| `RISK-001` | `Only Dimension tool + manual labels exist; other tools still placeholders` | `NCD / M` | `Phase 1E+` | `Intentional` |
| `RISK-002` | `Android runtime behavior not validated` | `NCD / M` | `Later phase` | `Intentional` |
| `RISK-003` | `Manual picker cancel/select steps not fully automatable in this environment` | `Codex` | `Next interactive validation` | `OS SendKeys blocked` |
| `RISK-004` | `Interactive Windows manual drawing + label entry/edit validation still needed` | `NCD / M` | `Next owner interactive run` | `Automated tests cover logic but not full operator flow` |
| `RISK-005` | `Approved v1.5 icon is mini-logo style (small text/detail/padding), so taskbar-size readability is limited without a simplified icon standard` | `NCD / M` | `Future icon redesign phase` | `MVP accepts current transparent icon; redesign tracked in TODO-014` |

## Visual and Runtime Behavior
- App bar shows `NCD Photo Markup` and `v0.5`.
- Startup splash gate uses `splash_v1_5.png` for `2200 ms` before shell handoff.
- Windows app window now opens maximized to match startup-screen size.
- Windows app icon resource uses a transparent approved-design master derived from v1.5:
  - source concept: `System/Documentation/Images/NCD Photo Markup Icon v1.5.png`
  - transparent master: `System/Documentation/Images/NCD Photo Markup Icon v1.5-transparent-approved-design-master.png`
  - runtime icon asset: `app/assets/branding/icon_v1_5.png`
  - packaged icon: `app/windows/runner/resources/app_icon.ico`
- MVP icon decision:
  - transparency and packaging are accepted for Phase 1D.
  - taskbar readability/design optimization is deferred to a future icon standard/redesign phase.
  - splash asset/behavior remains unchanged.
- If no image loaded, canvas shows: `Open or import a photo to start marking it up.`
- Open Photo launches picker for `jpg`, `jpeg`, `png`, `webp`.
- Loaded photo is displayed in-canvas with preserved aspect ratio and contain fit.
- Dimension tool can be selected before photo load without crash.
- When a photo is loaded and Dimension is selected, pointer drag creates a straight line overlay with endpoint markers.
- Dimension drag start/end points are clamped to the actual displayed image rectangle (BoxFit.contain bounds).
- Overlay painter clips drawing to the displayed image rectangle to prevent render bleed into white canvas.
- After line creation, label dialog allows manual text input or skip.
- Pressing Enter/Done in the label input submits the same save path as tapping Save.
- Saved labels render near the line midpoint and remain in displayed-image bounds as much as practical.
- Tapping near an existing line re-opens the label dialog for editing.
- Label dialog controller lifecycle is dialog-local to prevent disposed-controller crashes during Save/Enter/Skip teardown.
- Quick-entry measurement normalization currently outputs inches:
  - `72` -> `72"`
  - `6 6` -> `78"`
  - `5 10` -> `70"`
- Non-measurement free text remains unchanged.
- Undo removes the most recently created dimension line.
- Loaded-photo indicator shows selected file name.
- Unsupported/unreadable image shows field-safe error message.

## Tunable Constants Standard (Governance v1.7)
- Tunable Flutter/Dart values are centralized in `app/lib/core/constants/app_constants.dart`.
- Grouped domains:
  - app metadata/version
  - theme/colors
  - image import (picker labels, supported extensions, open error text)
  - UI copy strings
  - tool labels
  - layout/spacing/sizing
  - dimension line styling and drag thresholds
  - dimension label dialog copy
  - dimension label style/placement thresholds
- Remaining repeated literals in `app/lib/main.dart` are intentional one-off framework/style usages and are tracked in validation notes.
- Splash duration remains tunable through `BrandingAssetConstants.startupSplashDurationMs`.
- Splash footprint remains tunable through:
  - `UiLayoutConstants.splashImageWidthFactor`
  - `UiLayoutConstants.splashImageHeightFactor`





## Roadmap (Near-Future)
- Future Phase: Apple Compatibility and HEIC/HEIF Support (see Operations/TODO_REGISTER.md).
- Future Phase: NCD Control Center Integration via isolated adapter/service boundaries (see Operations/TODO_REGISTER.md).

## Phase 1A.1 Structure Note
- This phase updates repository structure, governance scripts, and documentation references only.
- No app runtime or image import behavior changes are included in this phase.

