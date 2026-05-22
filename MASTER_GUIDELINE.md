# Master Guideline 

Document Path: `C:\apps\NCD_Photo_Markup/MASTER_GUIDELINE.md`
Version: `v0.1`
Pack File Version: `v1.5`
Owner: `NCD / M`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Main policy entry point for `NCD Photo Markup` documentation, governance, validation, and agent work.
Changes: Added v1.5 UI standards, form definitions, and multi-coder coordination requirements.

## Quick Rules
- `APP_PROFILE.md` stores project facts; governance stores rules.
- Agent output must be concise, evidence-based, and free of unsupported assumptions.
- No behavior change is complete without documentation, changelog, and validation evidence.
- No release-impacting work is complete without rollback or recovery notes.
- Logging must be structured, user-safe, and free of secrets.
- User-facing text should be corrected unless listed in the as-is exception register.
- Build success is not full validation when runtime behavior may be affected.
- Visual/user-facing changes require visual evidence when screenshots or screen checks can prove correctness.
- Temporary artifacts must stay out of production folders unless intentionally governed.

## Required Contract
This master guideline must link to the active governance set:
- `Governance/AGENT_EXECUTION_POLICY.md`
- `Governance/AGENT_OUTPUT_DISCIPLINE_POLICY.md`
- `Governance/CODE_FILE_STRUCTURE_POLICY.md`
- `Governance/LOGGING_AND_ERROR_POLICY.md`
- `Governance/PRIVACY_AND_DATA_HANDLING_POLICY.md`
- `Governance/RELEASE_AND_VALIDATION_POLICY.md`
- `Governance/TEMPORARY_ARTIFACT_POLICY.md`
- `Governance/TEXT_QUALITY_POLICY.md`
- `Governance/VERSIONING_AND_CHANGE_CONTROL.md`

Minimum completion evidence for any code or documentation change:
- changed files list
- version/changelog decision
- concise evidence summary without unnecessary raw dumps
- assumptions/unknowns clearly labeled
- validation commands and results
- runtime startup smoke result when required
- runtime log review result when runtime launch was performed
- visual QA evidence when UI, layout, game, map, sprite, or user-visible behavior changed
- temporary artifact summary when screenshots, diagnostics, generated files, or scratch outputs were created
- risks, known gaps, or explicit none
- rollback/recovery note when behavior, data, release, or schema changes

## Detailed Guidance
- Project teams may add stricter rules but must not weaken the baseline policies.
- Language-specific rules belong in `Governance/Language_Addendums/`.
- Module docs must stay aligned with implementation contracts.
- Protected public identifiers must not be renamed without migration notes and decision log entry.
- If a requirement conflicts with a policy, record the decision and get owner approval before weakening protection.
- Runtime startup requirements belong in `APP_PROFILE.md`, `Operations/VALIDATION_MATRIX.md`, and `Operations/RUNTIME_STARTUP_SMOKE_TEST.md` after adoption.

## Closeout Standard
Before marking work complete, confirm:
1. implementation matches requested scope
2. docs match implementation
3. changelog matches docs and version
4. validation evidence is recorded
5. runtime startup validation is recorded when required
6. logs were reviewed when runtime validation was performed
7. output is concise and does not repeat unnecessary boilerplate
8. assumptions and unknowns are clearly labeled
9. any handoff has one exact next action

If runtime startup validation was required but not performed, do not mark the work as fully validated.

## Verification Gate
- [ ] Governance links resolve.
- [ ] Project facts are stored in `APP_PROFILE.md`.
- [ ] Completion evidence standard is followed.
- [ ] Runtime startup validation is included in closeout when required.
- [ ] Output discipline policy is included in active governance.
- [ ] Language addendums are included only when applicable.

## v1.5 UI Standards and Multi-Coder Coordination
Projects with UI work should adopt a governed UI standards document and selection/approval form before broad modernization.

Projects using multiple agents must maintain a coordination record that identifies:
- the master source of truth
- each coder's scope
- files each coder must not touch
- current clean checkpoint
- version and commit status
- sync/pull requirements before work continues

Form/screen architecture should be tracked in a form definitions document. This document should map main forms/screens, child components, routes, related services, and data sources, without becoming a noisy inventory of every source file.


