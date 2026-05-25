# Form Definitions

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\FORM_DEFINITIONS.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-24`
Purpose: Define app forms/screens and responsibilities.
Changes: Added Phase 1K Freehand Tool MVP behavior.

## Primary Forms/Screens
- `Photo Markup Shell` (implemented)
- `Photo Canvas Area` (implemented with image display)
- `Dimension Overlay Layer` (implemented)
- `Arrow Overlay Layer` (implemented)
- `Rectangle Overlay Layer` (implemented)
- `Circle/Oval Overlay Layer` (implemented)
- `Freehand Overlay Layer` (implemented)
- `HEIC/HEIF Import Conversion Flow` (implemented)
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
- `image_import_service (HEIC/HEIF conversion to temporary PNG working copy)`
- Data sources:
- `Runtime-selected local image path`
- Route/name:
- `home`
- Read/write behavior: `MIXED`
- Notes:
- `Open Photo + Dimension + Arrow + Rectangle + Circle + Undo are functional in this phase`
- `Open Photo + Dimension + Arrow + Rectangle + Circle + Freehand + Undo are functional in this phase`
- `Erase removes currently selected dimension line/arrow/rectangle/oval (+dimension label when applicable)`
- `Open Photo supports jpg/jpeg/png/webp/heic/heif`
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
- `Original selected source file is not modified`
- `Shows safe error message if image cannot be opened`
- `HEIC/HEIF source files are converted to temporary PNG working copies for display/markup`
- `Dimension overlay is constrained to displayed photo bounds (BoxFit.contain rect)`

#### `HEIC/HEIF Import Conversion Flow`
- Source path: `app/lib/features/import/services/image_import_service.dart`
- Purpose: `Convert HEIC/HEIF images to displayable PNG bytes/file path for Flutter canvas rendering`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `HEIC extension detection`
- `Conversion call via heic_to_png_jpg (primary path)`
- `External conversion fallback via magick command`
- `Temporary file write and cleanup`
- Related widgets/components:
- `PhotoMarkupShellScreen import path`
- `ImageImportResult`
- Read/write behavior: `READ_WRITE`
- Notes:
- `Original HEIC/HEIF file remains unchanged`
- `Temporary converted file is internal working copy only`
- `Conversion attempts package path first, then external fallback`
- `Conversion failure returns friendly field-safe HEIC message if both paths fail`

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
- `Supports multiple dimension lines/arrows and undo-latest-markup behavior`
- `Supports multiple dimension lines/arrows/rectangles/ovals and undo-latest-markup behavior`
- `Pointer start/update is clamped to displayed image rectangle`
- `Painter clips draw operations to displayed image rectangle`
- `Line labels render near midpoint with readable chip styling`
- `Tap-near-line can trigger label edit flow`
- `Single tap selects line; second tap on selected line re-opens label edit`
- `Selected line visual state is highlighted`
- `Delete/Backspace keyboard keys erase selected line`

#### `Freehand Overlay Layer`
- Source path: `app/lib/features/markup/widgets/dimension_lines_overlay.dart`
- Purpose: `Capture drag path and render freehand strokes above the displayed photo`
- Parent/master form: `Photo Canvas Area`
- Child components:
- `Active freehand path preview`
- `Persisted freehand stroke rendering`
- `Freehand stroke hit testing for selection`
- Related widgets/components:
- `DimensionLinesOverlay`
- `FreehandMarkup` model
- Read/write behavior: `MIXED`
- Notes:
- `Freehand points are clamped to displayed image bounds`
- `Freehand uses minimum point distance threshold to reduce over-capture`
- `Selected freehand stroke uses highlighted visual state`
- `Erase/Delete/Backspace support freehand deletion`

#### `Circle/Oval Overlay Layer`
- Source path: `app/lib/features/markup/widgets/dimension_lines_overlay.dart`
- Purpose: `Capture oval drag gestures and render oval highlights`
- Parent/master form: `Photo Canvas Area`
- Child components:
- `CustomPaint oval renderer`
- `Transparent-fill + outline style`
- `Shared pointer event listener`
- Related widgets/components:
- `DimensionLinesOverlay`
- `OvalMarkup` model
- Read/write behavior: `MIXED`
- Notes:
- `Circle/Oval tool remains separate from Rectangle and Arrow tools`
- `Oval bounds are clamped to displayed photo rectangle`
- `Selected oval visual state is highlighted`
- `Erase/Delete/Backspace remove selected oval`

#### `Rectangle Overlay Layer`
- Source path: `app/lib/features/markup/widgets/dimension_lines_overlay.dart`
- Purpose: `Capture rectangle drag gestures and render rectangular scope areas`
- Parent/master form: `Photo Canvas Area`
- Child components:
- `CustomPaint rectangle renderer`
- `Transparent-fill + outline style`
- `Shared pointer event listener`
- Related widgets/components:
- `DimensionLinesOverlay`
- `RectangleMarkup` model
- Read/write behavior: `MIXED`
- Notes:
- `Rectangle tool remains separate from Dimension and Arrow tools`
- `Rectangle bounds are clamped to displayed photo rectangle`
- `Selected rectangle visual state is highlighted`
- `Erase/Delete/Backspace remove selected rectangle`

#### `Arrow Overlay Layer`
- Source path: `app/lib/features/markup/widgets/dimension_lines_overlay.dart`
- Purpose: `Capture arrow drag gestures and render arrows with visible arrowheads`
- Parent/master form: `Photo Canvas Area`
- Child components:
- `CustomPaint arrow renderer`
- `Arrowhead render logic`
- `Shared pointer event listener`
- Related widgets/components:
- `DimensionLinesOverlay`
- `ArrowMarkup` model
- Read/write behavior: `MIXED`
- Notes:
- `Arrow tool remains separate from Dimension tool`
- `Arrow start/end points are clamped to displayed photo bounds`
- `Selected arrow visual state is highlighted`
- `Erase/Delete/Backspace remove selected arrow`

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
| `Image Import Service` | `HEIC/HEIF Import Conversion Flow` | `Convert HEIC/HEIF to temporary PNG working copy` | `app/lib/features/import/services/image_import_service.dart` |
| `Canvas Image View` | `Photo Canvas Area` | `Render selected photo with BoxFit.contain` | `app/lib/main.dart` |
| `Touch Toolbar` | `Photo Markup Shell` | `Expose tool actions with selected/disabled state` | `app/lib/main.dart` |
| `Dimension Overlay` | `Dimension Overlay Layer` | `Render and capture dimension line interactions` | `app/lib/features/markup/widgets/dimension_lines_overlay.dart` |
| `Dimension Model` | `Dimension Overlay Layer` | `Store start/end coordinates for each line` | `app/lib/features/markup/models/dimension_line.dart` |
| `Oval Model` | `Circle/Oval Overlay Layer` | `Store start/end coordinates for each oval` | `app/lib/features/markup/models/oval_markup.dart` |
| `Dimension Label Dialog` | `Dimension Label Dialog` | `Collect manual label text with Save/Skip` | `app/lib/main.dart` |
| `Dimension Label Formatter` | `Dimension Label Dialog` | `Normalize common feet/inches inputs` | `app/lib/features/markup/utils/dimension_label_formatter.dart` |
| `Export Service` | `Export / Save Dialog` | `Capture marked canvas and write PNG bytes` | `app/lib/features/export/services/marked_up_image_export_service.dart` |

## Phase 1D Review Note
- Dimension label entry/edit behavior is implemented on top of existing dimension overlay.
- Non-dimension tools remain placeholders in this phase.
- Icon quality refinement in this pass changed branding assets only (no form flow changes).
- Taskbar icon variant pass changed only branding image assets and Windows icon packaging (no form flow changes).
- Approved-design icon correction pass also changed only branding image assets and Windows icon packaging (no form flow changes).


