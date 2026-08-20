# NCD Photo Markup

Document Path: `C:\apps\NCD_Photo_Markup\README.md`
Version: `v0.6`
Owner: `NCD / M`
Last Updated By: `Claude`
Last Updated: `2026-08-19`
Purpose: Root repo map, app overview, and quick start for the standalone Flutter app.
Changes: Adopted the owner bump-and-push rule in the version rules section.

## What This Is
Touch-first field photo markup app for internal and client annotation work.
A photo is opened, marked up on screen, and produces two separate outputs: an
editable markup sidecar file and a flattened PNG export. The source photo is
never modified.

Windows tablet first. Android (Samsung tablet) is planned, not built.

## Repo Map
- `app/`: Flutter runtime app (Windows-first currently).
- `System/Documentation/`: project-level working docs.
- `Governance/`: governance and policy documents.
- `Operations/`: operational logs, validation, and checklist docs.
- `Templates/`: reusable documentation templates.
- `scripts/`: governance hook/version scripts.
- `.agent_temp/`: ignored temporary artifacts.
- `VERSION`: repo version file for push-hook/version governance.

## Markup Tools
Sidebar sections are `File`, `Markup Tools`, and `Edit`.

| Tool | What it does |
|---|---|
| `Scale Calibration` | Drag a line across something of known length, then enter the real distance and unit. Every measurement tool afterwards reports real-world values. Draws **dashed in its own colour** and labels itself `SCALE: 8 ft`, so it never looks like an annotation. One per photo; drawing another replaces it. |
| `Multi-Segment` | Tap point to point for a running length. Double-tap the last point or press Enter to finish. |
| `Area / Perimeter` | Tap points to enclose a shape. Tap the first point again or double-tap the last point to close. Reports area and perimeter. |
| `Dimension` | Two-point dimension line with an editable label. On a calibrated photo the label opens pre-filled with the measured value; type over it to change it. |
| `Text Note` | Free text placed on the photo. |
| `Arrow` | Straight arrow with a head. |
| `Rectangle` | Rectangle outline. |
| `Circle` | Ellipse outline. |
| `Freehand` | Freehand stroke. |

`Edit` holds `Style`, `Undo`, and `Erase`.

Measurement tools without a calibration show `Set scale` instead of a value.
Calibration is stored per photo and saved into the markup sidecar file.

### Scale Calibration is not a Dimension
They look similar because both are a two-point line, but they do different jobs:

- A `Dimension` is an annotation. You type the label. Nothing is calculated from
  it, and you can place as many as you like.
- `Scale Calibration` is the reference. There is one per photo. It tells the app
  how many real units a pixel is worth, and `Multi-Segment` and
  `Area / Perimeter` compute their labels from it. A new `Dimension` is also
  pre-filled from it.

A measured value you keep is stored exactly as shown. Only a label you type
yourself goes through the imperial shorthand formatter, which turns `6'-0"` into
`72"`. There is no unit conversion; a dimension is reported in the same unit you
calibrated with.

Every mark is stored in normalized (`0..1`) coordinates against the source
image, so marks stay in the right place when the window is resized.

## Supported Input
`jpg`, `jpeg`, `png`, `webp`, `heic`, `heif`, `dwg`.

- HEIC/HEIF are converted to a cached preview before display.
- DWG opens through a preview conversion path only. There is no free offline DWG
  renderer in the app; see `TODO-040` in `Operations/TODO_REGISTER.md`.

## File Outputs
Two separate files, written next to the photo unless another folder is chosen.

| Output | Name | Notes |
|---|---|---|
| Editable markup | `<photo>.ncdmarkup.json` | Schema version `1.0`. Reopen it to keep editing. Holds every mark, the style, and the scale calibration. |
| Flattened image | `<photo> - Markup.png` | PNG only. Duplicate names get a numeric suffix rather than overwriting. |

The source photo is never written to.

## Control Center Launch Arguments
The app accepts these on the command line, all in `--key=value` form:

`launchContextPath`, `launchedFromControlCenter`, `clientId`, `clientName`,
`projectId`, `projectCode`, `sourceImagePath`, `suggestedExportFolder`,
`suggestedEditableMarkupFolder`, `returnMode`, `sourceLabel`.

Example:

```
ncd_photo_markup.exe --sourceImagePath="C:\jobs\1042\front-elevation.jpg" --suggestedExportFolder="C:\jobs\1042\markup"
```

Unknown keys are ignored. Launching with no arguments opens the empty state.

## App Source Map
From `app/lib/`:

| Path | Holds |
|---|---|
| `main.dart` | App shell, sidebar wiring, tool state, dialogs, save/open/export actions. |
| `core/constants/app_constants.dart` | All tunable constants and user-facing copy. Change strings and sizes here, not inline. |
| `features/markup/models/` | Mark data types, including `scale_calibration.dart`, `multi_segment_measurement.dart`, `area_measurement.dart`, and the sidecar document. |
| `features/markup/utils/measurement_value_utils.dart` | Measurement math and value formatting. |
| `features/markup/utils/markup_interaction_policy.dart` | Which tools draw by drag, by tap sequence, or by dialog. |
| `features/markup/widgets/dimension_lines_overlay.dart` | Canvas painting, hit testing, selection, and drag handles. |
| `features/markup/services/` | Editable sidecar read and write. |
| `features/import/services/` | Image import, HEIC and DWG preview conversion. |
| `features/export/services/` | PNG export and export path naming. |
| `features/integration/services/` | Control Center launch context parsing. |
| `features/sidebar/models/sidebar_icon_pack.dart` | Sidebar icon and label mapping. |

Constants policy: user-facing text and tunable numbers live in
`app_constants.dart`. See `Governance/Examples/CONSTANT_BLOCKS_EXAMPLE.md`.

## Run and Validate
From the `app/` folder:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build windows --debug`
- `flutter run -d windows --debug --no-resident`

### Build limitation on the network drive
`flutter build windows` and `flutter run -d windows` fail when the repo is
checked out on the `H:` network share (`\\NCD-NAS01\homes`). The Flutter tool
crashes creating the plugin symlinks under
`app/windows/flutter/ephemeral/.plugin_symlinks`. The observed errors are
`Cannot create link ... errno = 183` and, once the folder is cleared,
`ERROR_ACCESS_DENIED ... trying to create a symlink` pointing from the share to
the pub cache on `C:`. Directory junctions fail too (`Local NTFS volumes are
required`), and Windows Developer Mode is already enabled, so neither is the
cause. Real copies in place of the links do not work either, because the tool
insists on creating links.

`flutter analyze` and `flutter test` run fine from the network path. To build or
run the Windows app, use a local-drive checkout such as `C:\apps\NCD_Photo_Markup`.

## Workspace Paths
- Canonical path in governance docs: `C:\apps\NCD_Photo_Markup`
- Current working checkout: `H:\Marcelo\Programming\apps\NCD_Photo_Markup`
- Active branch: `main` (`System/Documentation/APP_PROFILE.md` still records `master`)

## Key Documents
- `System/Documentation/APP_PROFILE.md`
- `System/Documentation/PROJECT_DOCUMENTATION.md`
- `System/Documentation/CHANGELOG.md`
- `System/Documentation/RELEASE_NOTES.md`
- `System/Documentation/UI_STANDARDS.md`
- `System/Documentation/UI_STANDARDS_SELECTION_FORM.md`
- `System/Documentation/FORM_DEFINITIONS.md`
- `Governance/MASTER_GUIDELINE.md`
- `Governance/AGENT_BASELINE.md`
- `Governance/CODE_FILE_STRUCTURE_POLICY.md`
- `Governance/VERSIONING_AND_CHANGE_CONTROL.md`
- `Governance/RELEASE_AND_VALIDATION_POLICY.md`
- `Governance/Language_Addendums/DART_FLUTTER_ADDENDUM.md`
- `Governance/Examples/CONSTANT_BLOCKS_EXAMPLE.md`
- `Operations/VALIDATION_MATRIX.md`
- `Operations/TODO_REGISTER.md`
- `Operations/DECISION_LOG.md`
- `Operations/SESSION.md`

## Governance Commands
- `powershell -ExecutionPolicy Bypass -File scripts/setup-git-hooks.ps1`
- `powershell -ExecutionPolicy Bypass -File scripts/verify-version-sync.ps1`
- `powershell -ExecutionPolicy Bypass -File scripts/bump-version.ps1 -Bump minor -Reason "<reason>"`

## Version Rules
- Current version: `v0.34`
- Use two-part versions only (`v0.1`, `v0.2`, `v0.3`, `v0.4`, ...)
- **Every change bumps the version, gets committed, and gets pushed.** A one-line
  fix, a doc edit, and a test-only change all bump. Nothing stays at the same
  version.
- A version is never withheld pending validation. Validation decides whether a
  version is good, not whether it gets a number. An unvalidated version is
  recorded as unvalidated and still gets its number.
- Bump with `scripts/bump-version.ps1`; the pre-push hook rejects a push with no
  bump.
- See `Governance/VERSIONING_AND_CHANGE_CONTROL.md`.

## Current State and Known Gaps
- Phase 1Z measurement tools are MVP wiring. Owner manual validation on real
  photos is still pending before any version bump.
- `TODO-040` offline DWG rendering is open and unchanged. Free offline renderer
  research was recorded as blocked.
- No autosave, no full-resolution export, and no PDF export.
- Android is not built.
