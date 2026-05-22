# Form Definitions

Document Path: `C:\apps\NCD_Photo_Markup\FORM_DEFINITIONS.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Define app forms/screens and responsibilities.
Changes: Added implemented Phase 1A shell screen entry.

## Primary Forms/Screens
- `Photo Markup Shell` (implemented)
- `Photo Markup Workspace` (placeholder canvas region in shell)
- `Export / Save Dialog` (planned)

## Field Work Forms
### `Shell` Forms

#### `Photo Markup Shell`
- Source path: `app/lib/main.dart`
- Purpose: `Provide top-level shell with app bar, canvas placeholder, and bottom touch toolbar placeholders`
- Parent/master form: `Root app`
- Child components:
- `Canvas placeholder panel`
- `Horizontal touch toolbar`
- Related widgets/components:
- `_ToolbarPlaceholderButton`
- Related services:
- `None in Phase 1A`
- Data sources:
- `None in Phase 1A`
- Route/name:
- `home`
- Read/write behavior: `READ_ONLY`
- Notes:
- `No markup behavior implemented yet`

#### `Photo Markup Workspace (Placeholder)`
- Source path: `app/lib/main.dart`
- Purpose: `Display empty-state message and reserved area for future photo/canvas`
- Parent/master form: `Photo Markup Shell`
- Child components:
- `Empty-state icon`
- `Placeholder text`
- Read/write behavior: `READ_ONLY`
- Notes:
- `Message: Open or import a photo to start marking it up.`

## Dependency/Component Map
| Name | Form | Purpose | Path |
|---|---|---|---|
| `App Bar` | `Photo Markup Shell` | `Show app name and version` | `app/lib/main.dart` |
| `Canvas Placeholder` | `Photo Markup Workspace` | `Reserve future photo/markup area` | `app/lib/main.dart` |
| `Touch Toolbar` | `Photo Markup Shell` | `Expose tool/action placeholders` | `app/lib/main.dart` |
