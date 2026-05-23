# Decision Log

Document Path: `C:\apps\NCD_Photo_Markup\Operations\DECISION_LOG.md`
Version: `v0.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Record material architecture/process decisions.
Changes: Added tunable-constants governance adoption decision for Flutter shell.

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

