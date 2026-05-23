# Responsive Layout Validation Template

Document Path: `<PRIMARY_PATH>/Operations/RESPONSIVE_LAYOUT_VALIDATION_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.3`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Record resize, screen scaling, desktop window, canvas, map, HUD, and responsive layout validation evidence.
Changes: Initial v1.3 template.

## Quick Rules
- Use this template when layout, map scaling, canvas/game rendering, HUD positioning, or desktop window behavior changes.
- Validate more than one size.
- Confirm required content is visible and usable.
- For games/maps/canvas apps, confirm gameplay coordinates still match the rendered scene.

## Required Contract
| State | Size / Mode | Screenshot Evidence | Required Content Visible | Controls Usable | Alignment Correct | Result |
|---|---|---|---|---|---|---|
| Fullscreen/maximized | `<SIZE_OR_MODE>` | `<PATH>` | `<YES|NO>` | `<YES|NO>` | `<YES|NO|N/A>` | `<PASS|FAIL>` |
| Normal window | `<SIZE_OR_MODE>` | `<PATH>` | `<YES|NO>` | `<YES|NO>` | `<YES|NO|N/A>` | `<PASS|FAIL>` |
| Smaller resized window | `<SIZE_OR_MODE>` | `<PATH>` | `<YES|NO>` | `<YES|NO>` | `<YES|NO|N/A>` | `<PASS|FAIL>` |

## Expected Scaling Strategy
- Strategy: `<CONTAIN_FIT|LETTERBOX|RESPONSIVE_REFLOW|INTENTIONAL_CROP|OTHER>`
- Minimum size: `<WIDTH_X_HEIGHT_OR_N/A>`
- Intentional cropping allowed: `<YES|NO>`
- Notes: `<DETAILS>`

## Verification Gate
- [ ] Fullscreen/maximized state checked.
- [ ] Normal non-fullscreen state checked.
- [ ] Smaller resized state checked.
- [ ] Required content is not unintentionally cropped.
- [ ] Primary controls remain visible and usable.
- [ ] Gameplay/map/canvas alignment remains correct where applicable.

