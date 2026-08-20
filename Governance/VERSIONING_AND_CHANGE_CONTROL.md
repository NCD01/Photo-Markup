# Versioning and Change Control Policy

Document Path: `<PRIMARY_PATH>/Governance/VERSIONING_AND_CHANGE_CONTROL.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define versioning, changelog, decision, release, and rollback rules.
Changes: Added the owner bump-and-push rule; a version is no longer withheld pending validation.

## Quick Rules
- Every change gets a version bump, a commit, and a push. No exceptions.
- Validation gates whether a version is good, not whether it gets a number.
- Use version format `vX.Y` unless the project owner approves a different scheme.
- Do not use patch versions like `v1.2.1` unless explicitly adopted in `System/Documentation/APP_PROFILE.md`.
- No approved change without changelog decision.
- No release notes without matching versioned changes.
- Include rollback or recovery notes for every release-impacting change.

## Required Contract
Bump-and-push rule (owner directive, 2026-08-19):
- Every change bumps the version. A one-line fix, a documentation edit, and a
  test-only change all bump. There is no change that stays at the same version.
- Every version bump is committed.
- Every commit is pushed. `main` must not be left ahead of `origin/main` at the
  end of a working session.
- A version is never withheld pending owner validation. Validation decides
  whether a version is good, not whether it is issued. An unvalidated version is
  recorded as unvalidated in the changelog and still gets its number.
- Use `scripts/bump-version.ps1` so `VERSION`, `AppConstants.appVersion`,
  `CHANGELOG.md`, and `RELEASE_NOTES.md` stay in step. The pre-push hook rejects
  a push with no bump.

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
- [ ] The change carries a version bump.
- [ ] The bump is committed and pushed.
- [ ] Version format is valid.
- [ ] Changelog entry includes mandatory fields.
- [ ] Release note linkage is explicit.
- [ ] Breaking changes include migration and rollback details.
- [ ] Related artifacts have aligned versions or documented reason for mismatch.

