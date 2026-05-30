# Project Documentation

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\PROJECT_DOCUMENTATION.md`
Version: `v0.5`
Pack File Version: `v1.7`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-29`
Purpose: Canonical project runtime, architecture, and behavior record.
Changes: Added Phase 1U compact sidebar rail/drawer field-usability architecture/behavior notes.

## Quick Rules
- Keep architecture aligned to implementation.
- Keep non-approved toolbar actions as placeholders until approved.
- Structure/governance cleanup must not change runtime behavior.

## Required Contract
Required sections are present and updated through Phase 1O.

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
| Markup Model | `Dimension line + arrow + rectangle + oval + freehand + text note entities and tool enum` | `app/lib/features/markup/models/` | `NCD / M` |
| Style Model | `Markup style preset definitions and preset-id based style registry` | `app/lib/features/markup/models/markup_style_preset.dart` | `NCD / M` |
| Markup Widget | `Dimension lines overlay input capture, selection hit-testing, and custom rendering` | `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `NCD / M` |
| Markup Utility | `Lightweight normalization for common measurement label formats` | `app/lib/features/markup/utils/dimension_label_formatter.dart` | `NCD / M` |
| Move Utility | `Whole-markup move translation/clamp helpers used by drag-selected move workflow` | `app/lib/features/markup/utils/markup_move_utils.dart` | `NCD / M` |
| Handle Utility | `Endpoint/corner handle hit-testing and resize math helpers` | `app/lib/features/markup/utils/markup_handle_utils.dart` | `NCD / M` |
| Unsaved State Utility | `Tracks markup dirty/saved state for guard prompts before replace/close actions` | `app/lib/features/markup/utils/unsaved_changes_tracker.dart` | `NCD / M` |
| Editable Markup Model | `Typed sidecar schema model for persisted editable markup sessions` | `app/lib/features/markup/models/editable_markup_document.dart` | `NCD / M` |
| Editable Markup Service | `Builds safe sidecar paths and reads/writes .ncdmarkup.json documents` | `app/lib/features/markup/services/editable_markup_document_service.dart` | `NCD / M` |
| Import Service | `Converts HEIC/HEIF source files into preview-capped temporary working copies (cache-reused JPEG in current policy), applies fallback conversion, and cleans stale cache artifacts` | `app/lib/features/import/services/image_import_service.dart` | `NCD / M` |
| View Transform Utility | `Provides centralized zoom clamp/step/wheel transform helpers for canvas view controls` | `app/lib/features/view/utils/canvas_view_transform_utils.dart` | `NCD / M` |
| Export Service | `Capture visible marked canvas and write PNG to user-selected location` | `app/lib/features/export/services/marked_up_image_export_service.dart` | `NCD / M` |
| Export Path Service | `Builds default export name/folder and duplicate-safe output path` | `app/lib/features/export/services/markup_export_path_service.dart` | `NCD / M` |
| Launch Context Adapter | `Parses optional launch context args/file for client/project/source image bootstrap while preserving standalone fallback` | `app/lib/features/integration/models/ + app/lib/features/integration/services/launch_context_service.dart` | `NCD / M` |
| API | `Not implemented` | `app/lib (planned)` | `NCD / M` |
| Engine | `Not implemented` | `app/lib (planned)` | `NCD / M` |
| Data | `No persistence yet; runtime-only selected file path` | `app/lib/main.dart` | `NCD / M` |

## Core Features
| Feature | Behavior | Primary Module | Test Evidence |
|---|---|---|---|
| `Open Photo` | `Opens Windows-compatible file picker and loads JPG/JPEG/PNG/WEBP/HEIC/HEIF into canvas` | `app/lib/main.dart` + `app/lib/features/import/services/image_import_service.dart` | `flutter analyze/test/build + runtime smoke` |
| `HEIC/HEIF Conversion` | `Converts HEIC/HEIF to preview-capped temporary working copy (current policy: JPEG cache), preserves original file, and retains fallback conversion safety` | `app/lib/features/import/services/image_import_service.dart` | `Service tests + runtime smoke` |
| `Import Progress Feedback` | `Shows user-friendly progress copy while photo import/conversion is in progress` | `app/lib/main.dart` | `Runtime smoke + widget/runtime observation` |
| `Canvas Image Display` | `Shows selected image centered with BoxFit.contain (no default cropping)` | `app/lib/main.dart` | `Loaded-image screenshot` |
| `Canvas Zoom Controls` | `In-canvas controls support zoom in/out with configured min/max clamping and zoom-percent status` | `app/lib/main.dart` + `app/lib/features/view/utils/canvas_view_transform_utils.dart` | `Utility tests + runtime smoke` |
| `Canvas Pan Controls` | `Pan mode toggle enables drag-panning and wheel scroll panning while preserving markup model coordinates` | `app/lib/main.dart` | `Runtime smoke + code review` |
| `Canvas Fit/Actual Controls` | `Fit and 100% actions reset or normalize canvas transform without mutating markup geometry` | `app/lib/main.dart` | `Runtime smoke + code review` |
| `Pan/Tool Selection Safety` | `Selecting any markup drawing tool auto-disables pan mode so draw/select interactions resume immediately` | `app/lib/main.dart` | `Widget tests + runtime smoke` |
| `Dimension Tool Selection` | `Dimension button toggles active drawing mode with visible selected state` | `app/lib/main.dart` | `Widget tests + runtime smoke` |
| `Arrow Tool Selection` | `Arrow button toggles active arrow drawing mode with visible selected state` | `app/lib/main.dart` | `Runtime smoke + code review` |
| `Rectangle Tool Selection` | `Rectangle button toggles active rectangle drawing mode with visible selected state` | `app/lib/main.dart` | `Runtime smoke + code review` |
| `Circle/Oval Tool Selection` | `Circle button toggles active oval drawing mode with visible selected state` | `app/lib/main.dart` | `Runtime smoke + code review` |
| `Dimension Line Draw` | `Drag on overlay creates persistent straight dimension lines above image, clamped to displayed photo bounds` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Widget test drag callbacks + runtime smoke` |
| `Arrow Draw` | `Drag on overlay creates persistent arrows with arrowheads above image, clamped to displayed photo bounds` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Rectangle Draw` | `Drag on overlay creates persistent rectangles above image, clamped to displayed photo bounds` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Circle/Oval Draw` | `Drag on overlay creates persistent ovals above image, clamped to displayed photo bounds` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Dimension Selection` | `Tap line once to select; selected line shows highlighted visual state` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Arrow Selection` | `Tap arrow to select; selected arrow shows highlighted visual state` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Rectangle Selection` | `Tap rectangle to select; selected rectangle shows highlighted visual state` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Circle/Oval Selection` | `Tap oval to select; selected oval shows highlighted visual state` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Freehand Tool Selection` | `Freehand button toggles active freehand drawing mode with visible selected state` | `app/lib/main.dart` | `Runtime smoke + widget tests` |
| `Freehand Draw` | `Drag on overlay creates persistent freehand strokes above image, clamped to displayed photo bounds` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` + `app/lib/features/markup/models/freehand_markup.dart` | `Model tests + runtime smoke` |
| `Freehand Selection` | `Tap stroke to select; selected stroke shows highlighted visual state` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Text Note Tool Selection` | `Text Note button toggles active note placement mode with visible selected state` | `app/lib/main.dart` | `Runtime smoke + widget tests` |
| `Text Note Create/Edit` | `Tap photo opens note dialog; Save creates/updates note at tapped anchor` | `app/lib/main.dart` + `app/lib/features/markup/models/text_note_markup.dart` | `Runtime smoke + model tests` |
| `Text Note Selection` | `Tap note to select; tap selected note again to edit text` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Style Preset Selection` | `Style toolbar action opens touch-friendly preset list (NCD Blue/Red/Yellow/White/Black)` | `app/lib/main.dart` + `app/lib/features/markup/models/markup_style_preset.dart` | `Widget tests + runtime smoke` |
| `Style Preset Application` | `New markups use active style preset and selected markup can be restyled to current preset` | `app/lib/main.dart` + `app/lib/features/markup/models/*` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Model/widget tests + runtime smoke` |
| `Launch Context Bootstrap (Optional)` | `Accepts optional command-line args or launch context JSON path for Control Center-origin sessions; standalone startup remains default when absent` | `app/lib/main.dart` + `app/lib/features/integration/services/launch_context_service.dart` | `Launch-context service tests + runtime smoke` |
| `Launch Source Image Open (Optional)` | `If context includes a valid supported sourceImagePath, app opens it at startup; invalid paths show friendly message and keep app usable` | `app/lib/main.dart` + `app/lib/features/integration/services/launch_context_service.dart` | `Service tests + runtime smoke` |
| `Move Selected Markup` | `Drag already-selected markup to reposition it while clamped to displayed photo bounds` | `app/lib/main.dart` + `app/lib/features/markup/utils/markup_move_utils.dart` | `Utility tests + runtime smoke` |
| `Dimension Endpoint Handles` | `Selected dimension renders endpoint handles and supports drag-adjust on each endpoint` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` + `app/lib/features/markup/utils/markup_handle_utils.dart` | `Handle utility tests + runtime smoke` |
| `Arrow Endpoint Handles` | `Selected arrow renders endpoint handles and supports drag-adjust on each endpoint` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` + `app/lib/features/markup/utils/markup_handle_utils.dart` | `Handle utility tests + runtime smoke` |
| `Rectangle Corner Resize Handles` | `Selected rectangle renders corner handles and supports corner-drag resize with bounds/min-size guards` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` + `app/lib/features/markup/utils/markup_handle_utils.dart` | `Handle utility tests + runtime smoke` |
| `Oval Corner Resize Handles` | `Selected oval renders bounding-box corner handles and supports corner-drag resize with bounds/min-size guards` | `app/lib/main.dart` + `app/lib/features/markup/widgets/dimension_lines_overlay.dart` + `app/lib/features/markup/utils/markup_handle_utils.dart` | `Handle utility tests + runtime smoke` |
| `Dimension Label Entry` | `After line creation, opens manual label dialog with Save/Skip options` | `app/lib/main.dart` | `Runtime smoke + formatter tests` |
| `Dimension Label Render` | `Manual label appears near midpoint with readable background and bounds clamp` | `app/lib/features/markup/widgets/dimension_lines_overlay.dart` | `Runtime smoke + code review` |
| `Dimension Label Edit` | `Tap selected line again to re-open label dialog for updates` | `app/lib/main.dart` | `Runtime smoke + code review` |
| `Erase Selected Markup` | `Erase button and Delete/Backspace remove selected dimension, arrow, rectangle, oval, freehand, or text note immediately` | `app/lib/main.dart` | `Widget test (no-selection safety) + runtime smoke` |
| `Undo Dimension` | `Undo removes most recently added dimension line` | `app/lib/main.dart` | `Widget tests` |
| `Undo Latest Markup` | `Undo removes latest remaining markup regardless of type (dimension, arrow, rectangle, oval, freehand, or text note)` | `app/lib/main.dart` | `Runtime smoke + code review` |
| `Export PNG` | `Prompts user for save location and exports displayed photo area + markups as PNG (no outer letterbox/canvas whitespace)` | `app/lib/main.dart` + `app/lib/features/export/services/marked_up_image_export_service.dart` | `Analyze/test/build/run + pending owner manual E2E` |
| `Save Markup` | `Prompts user for save location and writes editable sidecar (OriginalName - Markup.ncdmarkup.json)` | `app/lib/main.dart` + `app/lib/features/markup/services/editable_markup_document_service.dart` | `Service tests + runtime smoke` |
| `Open Markup` | `Prompts user for sidecar file, loads source photo, and restores editable markups/styles` | `app/lib/main.dart` + `app/lib/features/markup/models/editable_markup_document.dart` | `Service tests + runtime smoke` |
| `Native Windows Close Guard` | `Native title-bar close requests route through unsaved warning flow and block immediate app exit when dirty` | `app/lib/main.dart` | `Analyze/test/build/run + owner manual native-close validation` |
| `Cancel Handling` | `Picker cancel leaves state stable and no crash` | `app/lib/main.dart` | `Runtime automation attempt + no runtime errors` |
| `Non-Approved Future Toolbar Actions` | `Any future actions outside approved scope remain placeholders until explicitly approved` | `app/lib/main.dart` | `Code review + widget/runtime observation` |
| `Branding Assets` | `Startup splash and app bar icon load from app-local branding assets` | `app/assets/branding/` + `app/lib/main.dart` + `app/pubspec.yaml` | `Runtime smoke + asset registration review` |
| `Windows App Icon` | `Executable/runner icon uses approved v1.5 branding source` | `app/windows/runner/resources/app_icon.ico` | `Windows build + resource replacement review` |

## Data and Persistence Boundaries
- Canonical data source: `User-selected local image file path at runtime`
- HEIC/HEIF working-copy policy: `Converted JPEG preview working copy is temporary/internal, preview-capped for display performance, and original source file remains unchanged`
- Launch-context policy: `Client/project/source context can be passed in, but app remains standalone and has no direct Control Center code dependency`
- Local cache policy: `Best-effort FileImage cache eviction on image replacement; stale HEIC preview cache files are pruned by age/count guardrails`
- Migration policy: `N/A`
- Backup/recovery policy: `N/A`

## Control Center Launch Contract (Phase 1P Adapter Foundation)
- Supported launch inputs:
  - Direct args (examples): `--launchedFromControlCenter true`, `--sourceImagePath "C:\path\photo.jpg"`, `--clientName "Client Name"`, `--projectCode "PRJ-01"`.
  - JSON context file path: `--launchContextPath "C:\path\photo_markup_launch_context.json"`.
- Accepted fields:
  - `launchedFromControlCenter`
  - `clientId`
  - `clientName`
  - `projectId`
  - `projectCode`
  - `sourceImagePath`
  - `suggestedExportFolder`
  - `suggestedEditableMarkupFolder`
  - `returnMode`
  - `sourceLabel`
- Safety rules:
  - Unknown fields are ignored.
  - Invalid/missing JSON context file is handled with friendly error copy.
  - Invalid/unsupported launch source image path is rejected with friendly error copy.
  - `suggestedExportFolder` is used only as an export-dialog default location when valid; no automatic writes occur.
  - No autosave, no auto-export, and no direct writes to suggested folders in this phase.
  - No direct dependency on Control Center app internals.

## Logging and Error Controls
- Log schema: `Governance/LOGGING_AND_ERROR_POLICY.md`
- Error handling: `Shows field-safe load message for unsupported/unreadable images and HEIC conversion failures`
- User-safe error behavior:
  - Generic: `Could not open this image. Please choose a JPG, PNG, WEBP, or HEIC/HEIF file.`
  - HEIC/HEIF conversion failure: `Could not open this HEIC image. Please convert it to JPG/PNG or try another photo.`

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
| `RISK-001` | `Core markup tools (dimension/arrow/rectangle/oval/freehand/text note) exist; advanced editing/persistence workflows are still deferred` | `NCD / M` | `Post-MVP phases` | `Intentional` |
| `RISK-002` | `Android runtime behavior not validated` | `NCD / M` | `Later phase` | `Intentional` |
| `RISK-003` | `Manual picker cancel/select steps not fully automatable in this environment` | `Codex` | `Next interactive validation` | `OS SendKeys blocked` |
| `RISK-004` | `Interactive Windows manual drawing + label entry/edit validation still needed` | `NCD / M` | `Next owner interactive run` | `Automated tests cover logic but not full operator flow` |
| `RISK-005` | `Approved v1.5 icon is mini-logo style (small text/detail/padding), so taskbar-size readability is limited without a simplified icon standard` | `NCD / M` | `Future icon redesign phase` | `MVP accepts current transparent icon; redesign tracked in TODO-014` |
| `RISK-006` | `Current export captures visible canvas resolution (viewport-based), not original-image full resolution` | `NCD / M` | `Future export enhancement` | `Tracked in TODO-015` |
| `RISK-007` | `Arrow labels/annotations are intentionally deferred in Arrow MVP` | `NCD / M` | `Future markup enhancement` | `Tracked in TODO-018` |
| `RISK-008` | `Rectangle labels/annotations are intentionally deferred in Rectangle MVP` | `NCD / M` | `Future markup enhancement` | `Tracked in TODO-019` |
| `RISK-009` | `Circle/Oval labels/annotations are intentionally deferred in Circle/Oval MVP` | `NCD / M` | `Future markup enhancement` | `Tracked in TODO-020` |
| `RISK-010` | `Desktop HEIC conversion now uses package-first plus external converter fallback; deployment environments must still provide fallback converter availability` | `NCD / M` | `Near-term validation cycle` | `Provided sample IMG_2434.HEIC now converts successfully; deployment hardening tracked in TODO-021/TODO-023` |
| `RISK-011` | `Advanced handle editing (freehand point editing, text-note resize, rotation, edge handles) remains deferred after endpoint/resize handle MVP` | `NCD / M` | `Future markup enhancement` | `Tracked in TODO-028` |
| `RISK-012` | `Advanced style controls (custom picker, per-tool style editor, saved defaults) remain deferred after style preset MVP` | `NCD / M` | `Future markup enhancement` | `Tracked in TODO-029` |
| `RISK-013` | `Control Center-side launcher and return/save handoff remain deferred; Phase 1P only adds adapter contract inside Photo Markup` | `NCD / M` | `Future integration phase` | `Tracked in TODO-030/TODO-031/TODO-032/TODO-033` |

## Visual and Runtime Behavior
- App bar shows `NCD Photo Markup` and `v0.21`.
- Startup splash renders version text from `AppConstants.appVersion` (same source as app bar version text).
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
- Open Photo launches picker for `jpg`, `jpeg`, `png`, `webp`, `heic`, and `heif`.
- App accepts optional launch context (`--sourceImagePath`, client/project fields, or `--launchContextPath`) and still runs standalone when absent.
- Launch context can display a non-intrusive client/project/source banner when provided.
- Invalid or unsupported launch source image paths show a friendly message and do not block normal app usage.
- HEIC/HEIF files are converted to preview-capped temporary working copies for display/markup (current policy: JPEG cache output), with fallback conversion when package conversion fails.
- Original HEIC/HEIF source files are not modified, moved, overwritten, or deleted.
- Loaded photo is displayed in-canvas with preserved aspect ratio and contain fit.
- Dimension tool can be selected before photo load without crash.
- When a photo is loaded and Dimension is selected, pointer drag creates a straight line overlay with endpoint markers.
- When a photo is loaded and Arrow is selected, pointer drag creates an arrow overlay with a visible arrowhead.
- When a photo is loaded and Rectangle is selected, pointer drag creates a rectangle overlay with visible outline and transparent fill.
- When a photo is loaded and Circle is selected, pointer drag creates an oval overlay with visible outline and transparent fill.
- When a photo is loaded and Text Note is selected, tapping the image opens a note dialog and saves note chips anchored to the photo.
- Toolbar is implemented as a compact left navigation rail with an overlay drawer for sections (`File`, `Markup Tools`, `Edit`) so canvas focus remains primary.
- Drawer anchor is flush to the rail edge (no spacer/gutter strip) and overlays the canvas instead of splitting layout columns.
- Collapsed mode keeps compact icon actions visible; expanded mode overlays compact icon+label rows and supports vertical scrolling if needed.
- Sidebar icons are sourced from centralized Flutter Material `IconData` mappings only (no unicode/emoji text glyph icons and no external icon dependency).
- Toolbar shows active tool status text (`Active Tool: ...`) and style state (`Style: ...`) for quick state awareness.
- Style action remains in the `Edit` group and updates active style for subsequent markups.
- New markups store a style preset id at creation, so changing active preset does not recolor existing markups unexpectedly.
- Dimension drag start/end points are clamped to the actual displayed image rectangle (BoxFit.contain bounds).
- Arrow drag start/end points are clamped to the actual displayed image rectangle (BoxFit.contain bounds).
- Rectangle drag start/end points are clamped to the actual displayed image rectangle (BoxFit.contain bounds).
- Oval drag start/end points are clamped to the actual displayed image rectangle (BoxFit.contain bounds).
- Overlay painter clips drawing to the displayed image rectangle to prevent render bleed into white canvas.
- Tapping a dimension line selects it for erase/edit actions.
- Tapping an arrow selects it for erase actions.
- Tapping a rectangle selects it for erase actions.
- Tapping an oval selects it for erase actions.
- Tapping a text note selects it for erase/edit actions.
- Dragging a selected markup moves the whole markup (dimension/arrow/rectangle/oval/freehand/text note) within displayed image bounds.
- Dimension line labels move with their line during whole-markup move.
- Selected dimension lines and arrows render endpoint handles; dragging a handle adjusts that endpoint.
- Selected rectangles and ovals render corner handles; dragging a corner resizes with minimum-size and bounds guards.
- Handle drag takes priority over whole-markup move when pointer-down is on a visible handle.
- Selected lines render with highlighted stroke styling for clear visual feedback.
- Erase removes the selected dimension/arrow/rectangle/oval/freehand/text note; if nothing is selected, app shows a safe guidance message.
- Keyboard `Delete` and `Backspace` trigger the same selected-line erase path.
- After line creation, label dialog allows manual text input or skip.
- Pressing Enter/Done in the label input submits the same save path as tapping Save.
- Saved labels render near the line midpoint and remain in displayed-image bounds as much as practical.
- Tapping near an existing line re-opens the label dialog for editing.
- Label dialog controller lifecycle is dialog-local to prevent disposed-controller crashes during Save/Enter/Skip teardown.
- Label updates repaint immediately after save (no delayed redraw on next interaction).
- Export button now performs explicit user-selected PNG export workflow:
  - no photo loaded: friendly warning message
  - cancel save dialog: no-op, no crash
  - default suggested name: `OriginalName - Markup.png`
  - default initial save folder: valid `suggestedExportFolder`, otherwise source-image folder when available
  - duplicate filename safety: if target exists, output path auto-increments (`... - Markup 2.png`, `... - Markup 3.png`, ...)
  - selected path: writes PNG cropped to displayed photo rect containing photo + markups
  - original source image is not modified
- If unsaved markup changes exist, open-photo replacement and pop/close route attempts show:
  - `You have unsaved markup changes. Export or discard before continuing.`
  - actions: `Export`, `Discard`, `Cancel`
  - successful export marks state clean.
- Native Windows app-exit requests (title-bar `X`) also use the same unsaved guard flow through `didRequestAppExit`.
- Exported markups preserve style colors/strokes/fills from each markup's stored style preset.
- Save Markup defaults to `OriginalName - Markup.ncdmarkup.json` naming with duplicate-safe increment behavior.
- Open Markup restores saved dimension/arrow/rectangle/oval/freehand/text note geometry and stored style preset IDs.
- If sidecar source image is missing, app prompts user to locate the source image before restoring markups.
- Quick-entry measurement normalization currently outputs inches:
  - `72` -> `72"`
  - `6 6` -> `78"`
  - `5 10` -> `70"`
- Non-measurement free text remains unchanged.
- Undo removes the most recently created markup regardless of type.
- Loaded-photo indicator shows selected file name.
- Unsupported/unreadable image shows field-safe error message.
- If HEIC/HEIF conversion fails, app shows HEIC-specific friendly field-safe message.

## Tunable Constants Standard (Governance v1.7)
- Tunable Flutter/Dart values are centralized in `app/lib/core/constants/app_constants.dart`.
- Grouped domains:
  - app metadata/version
  - theme/colors
  - image import (picker labels, supported extensions, HEIC preview cache/output/quality/cap/timeout, fallback args, temp cleanup limits, and friendly import error/progress copy)
  - UI copy strings
  - tool labels
  - layout/spacing/sizing
  - dimension line styling and drag thresholds
  - dimension label dialog copy
  - dimension label style/placement thresholds
  - dimension selection/erase copy and visual style tunables
  - arrow style/arrowhead/selection tunables
  - rectangle outline/fill/selection tunables
  - oval outline/fill/selection tunables
  - freehand stroke/selection/point-threshold tunables
  - text note dialog copy and note chip style/selection tunables
  - markup move threshold/hit-distance/fine-delta/bounds-padding tunables
  - endpoint/resize handle radius, hit-distance, drag-threshold, and handle visual style tunables
  - style selector labels/copy and preset definitions (names/colors/fill/text-note chip colors)
  - export default filename suffix, extension, and duplicate-name sequence tunables
  - editable markup sidecar schema version, extension, dialog labels, and duplicate-name sequence tunables
  - unsaved-change warning copy/action labels
- Remaining repeated literals in `app/lib/main.dart` are intentional one-off framework/style usages and are tracked in validation notes.
- Toolbar section labels/order are centralized in `ToolbarConstants.sections`.
- Splash duration remains tunable through `BrandingAssetConstants.startupSplashDurationMs`.
- Splash footprint remains tunable through:
  - `UiLayoutConstants.splashImageWidthFactor`
  - `UiLayoutConstants.splashImageHeightFactor`
- Version sync contract:
  - `VERSION` is the canonical release value.
  - `scripts/bump-version.ps1` updates both `VERSION` and `AppConstants.appVersion`.
  - `scripts/verify-version-sync.ps1` must pass to verify splash/app version parity.





## Roadmap (Near-Future)
- Future Phase: Extended Apple compatibility beyond MVP HEIC/HEIF import (see Operations/TODO_REGISTER.md).
- Future Phase: NCD Control Center Integration via isolated adapter/service boundaries (see Operations/TODO_REGISTER.md).
- Post-MVP priorities are now grouped as Critical/High/Medium in `Operations/TODO_REGISTER.md`:
  - Critical: Editable Save/Reopen, Full-Resolution Export, Undo/Redo, Export Naming, Large-Image Performance.
  - Touch UX baseline compact rail + expandable drawer is now delivered in Phase 1U; ultra-compact short-window follow-up is tracked in `TODO-037`.
  - High: Multi-photo sets, Control Center adapter, Samsung/Android validation, Apple review, HEIC fallback hardening, export-quality review.
  - Medium: Icon standard redesign, optional PDF, voice-to-text notes, styling panel, editable schema, error polish, onboarding, touch feedback, z-order, governance icon standard follow-up, advanced handle editing beyond Phase 1N.

## Phase 1A.1 Structure Note
- This phase updates repository structure, governance scripts, and documentation references only.
- No app runtime or image import behavior changes are included in this phase.

