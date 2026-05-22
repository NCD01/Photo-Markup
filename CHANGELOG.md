# Changelog

Document Path: `C:\apps\NCD_Photo_Markup\CHANGELOG.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Canonical changelog for project changes.
Changes: Added Phase 1A shell-in-progress entry without version bump.

## Unreleased - 2026-05-22 (Phase 1A)
- Owner: NCD / M
- Author: Codex
- Type: Feature
- Reason: Create initial Flutter app shell for Windows-first workflow without implementing markup behavior.
- Scope:
  - `app/` Flutter project scaffold
  - Phase 1A governance/doc updates
- Changes:
  - Created Flutter app in `app/` with package name `ncd_photo_markup`.
  - Implemented shell UI in `app/lib/main.dart` with app bar, canvas placeholder, toolbar placeholders, and visible `v0.1`.
  - Added/updated test for shell text.
  - Set display label/title to `NCD Photo Markup` for shell runtime contexts.
- Validation Evidence:
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS` (after fixing initial test reference)
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident`: `PASS`
  - Screenshot: `C:\apps\NCD_Photo_Markup\.agent_temp\screenshots\phase1a_shell_startup.png`
- Risks / Known Gaps:
  - Markup tools are placeholders only; no drawing/annotation behavior yet.
- Rollback / Recovery Notes:
  - Revert Phase 1A app-shell files and docs if UI baseline needs reset.

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
