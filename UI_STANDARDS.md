# UI Standards

Document Path: `C:\apps\NCD_Photo_Markup\UI_STANDARDS.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Define baseline UI standards for NCD Photo Markup.
Changes: Created initial draft for touch-first Windows-first UI direction.

## Visual Direction
- Prioritize touch-first control sizing and spacing.
- Keep markup tools clear, discoverable, and separated (Dimension Line and Arrow are distinct tools).
- Keep UI minimal during field use; avoid clutter.

## Foundations
- Brand color: `#1F4E79`
- Typography: `To be finalized in implementation phase`
- Spacing/size tokens: `To be defined in Flutter theme/tokens layer`
- Component reuse: `Required for shared toolbar/tool controls`

## Accessibility/Usability
- Large tap targets for tablet use.
- High contrast for outdoor/field readability.
- Clear mode labeling for internal/client visibility states.

## Governance Notes
- Do not hard-code business label presets; use configurable presets/favorites.
- Keep future Control Center integration behind a separate adapter/service.
