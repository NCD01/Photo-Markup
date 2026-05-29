# Form Definitions

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\FORM_DEFINITIONS.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-28`
Purpose: Define app forms/screens and responsibilities.
Changes: Added Phase 1T-A import performance/memory cleanup and import-progress UI notes.

## Primary Forms/Screens
- `Photo Markup Shell` (implemented)
- `Photo Canvas Area` (implemented with image display)
- `Dimension Overlay Layer` (implemented)
- `Arrow Overlay Layer` (implemented)
- `Rectangle Overlay Layer` (implemented)
- `Circle/Oval Overlay Layer` (implemented)
- `Freehand Overlay Layer` (implemented)
- `Text Note Overlay Layer` (implemented)
- `HEIC/HEIF Import Conversion Flow` (implemented)
- `Dimension Label Dialog` (implemented)
- `Text Note Dialog` (implemented)
- `Export / Save Dialog` (implemented for PNG)
- `Style Preset Selector` (implemented)
- `Launch Context Adapter` (implemented, optional)
- `Selected Markup Erase Action` (implemented)
- `Selected Markup Move/Adjust Action` (implemented, whole-markup move MVP)
- `Endpoint/Resize Handle Adjust Action` (implemented for dimension/arrow/rectangle/oval)
- `Unsaved Close Guard Dialog` (implemented for route pop + native Windows app-exit requests)

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
- `Open Photo + Dimension + Arrow + Rectangle + Circle + Freehand + Text Note + Undo are functional in this phase`
- `Style selector supports NCD Blue / Red / Yellow / White / Black presets`
- `Erase removes currently selected dimension/arrow/rectangle/oval/freehand/text note (+dimension label when applicable)`
- `Dragging a selected markup moves the whole markup while clamped to displayed photo bounds`
- `Preset selection updates new-markup style and can apply style to selected markup`
- `Open Photo supports jpg/jpeg/png/webp/heic/heif`
- `Optional launch context is parsed at startup and can show a non-intrusive context banner`
- `Native Windows title-bar close requests are intercepted and routed to the unsaved guard dialog when markup state is dirty`
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
- `Import in-progress indicator/copy while loading/converting`
- Read/write behavior: `READ_ONLY`
- Notes:
- `Original selected source file is not modified`
- `Shows safe error message if image cannot be opened`
- `HEIC/HEIF source files are converted to preview-capped temporary PNG working copies for display/markup`
- `Import progress message ('Opening photo...') is shown while import/conversion is active`
- `Dimension overlay is constrained to displayed photo bounds (BoxFit.contain rect)`

#### `HEIC/HEIF Import Conversion Flow`
- Source path: `app/lib/features/import/services/image_import_service.dart`
- Purpose: `Convert HEIC/HEIF images to displayable preview-capped PNG file paths for Flutter canvas rendering`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `HEIC extension detection`
- `Conversion call via heic_to_png_jpg (primary path)`
- `External conversion fallback via magick command`
- `Temporary file write and cleanup`
- `Stale temp converted-file cleanup (age/count guardrails)`
- Related widgets/components:
- `PhotoMarkupShellScreen import path`
- `ImageImportResult`
- Read/write behavior: `READ_WRITE`
- Notes:
- `Original HEIC/HEIF file remains unchanged`
- `Temporary converted file is internal working copy only and remains in temp path`
- `Conversion attempts package file-based path first (with preview cap), then external fallback`
- `Image replacement path performs best-effort file-image cache eviction`
- `Conversion failure returns friendly field-safe HEIC message if both paths fail`

#### `Launch Context Adapter`
- Source path: `app/lib/features/integration/services/launch_context_service.dart`
- Purpose: `Parse optional Control Center launch contract fields while keeping standalone startup behavior intact`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Command-line arg parser for approved fields`
- `Optional JSON launch-context loader`
- `Source image path validation gate`
- `Context summary banner wiring`
- Related widgets/components:
- `NcdPhotoMarkupApp` bootstrap
- `PhotoMarkupShellScreen` context banner and startup image load
- `PhotoMarkupLaunchContext` model
- Read/write behavior: `READ_ONLY` (context intake only in Phase 1P)
- Notes:
- `No direct Control Center app dependency`
- `No project-folder autosave`
- `No auto-export`
- `Unknown context fields are ignored safely`

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
- `Dragging a selected line moves the line + label together`
- `Selected dimension line shows endpoint handles; dragging a handle adjusts the selected endpoint`
- `Dimension line style follows stored markup preset`

#### `Text Note Overlay Layer`
- Source path: `app/lib/features/markup/widgets/dimension_lines_overlay.dart`
- Purpose: `Render text-note chips anchored to image-space points and support tap hit-testing/selection`
- Parent/master form: `Photo Canvas Area`
- Child components:
- `Text chip painter`
- `Selected note highlight state`
- `Tap hit-distance logic tied to rendered chip rect`
- Related widgets/components:
- `DimensionLinesOverlay`
- `TextNoteMarkup` model
- Read/write behavior: `MIXED`
- Notes:
- `Text notes are clamped to displayed image bounds`
- `Text notes render with readable font and contrast chip styling`
- `Tap selected note again re-opens edit dialog`
- `Erase/Delete/Backspace support text note deletion`
- `Dragging a selected note moves note position instead of opening edit`
- `Text-note chip colors follow stored markup preset with readability-first contrast`

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
- `Dragging a selected freehand stroke moves the whole stroke`
- `Freehand stroke style follows stored markup preset`

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
- `Dragging a selected oval moves the whole oval`
- `Selected oval shows corner resize handles; dragging a corner resizes the oval within displayed photo bounds`
- `Oval outline/fill style follows stored markup preset`

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
- `Dragging a selected rectangle moves the whole rectangle`
- `Selected rectangle shows corner resize handles; dragging a corner resizes the rectangle within displayed photo bounds`
- `Rectangle outline/fill style follows stored markup preset`

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
- `Dragging a selected arrow moves the whole arrow`
- `Selected arrow shows endpoint handles; dragging a handle adjusts the selected endpoint and arrowhead direction`
- `Arrow style follows stored markup preset`

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

#### `Text Note Dialog`
- Source path: `app/lib/main.dart`
- Purpose: `Create/edit standalone text notes not tied to dimension lines`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Large text entry field`
- `Save action`
- `Skip action`
- Related widgets/components:
- `AlertDialog` + `TextField`
- `_TextNoteDialog` stateful widget
- Read/write behavior: `MIXED`
- Notes:
- `Shown after tapping the image while Text Note tool is active`
- `Tap selected text note again opens edit flow`
- `Skip/Cancel closes dialog without creating/updating a note`
- `Enter/Done key submits note as Save`
- `Dialog owns/disposes its own TextEditingController to avoid disposed-controller crashes`

#### `Style Preset Selector`
- Source path: `app/lib/main.dart` + `app/lib/features/markup/models/markup_style_preset.dart`
- Purpose: `Allow touch-friendly selection of centralized markup style presets`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Style toolbar button`
- `Preset picker dialog/list`
- `Optional apply-to-selected behavior`
- Related widgets/components:
- `_ToolbarActionButton`
- `MarkupStylePresets`
- Read/write behavior: `MIXED`
- Notes:
- `Preset updates style for new markups`
- `If markup is selected, preset can restyle the selected markup`
- `Advanced custom picker/user-default persistence remains deferred`

#### `Export / Save Dialog`
- Source path: `app/lib/main.dart` + `app/lib/features/export/services/marked_up_image_export_service.dart` + `app/lib/features/export/services/markup_export_path_service.dart`
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
- `Default suggested output name is OriginalName - Markup.png`
- `Default initial save folder uses valid launch suggestedExportFolder first, then source-image folder when available`
- `If target exists, export path is incremented safely (for example: OriginalName - Markup 2.png)`
- `Current export output is viewport-resolution capture (full-resolution export deferred)`

#### `Save Markup Dialog`
- Source path: `app/lib/main.dart` + `app/lib/features/markup/services/editable_markup_document_service.dart`
- Purpose: `Prompt for editable sidecar save location and write .ncdmarkup.json document`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Save location prompt`
- `Success/failure feedback snackbar`
- Read/write behavior: `WRITE_ONLY`
- Notes:
- `Save is user-triggered only (no autosave)`
- `Default sidecar name is OriginalName - Markup.ncdmarkup.json`
- `Default folder prefers launch suggestedEditableMarkupFolder, then launch suggestedExportFolder, then source-image folder`
- `If target exists, sidecar path is incremented safely (for example: OriginalName - Markup 2.ncdmarkup.json)`
- `Successful save marks unsaved state clean`

#### `Open Markup Dialog`
- Source path: `app/lib/main.dart` + `app/lib/features/markup/models/editable_markup_document.dart`
- Purpose: `Open editable sidecar and restore source image + markup state`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Open file prompt`
- `Missing source image locate prompt`
- `Success/failure feedback snackbar`
- Read/write behavior: `READ_ONLY`
- Notes:
- `Open is user-triggered only`
- `Reopen restores dimension/arrow/rectangle/oval/freehand/text note markups and style preset ids`
- `If source image path is missing/invalid, app prompts user to locate source image before restore`
- `Successful reopen marks unsaved state clean`

#### `Unsaved Changes Guard Dialog`
- Source path: `app/lib/main.dart` + `app/lib/features/markup/utils/unsaved_changes_tracker.dart`
- Purpose: `Prevent accidental loss of markup edits when replacing the loaded image or leaving the shell route`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Warning title/body text`
- `Export action`
- `Discard action`
- `Cancel action`
- Read/write behavior: `MIXED`
- Notes:
- `Shown when unsaved markup changes exist and user attempts open-photo replacement or pop/close route action`
- `Export runs normal manual PNG save flow and marks state clean on success`
- `Discard clears unsaved flag for current session state transition`
- `Cancel keeps current image/markups in place`

## Dependency/Component Map
| Name | Form | Purpose | Path |
|---|---|---|---|
| `App Bar` | `Photo Markup Shell` | `Show app name and version` | `app/lib/main.dart` |
| `Startup Splash` | `Photo Markup Shell` | `Show startup branding image before shell loads` | `app/lib/main.dart` + `app/assets/branding/splash_v1_5.png` |
| `Windows Runner Icon` | `Photo Markup Shell` | `Apply app icon branding to Windows executable resources` | `app/windows/runner/resources/app_icon.ico` |
| `Open Photo Action` | `Photo Markup Shell` | `Launch picker and request image file` | `app/lib/main.dart` |
| `Image Import Service` | `HEIC/HEIF Import Conversion Flow` | `Convert HEIC/HEIF to preview-capped temporary PNG working copy with fallback + temp cleanup` | `app/lib/features/import/services/image_import_service.dart` |
| `Canvas Image View` | `Photo Canvas Area` | `Render selected photo with BoxFit.contain` | `app/lib/main.dart` |
| `Touch Toolbar` | `Photo Markup Shell` | `Expose tool actions with selected/disabled state` | `app/lib/main.dart` |
| `Dimension Overlay` | `Dimension Overlay Layer` | `Render and capture dimension line interactions` | `app/lib/features/markup/widgets/dimension_lines_overlay.dart` |
| `Dimension Model` | `Dimension Overlay Layer` | `Store start/end coordinates for each line` | `app/lib/features/markup/models/dimension_line.dart` |
| `Text Note Model` | `Text Note Overlay Layer` | `Store normalized anchor + text for each note` | `app/lib/features/markup/models/text_note_markup.dart` |
| `Text Note Dialog` | `Text Note Dialog` | `Collect standalone note text with Save/Skip` | `app/lib/main.dart` |
| `Move Utility` | `Selected Markup Move/Adjust Action` | `Clamp/apply whole-markup movement inside displayed image bounds` | `app/lib/features/markup/utils/markup_move_utils.dart` |
| `Oval Model` | `Circle/Oval Overlay Layer` | `Store start/end coordinates for each oval` | `app/lib/features/markup/models/oval_markup.dart` |
| `Dimension Label Dialog` | `Dimension Label Dialog` | `Collect manual label text with Save/Skip` | `app/lib/main.dart` |
| `Dimension Label Formatter` | `Dimension Label Dialog` | `Normalize common feet/inches inputs` | `app/lib/features/markup/utils/dimension_label_formatter.dart` |
| `Export Service` | `Export / Save Dialog` | `Capture marked canvas and write PNG bytes` | `app/lib/features/export/services/marked_up_image_export_service.dart` |
| `Export Path Service` | `Export / Save Dialog` | `Resolve default name/folder and duplicate-safe export path` | `app/lib/features/export/services/markup_export_path_service.dart` |
| `Unsaved Changes Tracker` | `Unsaved Changes Guard Dialog` | `Track dirty/saved state for guard prompts` | `app/lib/features/markup/utils/unsaved_changes_tracker.dart` |

## Phase 1D Review Note
- Dimension label entry/edit behavior is implemented on top of existing dimension overlay.
- Non-dimension tools remain placeholders in this phase.
- Icon quality refinement in this pass changed branding assets only (no form flow changes).
- Taskbar icon variant pass changed only branding image assets and Windows icon packaging (no form flow changes).
- Approved-design icon correction pass also changed only branding image assets and Windows icon packaging (no form flow changes).


