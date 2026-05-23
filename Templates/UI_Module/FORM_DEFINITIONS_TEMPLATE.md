# Form Definitions Template

Document Path: `<PRIMARY_PATH>/Templates/UI_Module/FORM_DEFINITIONS_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Map Dart/forms/screens and form-level architecture without becoming a noisy inventory of every source file.
Changes: Added v1.5 form definitions template.

## Purpose
This document is the governed map for app forms/screens and form-level architecture.

It is not intended to list every source file in the app. Major shared widgets, services, and data sources should be referenced under the related form/screen entry.

## Documentation Rule
Every new or significantly changed form/screen must be added or updated here with:
- form/screen name
- source path
- purpose
- parent/master form
- child forms/components
- related shared widgets
- related services
- related data sources
- routes/navigation entry points
- notes/TODOs

## Main Form Index
- `<FORM_OR_SCREEN_NAME>`
- `<FORM_OR_SCREEN_NAME>`

## Form Definitions

### `<AREA_NAME>` Forms

#### `<FORM_OR_SCREEN_NAME>`
- Source path: `<PATH>`
- Purpose: `<PURPOSE>`
- Parent/master form: `<PARENT_OR_NONE>`
- Children/components:
  - `<CHILD_OR_COMPONENT>`
- Related shared widgets:
  - `<WIDGET_PATH_OR_NAME>`
- Related services:
  - `<SERVICE_PATH_OR_NAME>`
- Related data:
  - `<DATA_SOURCE_OR_FILE>`
- Routes/navigation:
  - `<ROUTE_NAME_OR_PATH>`
- Read/write behavior: `<READ_ONLY|EDITABLE|WORKFLOW_ACTION|MIXED>`
- Notes/TODOs:
  - `<NOTE>`

##### `<CHILD_SECTION_OR_TAB>`
- Source path: `<PATH_OR_PARENT_FILE>`
- Purpose: `<PURPOSE>`
- Parent/master form: `<PARENT>`
- Children/components:
  - `<CHILD_OR_COMPONENT>`
- Related services:
  - `<SERVICE>`
- Related data:
  - `<DATA_SOURCE>`
- Notes/TODOs:
  - `<NOTE>`

## Shared Components Referenced By Forms
Use this section only for major shared widgets/services that are part of form behavior. Do not list every helper file.

| Component/Service | Used By | Purpose | Source Path |
|---|---|---|---|
| `<NAME>` | `<FORM>` | `<PURPOSE>` | `<PATH>` |

## Verification Gate
- [ ] Every new/significantly changed form is documented.
- [ ] Parent/child relationships are clear.
- [ ] Related services and data sources are listed.
- [ ] Routes/navigation entries are listed.
- [ ] This document has not become an all-file inventory.

