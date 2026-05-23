# UI Standards Template

Document Path: `<PRIMARY_PATH>/Templates/UI_Module/UI_STANDARDS_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Provide a governed UI/design-system standards template for apps before broad UI modernization.
Changes: Added v1.5 UI standards template based on Control Center UI modernization governance.

## Status
Draft / Proposed until the product owner approves enforcement.

## Quick Rules
- Define shared UI standards before broad screen redesigns.
- Use shared tokens and shared components first.
- Do not create one-off local styles unless approved.
- Do not mix UI modernization with business-logic fixes unless approved.
- Keep UI-only commits separate from business-logic, data, and documentation commits.
- Update this document when a new approved visual pattern is introduced.

## Required Contract
This standards document must define:

### 1. Color System
- Brand color: `<BRAND_COLOR_HEX>`
- Background colors
- Card/surface colors
- Border colors
- Primary/secondary/muted text colors
- Error, warning, success, disabled, hover, and focus states

### 2. Typography
- Default font family
- Page title size
- Section header size
- Card title size
- Body text size
- Helper text size
- Button text style
- Table/list text style

### 3. Spacing Scale
Recommended starter scale:
- `4`
- `8`
- `12`
- `16`
- `20`
- `24`
- `32`

Document where each spacing value is used.

### 4. Border Radius
Recommended starter scale:
- Small: `8`
- Medium: `12`
- Large card: `16`
- Dialog: `20`

### 5. Component Standards
Define standard look and behavior for:
- cards
- buttons
- text fields
- dropdowns
- checkboxes
- tables/lists
- toolbars
- search boxes
- dialogs
- side panels
- navigation items
- empty states
- error states
- loading states

### 6. Screen Layout Rules
- No oversized dashboard tiles.
- Use available screen width wisely.
- Avoid cramped tables.
- Keep action buttons consistent.
- Keep read-only summaries separate from actions.
- Use responsive layouts.
- Use shared components/tokens first.
- Avoid one-off styling.

### 7. Responsive Layout Rules
Cover:
- wide desktop
- normal desktop
- narrow tablet/window
- wrapping behavior
- maximum card widths
- minimum usable pane widths
- avoiding giant empty right-side space
- avoiding overflow

### 8. Accessibility Basics
- readable contrast
- visible keyboard focus
- hover/focus states
- large enough click targets
- clear help/error text
- avoid relying only on color

### 9. Existing Implementation Source of Truth
List actual files after adoption:
- theme/token files
- shared input widgets
- shared grid/table widgets
- shared dialog widgets
- navigation/app shell widgets
- route files

Do not invent file paths. Inspect actual project files.

### 10. Agent Rules
- Agents must use shared tokens/components first.
- Agents must not create one-off local styles unless approved.
- Agents must update this UI standards document when an approved pattern is introduced.
- Agents must not mix UI modernization with business-logic fixes unless approved.
- Agents must keep UI-only commits separate from business-logic commits.
- Agents must run the project static analysis command.
- Agents must validate no layout overflow.
- Agents must capture screenshots for visual QA when requested.
- Agents must not place temp screenshots/assets in production folders.
- Agents must stop and report if shared tokens/components are insufficient.

### 11. Open Questions for Owner Approval
Track decisions such as:
- exact font family
- neutral color palette
- button sizing
- card density
- dashboard density
- navigation direction
- final radius scale

## Verification Gate
- [ ] Brand color and neutral palette are defined or marked for approval.
- [ ] Typography, spacing, and radius scales are defined.
- [ ] Component standards are documented.
- [ ] Source-of-truth implementation files are listed.
- [ ] Open questions are recorded.
- [ ] Agents are instructed not to hard-code one-off styles.

