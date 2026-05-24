# TODO Register

Document Path: `C:\apps\NCD_Photo_Markup\Operations\TODO_REGISTER.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-24`
Purpose: Track planned and in-progress work items.
Changes: Added Phase 1I follow-up TODO for optional circle/oval labels/annotations.

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

## Active Workstream Summary
| Order | Workstream | Item | Status | Dependency | Evidence |
|---|---|---|---|---|---|
| `1` | `Runtime` | `Phase 1B image import` | `Done` | `Validation run complete` | `Changelog v0.3 entry + phase1b screenshot` |
| `2` | `Manual QA` | `Interactive picker cancel/select validation` | `Open` | `Owner interactive pass` | `Pending` |
| `3` | `MVP Tools` | `Dimension line + manual label flow implemented; arrow and remaining tools pending` | `In Progress` | `Owner validation and next-phase approval` | `Phase 1D code + tests complete` |
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





## Roadmap Details
### Future Phase: Apple Compatibility and HEIC/HEIF Support
- Keep app architecture compatible with Apple platforms where practical.
- Plan for future iPad/iPhone support.
- Consider macOS compatibility if practical.
- Support opening HEIC/HEIF images from Apple devices.
- Do not break the current Windows tablet workflow.
- Do not implement during this cleanup phase.

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

