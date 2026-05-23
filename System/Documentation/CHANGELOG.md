# Changelog

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\CHANGELOG.md`
Version: `v0.4`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Canonical changelog for project changes.
Changes: Added uncommitted Phase 1C startup-window maximize behavior and final splash size polish details.

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

## Unreleased - 2026-05-22 (Phase 1C)
- Owner: NCD / M
- Author: Codex
- Type: Feature
- Reason: Implement Dimension Line MVP behavior without adding unrelated tools or persistence.
- Scope:
  - `app/lib/main.dart`
  - `app/lib/core/constants/app_constants.dart`
  - `app/lib/features/markup/models/dimension_line.dart`
  - `app/lib/features/markup/models/markup_tool.dart`
  - `app/lib/features/markup/widgets/dimension_lines_overlay.dart`
  - `app/test/widget_test.dart`
  - Required project/governance docs
- Changes:
  - Added tool selection state for Dimension in toolbar.
  - Added dimension line overlay rendering above image without modifying original image.
  - Added persistent dimension line state and pointer drag behavior.
  - Added displayed-image-rect clamping so dimension lines stay inside photo bounds and do not draw into white canvas space.
  - Added overlay clipping to displayed image rect as an additional draw safeguard.
  - Added undo-last-dimension-line behavior via Undo button.
  - Kept non-dimension tools as placeholders.
  - Kept image import flow intact.
  - Added app-consumed branding assets under `app/assets/branding/` and wired:
    - startup splash asset (`splash_v1_5.png`)
    - app bar icon asset (`icon_v1_5.png`)
  - Registered branding assets in `app/pubspec.yaml`.
  - Replaced Windows runner icon resource with approved v1.5 icon:
    - `app/windows/runner/resources/app_icon.ico` generated from `System/Documentation/Images/NCD Photo Markup Icon v1.5.png`
  - Increased startup splash duration to `2200 ms` (centralized constant).
  - Increased splash image footprint again to fill most of startup screen:
    - `splashImageWidthFactor: 0.97`
    - `splashImageHeightFactor: 0.88`
  - Updated Windows runner show behavior to open maximized (startup-screen size) via `SW_MAXIMIZE`.
  - Centralized tunable dimension values in constants (line color, stroke, endpoint sizes, drag threshold).
- Validation Evidence:
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident -v`: `PASS`
  - Final rerun after larger splash + startup maximize updates:
    - `flutter pub get`: `PASS`
    - `flutter analyze`: `PASS`
    - `flutter test`: `PASS`
    - `flutter build windows --debug`: `PASS`
    - `flutter run -d windows --debug --no-resident`: `PASS`
  - Commit-approval validation rerun (`2026-05-23`): `PASS`
  - Screenshot artifact: `C:\apps\NCD_Photo_Markup\.agent_temp\screenshots\phase1c_dimension_overlay_artifact.png`
  - Manual full interactive Open Photo + draw flow: `NOT_VALIDATED` in this environment
  - Android runtime/device behavior: `NOT_VALIDATED`
- Risks / Known Gaps:
  - Full owner-interactive manual validation still required for complete field workflow confirmation.
  - Other markup tools remain intentionally unimplemented.

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





## v0.4 - 2026-05-22
- Owner: Documentation Maintainers
- Author: defre
- Type: Documentation
- Reason: Approve governance sync and lean root cleanup
- Changes:
  - Updated release version.
- Validation Evidence:
  - Automated version bump script: PASS
- Rollback Notes:
  - Revert the version bump commit and delete the matching tag.
