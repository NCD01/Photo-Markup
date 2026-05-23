# Form Definitions

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\FORM_DEFINITIONS.md`
Version: `v0.4`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Define app forms/screens and responsibilities.
Changes: Added Phase 1C startup-window maximize behavior and final larger splash scaling note.

## Primary Forms/Screens
- `Photo Markup Shell` (implemented)
- `Photo Canvas Area` (implemented with image display)
- `Dimension Overlay Layer` (implemented)
- `Export / Save Dialog` (planned)

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
- `Startup splash uses approved v1.5 asset with centralized duration (2200 ms)`
- `Startup splash image is scaled to fill most of startup screen`
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

## Phase 1C Review Note
- Dimension overlay behavior is implemented as an additive layer above image rendering.
- Non-dimension tools remain placeholders in this phase.


