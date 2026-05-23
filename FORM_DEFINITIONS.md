# Form Definitions

Document Path: `C:\apps\NCD_Photo_Markup\FORM_DEFINITIONS.md`
Version: `v0.2`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Define app forms/screens and responsibilities.
Changes: Added Phase 1B image import behavior details.

## Primary Forms/Screens
- `Photo Markup Shell` (implemented)
- `Photo Canvas Area` (implemented with image display)
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
- Related widgets/components:
- `_ToolbarPlaceholderButton`
- Related services:
- `file_selector picker integration`
- Data sources:
- `Runtime-selected local image path`
- Route/name:
- `home`
- Read/write behavior: `MIXED`
- Notes:
- `Only Open Photo is functional in this phase`

#### `Photo Canvas Area`
- Source path: `app/lib/main.dart`
- Purpose: `Display empty state or selected image using contain-fit`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Empty-state icon/text`
- `Image display pane`
- `Loaded filename indicator`
- Read/write behavior: `READ_ONLY`
- Notes:
- `Original image is not copied or modified`
- `Shows safe error message if image cannot be opened`

## Dependency/Component Map
| Name | Form | Purpose | Path |
|---|---|---|---|
| `App Bar` | `Photo Markup Shell` | `Show app name and version` | `app/lib/main.dart` |
| `Open Photo Action` | `Photo Markup Shell` | `Launch picker and request image file` | `app/lib/main.dart` |
| `Canvas Image View` | `Photo Canvas Area` | `Render selected photo with BoxFit.contain` | `app/lib/main.dart` |
| `Touch Toolbar` | `Photo Markup Shell` | `Expose tool/action placeholders` | `app/lib/main.dart` |
