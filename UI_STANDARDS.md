# UI Standards

Document Path: `C:\apps\NCD_Photo_Markup\UI_STANDARDS.md`
Version: `v0.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Define baseline UI standards for NCD Photo Markup.
Changes: Added Phase 1A shell token usage and touch-target baseline.

## Visual Direction
- Prioritize touch-first control sizing and spacing.
- Keep markup tools clear, discoverable, and separated.
- Keep UI minimal during field use; avoid clutter.

## Foundations
- Primary brand color: `#009ADA` (NCD Blue)
- Neutral surface for tool strips: `#F2FAFE`
- Typography: `Default Flutter Material typography for now`
- Touch target minimum: `56px` height for primary toolbar buttons
- Component reuse: `Use shared toolbar placeholder button pattern`

## Accessibility/Usability
- Large tap targets for tablet use.
- High contrast between action color and content surfaces.
- Keep the empty state explicit and safe.

## Governance Notes
- Do not hard-code business label presets; use configurable presets/favorites later.
- Keep future Control Center integration behind a separate adapter/service.


