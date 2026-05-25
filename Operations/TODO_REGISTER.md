# TODO Register

Document Path: `C:\apps\NCD_Photo_Markup\Operations\TODO_REGISTER.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-25`
Purpose: Track planned and in-progress work items.
Changes: Updated for Phase 1O markup color/stroke presets MVP completion and advanced style follow-up split.

## Quick Rules
- Keep IDs stable.
- Update status and evidence when work changes.

## TODO Items
| ID | Area | Item | Priority | Owner | Status | Related Decision | Target Date |
|---|---|---|---|---|---|---|---|
| `TODO-001` | `Bootstrap` | `Finalize Phase 0 governance baseline` | `High` | `NCD / M` | `Done` | `DECISION-001` | `2026-05-22` |
| `TODO-002` | `Flutter Setup` | `Create Flutter app shell (no feature tooling yet)` | `High` | `NCD / M` | `Done` | `DECISION-002` | `2026-05-22` |
| `TODO-003` | `MVP Tools` | `Implement Dimension Line and Arrow as separate tools` | `High` | `NCD / M` | `In Progress` | `DECISION-005` | `N/A` |
| `TODO-004` | `Image Import` | `Implement Open Photo import to canvas with safe error handling` | `High` | `NCD / M` | `Done` | `N/A` | `2026-05-22` |
| `TODO-005` | `Manual QA` | `Owner-side interactive picker validation (cancel/select JPG/PNG)` | `Medium` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-006` | `Structure` | `Phase 1A.1 lean-root cleanup + governance sync (no app behavior changes)` | `High` | `NCD / M` | `Done` | `DECISION-003` | `2026-05-22` |
| `TODO-007` | `Governance` | `Adopt tunable constants standard in Flutter shell and governance docs` | `High` | `NCD / M` | `Done` | `DECISION-004` | `2026-05-22` |
| `TODO-008` | `Governance` | `Reconcile governance source metadata mismatch (requested v1.7 vs source VERSION v1.8)` | `Medium` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-009` | `Manual QA` | `Owner-side interactive validation for Phase 1C dimension draw + undo workflow` | `High` | `NCD / M` | `Done` | `N/A` | `2026-05-22` |
| `TODO-010` | `Branding` | `Complete Windows executable icon packaging from approved v1.5 icon asset (.ico pipeline), if owner wants platform icon replacement` | `Medium` | `NCD / M` | `Done` | `DECISION-006` | `2026-05-22` |
| `TODO-011` | `Input` | `Evaluate low-risk voice-to-text option for dimension labels` | `Medium` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-012` | `Measurement` | `Assess broader feet/inches parsing rules beyond lightweight Phase 1D formatter` | `Medium` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-013` | `Branding` | `Create and use transparent v1.5-derived icon source for Windows .ico regeneration` | `High` | `NCD / M` | `Done` | `DECISION-008` | `2026-05-23` |
| `TODO-014` | `Branding` | `Future Icon Standard / Taskbar Icon Redesign` | `Medium` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-015` | `Export` | `Add full-resolution marked-image export path (not current viewport resolution)` | `Medium` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-016` | `Export` | `Evaluate optional PDF export workflow after PNG MVP is validated` | `Low` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-017` | `Markup` | `Evaluate multi-select and bulk erase workflow (single-select only in Phase 1F)` | `Low` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-018` | `Markup` | `Evaluate optional arrow annotation/labels after Arrow MVP stabilizes` | `Low` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-019` | `Markup` | `Evaluate optional rectangle labels/annotations after Rectangle MVP stabilizes` | `Low` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-020` | `Markup` | `Evaluate optional circle/oval labels/annotations after Circle/Oval MVP stabilizes` | `Low` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-021` | `Import` | `Add broader HEIC/HEIF sample corpus and run owner-side Windows validation matrix for conversion success/failure variants` | `High` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-022` | `Import` | `Evaluate Windows-native HEIC decode fallback (codec/alternative package/service) after current sample conversion failure` | `High` | `NCD / M` | `Done` | `N/A` | `2026-05-24` |
| `TODO-023` | `Import` | `Package Windows HEIC fallback dependency strategy (verify ImageMagick availability or provide bundled converter guidance for deployments where magick is missing)` | `High` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-024` | `Markup` | `Evaluate optional freehand path simplification/smoothing for long strokes after MVP stability` | `Low` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-025` | `Markup` | `Implement Text Note Tool MVP (create/edit/select/delete/export)` | `Critical` | `NCD / M` | `Done` | `N/A` | `2026-05-25` |
| `TODO-026` | `Markup` | `Implement Move/Adjust Selected Markup MVP (whole-markup move for all current markup types)` | `Critical` | `NCD / M` | `Done` | `N/A` | `2026-05-25` |
| `TODO-027` | `Markup` | `Implement endpoint/resize handle editing MVP for dimension/arrow/rectangle/oval after move MVP stabilization` | `Critical` | `NCD / M` | `Done` | `N/A` | `2026-05-25` |
| `TODO-028` | `Markup` | `Evaluate advanced handle editing beyond Phase 1N (freehand point editing, text-note resize, rotation, edge handles)` | `Medium` | `NCD / M` | `Open` | `N/A` | `N/A` |
| `TODO-029` | `Markup` | `Evaluate advanced style controls beyond Phase 1O (custom color picker, per-tool style editor, optional saved user defaults)` | `Medium` | `NCD / M` | `Open` | `N/A` | `N/A` |

## Active Workstream Summary
| Order | Workstream | Item | Status | Dependency | Evidence |
|---|---|---|---|---|---|
| `1` | `Runtime` | `Phase 1B image import` | `Done` | `Validation run complete` | `Changelog v0.3 entry + phase1b screenshot` |
| `2` | `Manual QA` | `Interactive picker cancel/select validation` | `Open` | `Owner interactive pass` | `Pending` |
| `3` | `MVP Tools` | `Dimension/Arrow/Rectangle/Circle-Oval/Freehand/Text Note delivered; remaining advanced workflow items tracked in roadmap` | `In Progress` | `Owner validation and next-phase approval` | `Phase 1L code + tests complete` |
| `4` | `Structure` | `Lean-root + governance sync completion` | `Done` | `M-approved dirty-state continuation` | `Session + validation evidence` |
| `5` | `Governance` | `Tunable constants standard adoption` | `Done` | `Governance v1.7 effective update` | `Constants file + policy/addendum sync` |
| `6` | `Manual QA` | `Dimension line interactive field validation` | `Done` | `Owner Windows interactive run` | `Owner reported manual items 1-6 PASS + bounds fix PASS` |
| `7` | `Branding` | `Windows platform icon packaging follow-up` | `Done` | `Approved icon v1.5 source` | `app/windows/runner/resources/app_icon.ico replaced from approved asset` |
| `8` | `Branding` | `Taskbar icon visual readability redesign standard` | `Open` | `Future simplified icon standard approval` | `Tracked in TODO-014` |
| `9` | `Export` | `Viewport PNG export MVP shipped; full-resolution/PDF follow-up` | `Open` | `Owner approval for next export phase` | `Tracked in TODO-015/TODO-016` |
| `10` | `Markup` | `Single-select erase delivered; future multi-select/bulk erase follow-up` | `Open` | `Owner approval for expanded erase UX` | `Tracked in TODO-017` |
| `11` | `Markup` | `Arrow MVP delivered; optional arrow-label enhancement deferred` | `Open` | `Owner approval for annotation expansion` | `Tracked in TODO-018` |
| `12` | `Markup` | `Rectangle MVP delivered; optional rectangle-label enhancement deferred` | `Open` | `Owner approval for annotation expansion` | `Tracked in TODO-019` |
| `13` | `Markup` | `Circle/Oval MVP delivered; optional circle/oval-label enhancement deferred` | `Open` | `Owner approval for annotation expansion` | `Tracked in TODO-020` |
| `14` | `Import` | `HEIC/HEIF conversion path implemented with package + ImageMagick fallback; continue deployment hardening` | `Open` | `Windows fallback dependency availability` | `Tracked in TODO-021/TODO-023` |
| `15` | `Markup` | `Freehand MVP implemented; optional smoothing/path simplification tuning deferred` | `Open` | `Owner interactive validation + future tuning approval` | `Tracked in TODO-024` |
| `16` | `Markup` | `Move/Adjust + endpoint/resize handle MVP delivered for dimension/arrow/rectangle/oval` | `Done` | `N/A` | `Phase 1M+1N delivered` |
| `17` | `Markup` | `Advanced handle work (freehand points/text-note resize/rotation/edge handles)` | `Open` | `Owner approval for post-MVP advanced adjust UX` | `Tracked in TODO-028` |
| `18` | `Markup` | `Markup style preset MVP delivered for new markups + selected-markup restyle; advanced style controls deferred` | `Open` | `Owner approval for post-MVP style UX expansion` | `Tracked in TODO-029` |





## Roadmap Details
### Future Phase: Apple Compatibility and HEIC/HEIF Support
- Keep app architecture compatible with Apple platforms where practical.
- Plan for future iPad/iPhone support.
- Consider macOS compatibility if practical.
- HEIC/HEIF import support is now implemented in MVP; continue hardening with real-device sample validation and fallback coverage.
- Do not break the current Windows tablet workflow.
- Do not add unrelated Apple platform runtime integrations until approved.

### Future Phase: NCD Control Center Integration
- Keep current app standalone during MVP.
- Do not add Control Center dependency during MVP.
- Implement future integration behind isolated adapters/services.
- Support future open-from-client/project context workflow.
- Support future separate saves for original photo, editable markup file, client-facing export, and internal export.

### Future Icon Standard / Taskbar Icon Redesign
- Define a simplified taskbar-first icon standard for Windows small sizes.
- Require a transparent master source for packaging.
- Require vector or high-resolution source artwork for downscaling quality.
- Avoid tiny unreadable text at `16/24/32 px`.
- Verify alpha transparency and visual quality as separate validation gates.
- Document Windows icon cache troubleshooting steps for validation and owner QA.

## Post-MVP Priority Backlog
### Critical (Open)
1. Text Note Tool
- Status: `Done` (Phase 1L MVP complete).
- Added independent text notes (not tied to dimension lines), touch-friendly entry, render/export support, and select/edit/delete parity.
- Voice-to-text remains separate and deferred (see item 18).
2. Editable Markup Save / Reopen
- Save editable markup separately from exported PNG and reopen later with original image unchanged.
- Keep standalone; no Control Center integration/autosave yet.
3. Full-Resolution Export
- Add export using original image dimensions with correct markup scaling/placement.
- Keep PNG first; PDF remains separate.
4. Markup Color / Stroke Presets
- Status: `Done` in Phase 1O MVP.
- Presets delivered: NCD Blue, Red, Yellow, White, Black.
- Presets apply to new markups and can be applied to selected markup.
- Advanced style controls remain deferred (see TODO-029).
5. Better Touch Toolbar / Active Tool UX
- Improve touch targets, spacing, active-state clarity, and accidental-change prevention.
6. Move / Adjust Selected Markup
- Status: `Done` for whole-markup move (Phase 1M) and endpoint/resize handles for dimension/arrow/rectangle/oval (Phase 1N).
- Advanced handle work remains deferred (see TODO-028).
7. Better Undo / Redo History
- Add redo and predictable history across add/delete/move/edit/style actions.
8. Export Naming and Save Location Workflow
- Improve default naming, suffixes, and safe destination memory (without project-folder autosave).
9. Field Reliability / Large Image Performance
- Harden performance for large jobsite photos; protect responsiveness and original-file integrity.

### High (Open)
10. Multiple-Photo Markup Sets
- Group multiple photos with sequencing/thumbnails/per-photo markup state.
11. Control Center Integration Adapter
- Future adapter-only integration; preserve standalone MVP and separate asset outputs.
12. Samsung Tablet / Android Validation
- Validate touch/pen, picker, HEIC/JPG/PNG import, export, and toolbar sizing on Samsung tablet.
13. Apple Platform Compatibility Review
- Review iPad/iPhone/macOS feasibility and workflows; no implementation until approved.
14. HEIC/HEIF Dependency/Fallback Hardening
- Clarify dependency expectations, missing-fallback messaging, and future packaging strategy.
15. Export Quality / Output Review
- Validate readability/quality across sizes; confirm selected-state export behavior policy.

### Medium (Open)
16. Icon / Taskbar Branding Redesign Standard
- Define taskbar-first/vector icon standards and alpha/readability QA gates.
17. Optional PDF Export Evaluation
- Evaluate PDF after full-resolution PNG export is solved.
18. Voice-to-Text Notes
- Optional enhancement for Text Note Tool with typed fallback.
19. Shape/Text Styling Panel
- Add touch-friendly style controls (color/thickness/fill/font) later.
20. Editable Project File Format / Data Schema
- Define portable saved-markup schema for future integration.
21. Import/Export Error Handling Polish
- Improve user-friendly failures while keeping technical diagnostics available.
22. Onboarding / Quick Help Overlay
- Optional quick guidance for core gestures/tools.
23. Tool-Specific Cursor / Touch Feedback
- Improve draw previews/active tool cues/drag feedback.
24. Markup Layer / Z-Order Management
- Evaluate bring-forward/send-backward only if overlap complexity requires it.
25. Governance Icon Standard Follow-Up
- Add/update governance icon/splash standards in governance source (master rules, alpha, ICO frames, cache notes).

