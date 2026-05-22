# Changelog

Document Path: `C:\apps\NCD_Photo_Markup\CHANGELOG.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Canonical changelog for project changes.
Changes: Added Phase 0 bootstrap entry.

## v0.1 - 2026-05-22
- Owner: NCD / M
- Author: Codex
- Type: Documentation
- Reason: Establish governance and documentation baseline before feature development.
- Scope:
  - `C:\apps\NCD_Photo_Markup\*`
- Changes:
  - Bootstrapped governance and operations docs from Governance v1.5 pack.
  - Created project-specific baseline docs and placeholders replaced.
  - Added temp artifact folder policy and ignore rule.
- Validation Evidence:
  - `git status --short` (in `C:\apps`): `NOT_RUN_AS_REPO` (not a git repo)
  - `git status --short` (in `C:\apps\NCD_Photo_Markup`): `PASS` (repo initialized; working tree tracked)
  - Placeholder scan for project docs: `PASS`
- Risks / Known Gaps:
  - Flutter runtime/build validation not run because app code is not created yet.
- Rollback / Recovery Notes:
  - Remove `C:\apps\NCD_Photo_Markup` folder if bootstrap must be restarted from scratch.
