# UI Standards Selection Form

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\UI_STANDARDS_SELECTION_FORM.md`
Version: `v0.5`
Pack File Version: `v1.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-27`
Purpose: Owner-selection form for finalizing enforced UI standards.
Changes: Added Phase 1R note to keep Save/Open Markup as explicit user-triggered actions with predictable naming defaults.

## Purpose
Use this form to select baseline UI standards before broad UI modernization.

## Status
Completed baseline selection for current phase. Owner can revise selections later.
- Phase 1R addendum: `Open Markup` and `Save Markup` remain explicit manual actions; no autosave or auto-export behavior is part of this UI pattern.

## 1. Color System Approval
Brand/accent color:
- [x] Use `#009ADA` as primary accent.
- [x] Use brand color only for headers/highlights, not every button.
- [ ] Needs adjustment.

Background:
- [ ] Light neutral background.
- [x] Slight blue-gray background.
- [ ] White app background.
- [ ] Other.

Cards:
- [x] White cards with soft border.
- [ ] Light gray cards.
- [ ] Subtle shadow.
- [ ] Border only, no shadow.

Status colors:
- [x] Use recommended success/warning/error palette.
- [ ] Softer status colors.
- [ ] Stronger status colors.
- [ ] Needs owner review.

## 2. Typography Approval
- [x] Use current system/default font.
- [ ] Use platform-style system font.
- [ ] Use a more modern professional font if available.
- [ ] Needs font review.

## 3. Spacing Scale Approval
- [x] Use `4 / 8 / 12 / 16 / 20 / 24 / 32`.
- [ ] More compact spacing.
- [ ] More spacious spacing.
- [ ] Different scale.

## 4. Border Radius Approval
- [x] Small `8`, Medium `12`, Large card `16`, Dialog `20`.
- [ ] More rounded.
- [ ] Less rounded.
- [ ] Needs visual examples.

## 5. Card Style Approval
- [x] Rounded cards with soft border.
- [ ] Rounded cards with subtle shadow.
- [ ] Compact cards.
- [x] Spacious cards.
- [ ] Dashboard cards should be smaller/denser.
- [ ] Dashboard cards may be larger for high-level info.

## 6. Button Style Approval
- [x] Primary button uses brand color.
- [x] Secondary button is outline/neutral.
- [x] Destructive button uses error color.
- [ ] Buttons should be compact.
- [x] Buttons should have more padding.
- [ ] Icons allowed in buttons when useful.

## 7. Form Field Style Approval
- [x] Rounded fields.
- [x] Soft border.
- [x] Clear focus outline.
- [ ] Compact field height.
- [x] Larger field height for touch/tablet use.
- [x] Helper/error text below fields.

## 8. Dropdown / Checkbox Style Approval
- [x] Match text field style.
- [ ] Compact dropdowns.
- [x] Larger touch-friendly dropdowns.
- [x] Standard checkbox label alignment.
- [ ] Needs visual examples.

## 9. Table / List Style Approval
- [ ] Compact desktop rows.
- [x] More spacious rows.
- [ ] Alternating row background.
- [x] Hover highlight.
- [x] Selected row accent.
- [ ] Sticky headers where practical.

## 10. Dialog Style Approval
- [x] Rounded dialog corners.
- [x] Clear title/header.
- [x] Actions bottom-right.
- [x] Larger content padding.
- [ ] Compact content padding.
- [x] Avoid oversized dialogs.

## 11. Navigation Style Approval
- [x] Keep current top navigation for now.
- [ ] Future left navigation rail/sidebar.
- [ ] Hybrid: top commands plus left navigation.
- [ ] Needs separate navigation review.

## 12. Dashboard Layout Approval
- [ ] Compact cards.
- [x] 2-3 column responsive layout.
- [x] No oversized dashboard tiles.
- [x] Focus on actionable items first.
- [x] Separate read-only summaries from actions.

## 13. Empty / Error / Loading States
- [x] Calm empty states with icon and short message.
- [x] Clear error states with retry/action.
- [x] Loading spinners only where needed.
- [ ] Skeleton/loading cards if practical later.

## 14. Responsive Behavior Approval
- [x] Use full screen width wisely.
- [x] Cards wrap into columns on wide screens.
- [x] Stack cleanly on narrow windows.
- [x] Avoid giant empty right-side space.
- [x] Avoid horizontal overflow.
- [x] Preserve usability without maximizing app.

## 15. Accessibility Approval
- [x] Require visible focus state.
- [x] Require readable contrast.
- [x] Avoid color-only status meaning.
- [x] Use clear labels/tooltips.
- [x] Keep click targets large enough.

## 16. Agent Enforcement Rules
- [x] Agents must use shared UI tokens/components first.
- [x] Agents must not create one-off local styles without approval.
- [x] UI commits must be separate from business logic commits.
- [x] Agents must update UI standards when owner approves a new pattern.
- [x] Agents must not mix UI modernization with active feature/business fixes unless approved.
- [x] Agents must run static analysis.
- [x] Agents must capture screenshots when visual QA is requested.
- [x] Agents must stop/report if shared token/component structure is insufficient.

## 17. Final Approval
Approved by: `NCD / M`
Date: `2026-05-22`
Approved Version: `v0.5`
Notes: `Baseline selections applied for Windows-first workflow; can be revised before broad UI modernization.`

## 18. Open Questions
- Exact font: `Open (defer until broader UI pass)`
- Neutral palette: `Use current light blue-gray baseline`
- Card density: `Spacious for tablet`
- Dashboard density: `Open (future dashboard work)`
- Navigation direction: `Top navigation for now`
- Sidebar icon pack production default: `Resolved (NCD custom icon pack approved as production standard in Phase 1U-B)`
- Button sizing: `Touch-friendly padding`
- Radius scale: `Approved baseline`

## Verification Gate
- [x] Owner selections are complete.
- [x] Open questions are recorded.
- [x] Approved selections are reflected in UI standards.
- [x] Enforcement status is clear.
