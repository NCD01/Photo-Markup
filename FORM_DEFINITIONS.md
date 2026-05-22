# Form Definitions

Document Path: `C:\apps\NCD_Photo_Markup\FORM_DEFINITIONS.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Define app forms/screens and their responsibilities.
Changes: Added initial draft of planned screens/components.

## Primary Forms/Screens
- `Home / Project Picker (planned)`
- `Photo Markup Workspace (planned)`
- `Export / Save Dialog (planned)`

## Field Work Forms
### `Workspace` Forms

#### `Photo Markup Workspace`
- Source path: `lib/ui/workspace (planned)`
- Purpose: `Display photo, tool palette, and annotation canvas`
- Parent/master form: `Root app shell`
- Child components:
- `Tool palette`
- `Canvas overlay`
- Related widgets/components:
- `Dimension line tool`
- `Arrow tool`
- Related services:
- `Markup persistence service (planned)`
- Data sources:
- `Editable markup file set (planned)`
- Route/name:
- `workspace`
- Read/write behavior: `MIXED`
- Notes:
- `Original photo remains untouched; markup stored separately`

## Dependency/Component Map
| Name | Form | Purpose | Path |
|---|---|---|---|
| `Tool Palette` | `Photo Markup Workspace` | `Tool selection and actions` | `lib/ui/workspace/widgets (planned)` |
| `Canvas Overlay` | `Photo Markup Workspace` | `Render/edit markups` | `lib/ui/workspace/canvas (planned)` |
