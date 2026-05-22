# UI Standards Selection Form Template

Document Path: `<PRIMARY_PATH>/Templates/UI_Module/UI_STANDARDS_SELECTION_FORM_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Provide a reusable owner approval form for selecting final UI/design-system standards before enforcement.
Changes: Added v1.5 UI standards selection form template.

## Purpose
Use this form to let the product owner select or approve final UI standards before agents enforce or implement broad UI modernization.

## Status
Draft / Selection Form until approved.

## Instructions for Owner
Check one or more options in each section. If unsure, select `Use recommended default` and add a note.

## 1. Color System Approval
Brand/accent color:
- [ ] Use `<BRAND_COLOR_HEX>` as primary accent.
- [ ] Use brand color only for headers/highlights, not every button.
- [ ] Needs adjustment: `<NOTES>`

Background:
- [ ] Light neutral background.
- [ ] Slight blue-gray background.
- [ ] White app background.
- [ ] Other: `<NOTES>`

Cards:
- [ ] White cards with soft border.
- [ ] Light gray cards.
- [ ] Subtle shadow.
- [ ] Border only, no shadow.

Status colors:
- [ ] Use recommended success/warning/error palette.
- [ ] Softer status colors.
- [ ] Stronger status colors.
- [ ] Needs owner review.

## 2. Typography Approval
- [ ] Use current system/default font.
- [ ] Use platform-style system font.
- [ ] Use a more modern professional font if available.
- [ ] Needs font review.

## 3. Spacing Scale Approval
- [ ] Use `4 / 8 / 12 / 16 / 20 / 24 / 32`.
- [ ] More compact spacing.
- [ ] More spacious spacing.
- [ ] Different scale: `<NOTES>`

## 4. Border Radius Approval
- [ ] Small `8`, Medium `12`, Large card `16`, Dialog `20`.
- [ ] More rounded.
- [ ] Less rounded.
- [ ] Needs visual examples.

## 5. Card Style Approval
- [ ] Rounded cards with soft border.
- [ ] Rounded cards with subtle shadow.
- [ ] Compact cards.
- [ ] Spacious cards.
- [ ] Dashboard cards should be smaller/denser.
- [ ] Dashboard cards may be larger for high-level info.

## 6. Button Style Approval
- [ ] Primary button uses brand color.
- [ ] Secondary button is outline/neutral.
- [ ] Destructive button uses error color.
- [ ] Buttons should be compact.
- [ ] Buttons should have more padding.
- [ ] Icons allowed in buttons when useful.

## 7. Form Field Style Approval
- [ ] Rounded fields.
- [ ] Soft border.
- [ ] Clear focus outline.
- [ ] Compact field height.
- [ ] Larger field height for touch/tablet use.
- [ ] Helper/error text below fields.

## 8. Dropdown / Checkbox Style Approval
- [ ] Match text field style.
- [ ] Compact dropdowns.
- [ ] Larger touch-friendly dropdowns.
- [ ] Standard checkbox label alignment.
- [ ] Needs visual examples.

## 9. Table / List Style Approval
- [ ] Compact desktop rows.
- [ ] More spacious rows.
- [ ] Alternating row background.
- [ ] Hover highlight.
- [ ] Selected row accent.
- [ ] Sticky headers where practical.

## 10. Dialog Style Approval
- [ ] Rounded dialog corners.
- [ ] Clear title/header.
- [ ] Actions bottom-right.
- [ ] Larger content padding.
- [ ] Compact content padding.
- [ ] Avoid oversized dialogs.

## 11. Navigation Style Approval
- [ ] Keep current top navigation for now.
- [ ] Future left navigation rail/sidebar.
- [ ] Hybrid: top commands plus left navigation.
- [ ] Needs separate navigation review.

## 12. Dashboard Layout Approval
- [ ] Compact cards.
- [ ] 2-3 column responsive layout.
- [ ] No oversized dashboard tiles.
- [ ] Focus on actionable items first.
- [ ] Separate read-only summaries from actions.

## 13. Empty / Error / Loading States
- [ ] Calm empty states with icon and short message.
- [ ] Clear error states with retry/action.
- [ ] Loading spinners only where needed.
- [ ] Skeleton/loading cards if practical later.

## 14. Responsive Behavior Approval
- [ ] Use full screen width wisely.
- [ ] Cards wrap into columns on wide screens.
- [ ] Stack cleanly on narrow windows.
- [ ] Avoid giant empty right-side space.
- [ ] Avoid horizontal overflow.
- [ ] Preserve usability without maximizing app.

## 15. Accessibility Approval
- [ ] Require visible focus state.
- [ ] Require readable contrast.
- [ ] Avoid color-only status meaning.
- [ ] Use clear labels/tooltips.
- [ ] Keep click targets large enough.

## 16. Agent Enforcement Rules
- [ ] Agents must use shared UI tokens/components first.
- [ ] Agents must not create one-off local styles without approval.
- [ ] UI commits must be separate from business logic commits.
- [ ] Agents must update UI standards when owner approves a new pattern.
- [ ] Agents must not mix UI modernization with active feature/business fixes unless approved.
- [ ] Agents must run static analysis.
- [ ] Agents must capture screenshots when visual QA is requested.
- [ ] Agents must stop/report if shared token/component structure is insufficient.

## 17. Final Approval
Approved by: `<OWNER>`
Date: `<DATE_YYYY-MM-DD>`
Approved version: `<VERSION>`
Notes: `<NOTES>`

## 18. Open Questions
- Exact font: `<ANSWER_OR_OPEN>`
- Neutral palette: `<ANSWER_OR_OPEN>`
- Card density: `<ANSWER_OR_OPEN>`
- Dashboard density: `<ANSWER_OR_OPEN>`
- Navigation direction: `<ANSWER_OR_OPEN>`
- Button sizing: `<ANSWER_OR_OPEN>`
- Radius scale: `<ANSWER_OR_OPEN>`

## Verification Gate
- [ ] Owner selections are complete.
- [ ] Open questions are recorded.
- [ ] Approved selections are reflected in UI standards.
- [ ] Enforcement status is clear.
