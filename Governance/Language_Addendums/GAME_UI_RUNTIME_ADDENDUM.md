# Game UI Runtime Addendum

Document Path: `<PRIMARY_PATH>/Governance/Language_Addendums/GAME_UI_RUNTIME_ADDENDUM.md`
Version: `<VERSION>`
Pack File Version: `v1.3`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Optional runtime and validation rules for games, map-based apps, canvas apps, and sprite-based UI.
Changes: Initial v1.3 addendum.

## Quick Rules
- Use one source-of-truth coordinate system for map/canvas gameplay.
- Do not mix raw screen coordinates, image pixels, and normalized map coordinates without a documented conversion layer.
- Visual/gameplay changes require screenshot evidence, not just build/runtime proof.
- Responsive resizing must preserve required content visibility and coordinate alignment.
- Debug overlays must align with the visible game/map scene.

## Game Coordinate System Rule
For map-based games, the app must define one source-of-truth coordinate system.

Background image, gameplay route, enemies, towers, projectiles, placement zones, hitboxes, and debug overlays must all use the same map-to-screen transform.

Recommended pattern:
- store gameplay coordinates as normalized map coordinates from `0.0` to `1.0`
- compute the rendered map rectangle after applying contain-fit, letterbox, or documented scaling
- convert all gameplay points through the same `mapToScreen()` transform
- recalculate positions when the window size changes

## Validation Requirements
Game/map/canvas changes must validate:
- debug overlay route lines up with the visible road/path
- enemies or moving entities travel on the visible route
- tower/placement zones match valid visual areas
- hitboxes align with rendered objects
- HUD and controls remain visible and usable
- resizing does not break map alignment or object placement

## Visual Evidence Requirements
When a task affects visuals or gameplay alignment, provide:
- normal player-view screenshot
- debug-overlay screenshot when overlays exist
- responsive screenshot in a normal non-fullscreen window when resize behavior matters
- pass/fail comparison against the task acceptance criteria

## Verification Gate
- [ ] One coordinate system is documented.
- [ ] Map-to-screen transform is documented when needed.
- [ ] Debug overlay aligns with rendered map/canvas.
- [ ] Runtime positions and visual positions match.
- [ ] Responsive resize behavior is validated where applicable.
- [ ] Screenshot evidence is recorded.

