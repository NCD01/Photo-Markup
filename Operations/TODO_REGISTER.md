# TODO Register

Document Path: `C:\apps\NCD_Photo_Markup\Operations\TODO_REGISTER.md`
Version: `v0.4`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Track planned and in-progress work items.
Changes: Closed Phase 1C manual dimension-validation and Windows icon packaging follow-up items after owner feedback and icon resource replacement.

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

## Active Workstream Summary
| Order | Workstream | Item | Status | Dependency | Evidence |
|---|---|---|---|---|---|
| `1` | `Runtime` | `Phase 1B image import` | `Done` | `Validation run complete` | `Changelog v0.3 entry + phase1b screenshot` |
| `2` | `Manual QA` | `Interactive picker cancel/select validation` | `Open` | `Owner interactive pass` | `Pending` |
| `3` | `MVP Tools` | `Dimension line MVP implemented; arrow and remaining tools pending` | `In Progress` | `Owner validation and next-phase approval` | `Phase 1C code + tests complete` |
| `4` | `Structure` | `Lean-root + governance sync completion` | `Done` | `M-approved dirty-state continuation` | `Session + validation evidence` |
| `5` | `Governance` | `Tunable constants standard adoption` | `Done` | `Governance v1.7 effective update` | `Constants file + policy/addendum sync` |
| `6` | `Manual QA` | `Dimension line interactive field validation` | `Done` | `Owner Windows interactive run` | `Owner reported manual items 1-6 PASS + bounds fix PASS` |
| `7` | `Branding` | `Windows platform icon packaging follow-up` | `Done` | `Approved icon v1.5 source` | `app/windows/runner/resources/app_icon.ico replaced from approved asset` |





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

