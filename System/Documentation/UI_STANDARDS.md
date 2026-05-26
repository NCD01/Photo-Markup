# UI Standards

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\UI_STANDARDS.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-25`
Purpose: Define baseline UI standards for NCD Photo Markup.
Changes: Added Phase 1Q unsaved-guard dialog and export-default naming/location UI pattern notes.

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
- Style presets must be centralized and touch-selectable.
- Minimum MVP preset set: `NCD Blue`, `Red`, `Yellow`, `White`, `Black`.
- Preset changes should apply to new markups without recoloring existing markups unexpectedly.
- Dimension label chips: high-contrast text with semi-opaque light background and border
- Dimension label entry: touch-friendly dialog with explicit Save/Skip actions
- Dimension label entry should also support Enter/Done keyboard submit for fast field entry on desktop tablets.
- Selected markup state must be visually obvious (stroke color/weight contrast from non-selected lines).
- Erase interaction must be safe: no-selection click should be gentle guidance, never crash.
- Dragging a selected markup should move the whole markup with a movement threshold to avoid accidental tap/edit conflicts.
- Whole-markup move must remain clamped to the displayed image rectangle.
- Selected dimension/arrow should show endpoint handles for direct endpoint adjustment.
- Selected rectangle/oval should show corner handles for direct resize adjustment.
- Handle priority should be: handle drag first, then whole-markup move, then normal selection/tap behavior.
- Advanced handle work beyond endpoint/corner MVP (freehand point editing, text-note resize, rotation) remains deferred.
- Startup splash and app-bar icon should use app-local branding assets, not doc-folder runtime paths.
- Startup splash should visually occupy most of the launch window while keeping full image visible (`BoxFit.contain`).
- Import picker/file-type scope should list all currently supported image formats (`jpg/jpeg/png/webp/heic/heif`).
- HEIC/HEIF conversion failures should use field-safe, non-technical guidance copy.
- Optional launch context should render as a compact non-intrusive summary banner (client/project/source) and must not block normal standalone workflow.
- Unsaved-change guard prompts should use clear action hierarchy: `Export` (primary), `Discard`, `Cancel`.
- Export save defaults should prioritize predictable naming/location (`OriginalName - Markup.png` in source/suggested folder) while keeping export user-triggered only.

## Accessibility/Usability
- Large tap targets for tablet use.
- High contrast between action color and content surfaces.
- Keep the empty state explicit and safe.
- Selected tool state must remain visually distinguishable for field use.
- Text-note chip style should prioritize readability/contrast on varied photos.

## Governance Notes
- Do not hard-code business label presets; use configurable presets/favorites later.
- Keep advanced styling (custom picker/per-tool editor/saved defaults) deferred until explicitly approved.
- Keep future Control Center integration behind a separate adapter/service.

## Phase 1C Review Note
- Added selected-state styling pattern for tool buttons.
- Added baseline visual pattern for dimension lines and endpoint markers.
- Added pattern rule: overlay drawings must remain inside displayed image bounds.
- Other tool visuals remain placeholders.



