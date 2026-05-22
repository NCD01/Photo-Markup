# Versioning and Change Control Policy

Document Path: `<PRIMARY_PATH>/Governance/VERSIONING_AND_CHANGE_CONTROL.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define versioning, changelog, decision, release, and rollback rules.
Changes: Clarified no patch versions by default and version alignment expectations.

## Quick Rules
- Use version format `vX.Y` unless the project owner approves a different scheme.
- Do not use patch versions like `v1.2.1` unless explicitly adopted in `APP_PROFILE.md`.
- No approved change without changelog decision.
- No release notes without matching versioned changes.
- Include rollback or recovery notes for every release-impacting change.

## Required Contract
Version bump policy:
- `vX.Y` where:
  - `X` increments for breaking, major behavior, migration, or architecture changes.
  - `Y` increments for additive, corrective, documentation, or non-breaking changes.

Mandatory changelog fields per entry:
- version
- date
- owner
- author
- type
- reason
- scope
- changes
- validation evidence
- risks/known gaps
- rollback/recovery notes

Release linkage contract:
- Each release note version must map to one or more changelog entries.
- Breaking changes must include migration notes.
- Related artifacts should stay on aligned versions when they are released together.

## Detailed Guidance
Breaking change indicators:
- schema contract changed incompatibly
- required config keys changed
- removed/renamed externally consumed identifiers
- storage format changed
- migration required
- user workflow changed in a way that needs retraining or release notes

Decision records are required for:
- breaking changes
- rollback strategy changes
- data migrations
- privacy/security exceptions
- external dependency changes with risk

If rollback is impossible, document compensating controls and recovery procedure.

## Verification Gate
- [ ] Version format is valid.
- [ ] Changelog entry includes mandatory fields.
- [ ] Release note linkage is explicit.
- [ ] Breaking changes include migration and rollback details.
- [ ] Related artifacts have aligned versions or documented reason for mismatch.
