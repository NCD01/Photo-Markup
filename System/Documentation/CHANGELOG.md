# Changelog

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\CHANGELOG.md`
Version: `v0.3`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Canonical changelog for project changes.
Changes: Added uncommitted Phase 1A.1 lean-root/governance-sync structural update notes (no version bump).

## Unreleased - 2026-05-22
- Owner: NCD / M
- Author: Codex
- Type: Structural/Documentation
- Reason: Continue approved dirty-state lean-root cleanup and apply governance sync requirements.
- Scope:
  - Root structure cleanup and moved-document reference alignment
  - Governance hook/script sync and setup
  - Operations validation/session/todo records
  - Tunable constants governance adoption for Flutter shell
- Changes:
  - Synced governance hook/script artifacts from `C:\Games\Governance` (`main` at `bdd94db`).
  - Set hook path through `scripts/setup-git-hooks.ps1` to `Governance/.githooks`.
  - Updated `scripts/bump-version.ps1` doc output paths to `System/Documentation/`.
  - Removed duplicate root `.githooks` after confirming governed hook location.
  - Adopted updated tunable-constants governance files:
    - `Governance/CODE_FILE_STRUCTURE_POLICY.md`
    - `Governance/Language_Addendums/DART_FLUTTER_ADDENDUM.md`
    - `Governance/Examples/CONSTANT_BLOCKS_EXAMPLE.md`
  - Centralized shell tunable values into `app/lib/core/constants/app_constants.dart`.
  - Updated `app/lib/main.dart` to consume centralized constants without behavior changes.
  - Revalidated Flutter analyze/test/build/startup smoke.
- Validation Evidence:
  - `git pull` governance source: `PASS` (`Already up to date`)
  - Hook setup command: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident`: `PASS`
- Risks / Known Gaps:
  - Android runtime behavior remains `NOT_VALIDATED`.
  - No feature behavior changes are included.

## v0.3 - 2026-05-22
- Owner: NCD / M
- Author: Codex
- Type: Feature
- Reason: Add image import/open-photo behavior to the canvas without implementing markup tools yet.
- Scope:
  - `app/lib/main.dart`
  - `app/pubspec.yaml`, `app/pubspec.lock`
  - `app/test/widget_test.dart`
  - Required project/governance docs
- Changes:
  - Made `Open Photo` button functional via `file_selector`.
  - Added supported image extension handling (`jpg`, `jpeg`, `png`, `webp`).
  - Displayed selected image in canvas using contain-fit/aspect-preserving behavior.
  - Added loaded-photo filename indicator and field-safe load-failure messaging.
  - Kept all non-Open toolbar actions as placeholders.
  - Bumped visible app/docs version to `v0.3`.
- Validation Evidence:
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - Startup smoke: `PASS`
  - Loaded-image screenshot: `C:\apps\NCD_Photo_Markup\.agent_temp\screenshots\phase1b_loaded_image.png`
  - Manual picker cancel/select automation: `NOT_VALIDATED` (OS keyboard automation blocked)
  - Android runtime/device behavior: `NOT_VALIDATED`
- Risks / Known Gaps:
  - Markup tool behavior still intentionally unimplemented.
  - Manual picker click/cancel/select flow still needs owner-side interactive validation.
- Rollback / Recovery Notes:
  - Revert `app/lib/main.dart` + `file_selector` dependency changes and related docs.

## v0.2 - 2026-05-22
- Owner: NCD / M
- Author: Codex
- Type: Feature
- Reason: Create initial Flutter app shell for Windows-first workflow without implementing markup behavior.
- Scope:
  - `app/` Flutter project scaffold
  - Phase 1A governance/doc updates
- Changes:
  - Created Flutter app in `app/` with package name `ncd_photo_markup`.
  - Implemented shell UI in `app/lib/main.dart` with app bar, canvas placeholder, toolbar placeholders, and visible `v0.2`.
  - Added/updated test for shell text.
  - Set display label/title to `NCD Photo Markup` for shell runtime contexts.
  - Bumped visible app/docs version to `v0.2`.
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




