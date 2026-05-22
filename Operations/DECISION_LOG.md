# Decision Log

Document Path: `C:\apps\NCD_Photo_Markup\Operations\DECISION_LOG.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Record material architecture/process decisions.
Changes: Added initial bootstrap decisions.

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
