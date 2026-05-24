# UI Standards

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\UI_STANDARDS.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-24`
Purpose: Define baseline UI standards for NCD Photo Markup.
Changes: Added Phase 1J image import copy/file-type standards for HEIC/HEIF handling.

## Visual Direction
- Prioritize touch-first control sizing and spacing.
- Keep markup tools clear, discoverable, and separated.
- Keep UI minimal during field use; avoid clutter.

## Foundations
- Primary brand color: `#009ADA` (NCD Blue)
- Neutral surface for tool strips: `#F2FAFE`
- Typography: `Default Flutter Material typography for now`
- Touch target minimum: `56px` height for primary toolbar buttons
- Component reuse: `Use shared toolbar action button pattern with selected/disabled states`
- Dimension line color baseline: `#005C85`
- Dimension stroke baseline: `3px` with endpoint markers
- Arrow color baseline: `#006B3F` with visible arrowhead
- Arrow stroke baseline: `3.2px` with selected-state stroke multiplier
- Rectangle outline baseline: `#7A4B00` with transparent fill
- Rectangle stroke baseline: `3px` with selected-state stroke multiplier
- Circle/Oval outline baseline: `#8B1E00` with transparent fill
- Circle/Oval stroke baseline: `3px` with selected-state stroke multiplier
- Dimension label chips: high-contrast text with semi-opaque light background and border
- Dimension label entry: touch-friendly dialog with explicit Save/Skip actions
- Dimension label entry should also support Enter/Done keyboard submit for fast field entry on desktop tablets.
- Selected markup state must be visually obvious (stroke color/weight contrast from non-selected lines).
- Erase interaction must be safe: no-selection click should be gentle guidance, never crash.
- Startup splash and app-bar icon should use app-local branding assets, not doc-folder runtime paths.
- Startup splash should visually occupy most of the launch window while keeping full image visible (`BoxFit.contain`).
- Import picker/file-type scope should list all currently supported image formats (`jpg/jpeg/png/webp/heic/heif`).
- HEIC/HEIF conversion failures should use field-safe, non-technical guidance copy.

## Accessibility/Usability
- Large tap targets for tablet use.
- High contrast between action color and content surfaces.
- Keep the empty state explicit and safe.
- Selected tool state must remain visually distinguishable for field use.

## Governance Notes
- Do not hard-code business label presets; use configurable presets/favorites later.
- Keep future Control Center integration behind a separate adapter/service.

## Phase 1C Review Note
- Added selected-state styling pattern for tool buttons.
- Added baseline visual pattern for dimension lines and endpoint markers.
- Added pattern rule: overlay drawings must remain inside displayed image bounds.
- Other tool visuals remain placeholders.



