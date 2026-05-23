# Decision Log

Document Path: `C:\apps\NCD_Photo_Markup\Operations\DECISION_LOG.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-23`
Purpose: Record material architecture/process decisions.
Changes: Added Phase 1D decision for safe dialog-owned label controller lifecycle to prevent disposed-controller crashes.

## DECISION-001
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Governance
- Decision: Adopt Governance v1.5/NewApp Documentation Pack v1.5 as project baseline.
- Alternatives Considered:
- Recreate docs manually.
- Delay governance until after code starts.
- Rationale: Enforces validation, versioning, and documentation discipline from day one.
- Impact: Stronger change control and cleaner future handoffs.
- Rollback or Reversal: Replace baseline with a newer approved pack via explicit migration decision.
- Related Changes: v0.1 bootstrap docs
- Review Date: N/A

## DECISION-002
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Product Sequencing
- Decision: Build standalone Flutter app first for Windows touchscreen tablet, then add Android support later.
- Alternatives Considered:
- Build Android first.
- Start inside Control Center immediately.
- Rationale: Windows-first field workflow is primary near-term requirement.
- Impact: Platform adapters and integration deferred to later phases.
- Rollback or Reversal: Reprioritize platform order with explicit owner approval.
- Related Changes: v0.1 bootstrap docs
- Review Date: N/A

## DECISION-003
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Repository Structure and Governance
- Decision: Keep lean root layout with hooks under `Governance/.githooks` and scripts under root `scripts/`.
- Alternatives Considered:
- Keep hooks at root `.githooks`.
- Keep docs mixed at root.
- Rationale: Maintains clean repo navigation while preserving explicit governance boundaries.
- Impact: Root contains only essential files/folders; hook setup script points to `Governance/.githooks`.
- Rollback or Reversal: Restore root `.githooks` and adjust setup script if owner later prefers default root hook layout.
- Related Changes: Phase 1A.1 lean-root + governance sync (uncommitted workspace)
- Review Date: N/A

## DECISION-004
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Flutter Code Structure
- Decision: Centralize current shell tunable values into `app/lib/core/constants/app_constants.dart`.
- Alternatives Considered:
- Keep all literals inline in `main.dart`.
- Split many micro-constant files during cleanup.
- Rationale: Meets governance tunable-constants requirement without broad refactor.
- Impact: App title/version/theme/labels/extensions/copy/layout values now have clear edit points.
- Rollback or Reversal: Move values back inline if owner rejects constants approach.
- Related Changes: Governance v1.7 tunable constants adoption (uncommitted workspace)
- Review Date: N/A

## DECISION-005
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Markup MVP Architecture
- Decision: Implement Phase 1C dimension line using a separate overlay/model layer with no changes to original image files.
- Alternatives Considered:
- Draw directly into image pixels.
- Keep all markup logic inline in one widget without model separation.
- Rationale: Preserves original photo and keeps a clean expansion path for future tools.
- Impact: Added `DimensionLine` model, `MarkupTool` enum, and `DimensionLinesOverlay` widget; Undo removes latest line state.
- Rollback or Reversal: Revert feature files and toolbar tool-state wiring if owner rejects current MVP interaction.
- Related Changes: Phase 1C dimension MVP (uncommitted workspace)
- Review Date: N/A

## DECISION-006
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: UI/Runtime Boundaries
- Decision: Constrain dimension drawing to the actual displayed image rectangle and load splash/icon branding from app-local assets.
- Alternatives Considered:
- Allow lines to extend into non-image canvas space.
- Load runtime branding directly from `System/Documentation/Images`.
- Rationale: Prevents false markups outside photo bounds and keeps runtime assets decoupled from documentation storage.
- Impact: Drag points are clamped, overlay is clipped to image rect, branding assets are copied into `app/assets/branding/`, Windows runner icon is replaced from approved v1.5 source, and splash duration remains tunable via constants.
- Rollback or Reversal: Remove clamp/clip logic and revert branding references if owner requests a different workflow.
- Related Changes: Phase 1C approved image assets + dimension bounds fix (uncommitted workspace)
- Review Date: N/A

## DECISION-007
- Date: 2026-05-23
- Status: Accepted
- Owner: NCD / M
- Area: Dimension Label UX
- Decision: Add post-draw manual label dialog with optional Save/Skip and lightweight feet/inches normalization for common inputs.
- Alternatives Considered:
- Delay labels entirely until full Text Note tool phase.
- Force raw text only with no normalization.
- Rationale: Meets immediate field need for measurement annotations while keeping implementation low risk and touch-friendly.
- Impact: Dimension lines now support label add/edit; labels render in bounded readable chips; undo removes line + label together.
- Rollback or Reversal: Disable dialog entry flow and remove label rendering/formatter if owner rejects current behavior.
- Related Changes: Phase 1D manual label workflow (uncommitted workspace)
- Review Date: N/A

## DECISION-008
- Date: 2026-05-23
- Status: Accepted
- Owner: NCD / M
- Area: Dialog Lifecycle Safety
- Decision: Move dimension label `TextEditingController` ownership into a dedicated dialog `StatefulWidget` and submit through one shared callback for Enter/Save.
- Alternatives Considered:
- Keep controller in parent method and dispose after dialog await.
- Use inline stateless dialog with parent-owned controller.
- Rationale: Prevents runtime crash (`TextEditingController used after dispose`) seen during Save/Enter path.
- Impact: Save/Enter/Skip/Cancel now use dialog-local controller lifecycle and no disposed-controller assertions.
- Rollback or Reversal: Revert to prior inline dialog only if a safer equivalent lifecycle approach replaces it.
- Related Changes: Phase 1D blocking crash fix (uncommitted workspace)
- Review Date: N/A

## DECISION-009
- Date: 2026-05-23
- Status: Accepted
- Owner: NCD / M
- Area: Branding Scope Control
- Decision: Stop further Phase 1D icon iteration, keep current transparent approved-design icon for MVP, and defer taskbar readability redesign to a future icon standard phase.
- Alternatives Considered:
- Continue icon iteration within Phase 1D until taskbar readability is perfect.
- Revert to an opaque or Flutter default icon.
- Rationale: Current transparency/packaging is technically acceptable for MVP; additional redesign effort is out of scope for Phase 1D and needs a separate approved icon standard.
- Impact: Runtime icon remains `app/assets/branding/icon_v1_5.png` + `app/windows/runner/resources/app_icon.ico`; redesign backlog tracked as `TODO-014`.
- Rollback or Reversal: Reopen icon redesign effort only under a future approved phase.
- Related Changes: Phase 1D closeout commit preparation (uncommitted workspace)
- Review Date: N/A

