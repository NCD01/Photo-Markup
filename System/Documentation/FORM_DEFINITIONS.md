# Form Definitions

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\FORM_DEFINITIONS.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-24`
Purpose: Define app forms/screens and responsibilities.
Changes: Added Phase 1F dimension selection and erase/delete behavior.

## Primary Forms/Screens
- `Photo Markup Shell` (implemented)
- `Photo Canvas Area` (implemented with image display)
- `Dimension Overlay Layer` (implemented)
- `Dimension Label Dialog` (implemented)
- `Export / Save Dialog` (implemented for PNG)
- `Selected Dimension Erase Action` (implemented)

## Field Work Forms
### `Shell` Forms

#### `Photo Markup Shell`
- Source path: `app/lib/main.dart`
- Purpose: `Provide top-level shell with app bar, canvas area, and bottom touch toolbar`
- Parent/master form: `Root app`
- Child components:
- `Canvas area`
- `Horizontal touch toolbar`
- `Dimension overlay interaction layer`
- `Dimension label prompt flow`
- Related widgets/components:
- `_ToolbarPlaceholderButton`
- `DimensionLinesOverlay`
- Related services:
- `file_selector picker integration`
- Data sources:
- `Runtime-selected local image path`
- Route/name:
- `home`
- Read/write behavior: `MIXED`
- Notes:
- `Open Photo + Dimension + Undo (dimension only) are functional in this phase`
- `Erase removes currently selected dimension line + label`
- `Startup splash uses approved v1.5 asset with centralized duration (2200 ms)`
- `Startup splash image is scaled to fill most of startup screen`
- `Startup splash version text uses AppConstants.appVersion (shared with app bar version)`
- `Windows app opens maximized on launch`

#### `Photo Canvas Area`
- Source path: `app/lib/main.dart`
- Purpose: `Display empty state or selected image using contain-fit`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Empty-state icon/text`
- `Image display pane`
- `Dimension line overlay (when photo loaded)`
- `Loaded filename indicator`
- Read/write behavior: `READ_ONLY`
- Notes:
- `Original image is not copied or modified`
- `Shows safe error message if image cannot be opened`
- `Dimension overlay is constrained to displayed photo bounds (BoxFit.contain rect)`

#### `Dimension Overlay Layer`
- Source path: `app/lib/features/markup/widgets/dimension_lines_overlay.dart`
- Purpose: `Capture drag gestures and render dimension lines above the image`
- Parent/master form: `Photo Canvas Area`
- Child components:
- `CustomPaint dimension line renderer`
- `Pointer event listener for drag start/update/end`
- Related widgets/components:
- `DimensionLinesOverlay`
- `DimensionLine` model
- Read/write behavior: `MIXED`
- Notes:
- `Overlay draws above image and does not modify original file`
- `Supports multiple lines and undo-last-line behavior`
- `Pointer start/update is clamped to displayed image rectangle`
- `Painter clips draw operations to displayed image rectangle`
- `Line labels render near midpoint with readable chip styling`
- `Tap-near-line can trigger label edit flow`
- `Single tap selects line; second tap on selected line re-opens label edit`
- `Selected line visual state is highlighted`
- `Delete/Backspace keyboard keys erase selected line`

#### `Dimension Label Dialog`
- Source path: `app/lib/main.dart`
- Purpose: `Collect manual measurement/note text for a new or existing dimension line`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Large text entry field`
- `Save action`
- `Skip action`
- Related widgets/components:
- `AlertDialog` + `TextField`
- `DimensionLabelFormatter`
- Read/write behavior: `MIXED`
- Notes:
- `Shown automatically after line creation`
- `Can be opened by tapping near an existing line`
- `Skips are allowed; labels are optional`
- `Enter/Done key submits label as Save`
- `Dialog owns/disposes its own TextEditingController to avoid disposed-controller crashes during close/rebuild`
- `Saved label repaint is immediate (no next-action refresh required)`

#### `Export / Save Dialog`
- Source path: `app/lib/main.dart` + `app/lib/features/export/services/marked_up_image_export_service.dart`
- Purpose: `Prompt for output file location and export visible marked canvas PNG`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Save location prompt`
- `Success/failure feedback snackbar`
- Read/write behavior: `WRITE_ONLY`
- Notes:
- `Export is user-selected only; no automatic project-folder save`
- `No-photo export shows friendly warning and does not crash`
- `Cancel path performs no-op and does not crash`
- `Current export output is viewport-resolution capture (full-resolution export deferred)`

## Dependency/Component Map
| Name | Form | Purpose | Path |
|---|---|---|---|
| `App Bar` | `Photo Markup Shell` | `Show app name and version` | `app/lib/main.dart` |
| `Startup Splash` | `Photo Markup Shell` | `Show startup branding image before shell loads` | `app/lib/main.dart` + `app/assets/branding/splash_v1_5.png` |
| `Windows Runner Icon` | `Photo Markup Shell` | `Apply app icon branding to Windows executable resources` | `app/windows/runner/resources/app_icon.ico` |
| `Open Photo Action` | `Photo Markup Shell` | `Launch picker and request image file` | `app/lib/main.dart` |
| `Canvas Image View` | `Photo Canvas Area` | `Render selected photo with BoxFit.contain` | `app/lib/main.dart` |
| `Touch Toolbar` | `Photo Markup Shell` | `Expose tool actions with selected/disabled state` | `app/lib/main.dart` |
| `Dimension Overlay` | `Dimension Overlay Layer` | `Render and capture dimension line interactions` | `app/lib/features/markup/widgets/dimension_lines_overlay.dart` |
| `Dimension Model` | `Dimension Overlay Layer` | `Store start/end coordinates for each line` | `app/lib/features/markup/models/dimension_line.dart` |
| `Dimension Label Dialog` | `Dimension Label Dialog` | `Collect manual label text with Save/Skip` | `app/lib/main.dart` |
| `Dimension Label Formatter` | `Dimension Label Dialog` | `Normalize common feet/inches inputs` | `app/lib/features/markup/utils/dimension_label_formatter.dart` |
| `Export Service` | `Export / Save Dialog` | `Capture marked canvas and write PNG bytes` | `app/lib/features/export/services/marked_up_image_export_service.dart` |

## Phase 1D Review Note
- Dimension label entry/edit behavior is implemented on top of existing dimension overlay.
- Non-dimension tools remain placeholders in this phase.
- Icon quality refinement in this pass changed branding assets only (no form flow changes).
- Taskbar icon variant pass changed only branding image assets and Windows icon packaging (no form flow changes).
- Approved-design icon correction pass also changed only branding image assets and Windows icon packaging (no form flow changes).


