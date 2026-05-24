# Changelog

Document Path: `C:\apps\NCD_Photo_Markup\System\Documentation\CHANGELOG.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-24`
Purpose: Canonical changelog for project changes.
Changes: Added splash/app version sync fix and version drift guardrail.

## Unreleased - 2026-05-24 (Splash/App Version Sync Fix)
- Owner: NCD / M
- Author: Codex
- Type: Fix
- Reason: Splash version display could drift from app/release version after bump.
- Scope:
  - `app/lib/main.dart`
  - `app/lib/core/constants/app_constants.dart`
  - `scripts/bump-version.ps1`
  - `scripts/verify-version-sync.ps1`
  - `app/test/widget_test.dart`
  - `Operations/VALIDATION_MATRIX.md`
  - `Operations/SESSION.md`
  - `System/Documentation/PROJECT_DOCUMENTATION.md`
  - `System/Documentation/FORM_DEFINITIONS.md`
  - `scripts/README.md`
- Changes:
  - Splash now renders `AppConstants.appVersion` so splash and app bar share one version source.
  - Added script-level version sync update in bump flow (`VERSION` + `AppConstants.appVersion`).
  - Added `scripts/verify-version-sync.ps1` to fail fast on version drift.
  - Added widget regression check for splash/app centralized version usage.

## Unreleased - 2026-05-23 (Phase 1E Export Failure Debug/Fix)
- Owner: NCD / M
- Author: Codex
- Type: Fix
- Reason: Export button failed in Phase 1E attempt and required targeted debug/fix.
- Scope:
  - `app/lib/main.dart`
  - `app/lib/core/constants/app_constants.dart`
  - `app/lib/features/export/services/marked_up_image_export_service.dart`
  - `app/test/widget_test.dart`
  - Required operations/system documentation updates
- Changes:
  - Fixed root cause where Export toolbar action was not wired to any handler.
  - Added user-selected PNG save dialog workflow.
  - Added RepaintBoundary capture + PNG encode/write export service for marked canvas output.
  - Added friendly no-photo warning, cancel-safe no-op, and success/failure user feedback.
  - Added export-related tunable constants (suffix, extension, messages, pixel ratio cap).
  - Fixed delayed dimension-label repaint by snapshotting painter line input and using deep list comparison in `shouldRepaint`.
- Validation Evidence:
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident`: `PASS`
  - Export failure root-cause artifact: `.agent_temp/diagnostics/export_debug/export_failure_root_cause.txt`
- Risks / Known Gaps:
  - End-to-end interactive save-dialog cancel and exported-file visual verification are pending owner manual run in this environment.

## Unreleased - 2026-05-23 (Phase 1D Icon Iteration Stop + Deferral)
- Owner: NCD / M
- Author: Codex
- Type: Documentation
- Reason: Stop further Phase 1D icon iteration; accept current MVP icon and defer taskbar-readability redesign.
- Scope:
  - `System/Documentation/PROJECT_DOCUMENTATION.md`
  - `Operations/TODO_REGISTER.md`
  - `Operations/SESSION.md`
  - `Operations/VALIDATION_MATRIX.md`
- Changes:
  - Kept current runtime icon packaging (`app/assets/branding/icon_v1_5.png`, `app/windows/runner/resources/app_icon.ico`).
  - Kept final approved-design transparent master (`System/Documentation/Images/NCD Photo Markup Icon v1.5-transparent-approved-design-master.png`).
  - Removed experimental icon master artifacts from commit scope.
  - Added future taskbar icon standard/redesign backlog item (TODO-014).
  - Recorded that Phase 1D icon quality/readability limits stem from mini-logo detail at small sizes.

## Unreleased - 2026-05-23 (Phase 1D Approved-Design Icon Correction)
- Owner: NCD / M
- Author: Codex
- Type: Visual QA Fix
- Reason: Prior taskbar variant was rejected as wrong/simplified design despite quality/transparency pass.
- Scope:
  - `System/Documentation/Images/NCD Photo Markup Icon v1.5-transparent-approved-design-master.png`
  - `app/assets/branding/icon_v1_5.png`
  - `app/windows/runner/resources/app_icon.ico`
  - visual QA diagnostics + documentation updates
- Changes:
  - Rebased icon work on approved source concept `NCD Photo Markup Icon v1.5.png`.
  - Removed only outer opaque background and preserved approved design language.
  - Increased icon fit within frame (balanced padding) without redesigning symbol.
  - Kept experimental taskbar/simplified variant as reference only; not used as final runtime icon.
  - Regenerated multi-size ICO (`16,24,32,48,64,128,256`) from corrected approved-design master.
- Validation Evidence:
  - `flutter clean`: `PASS`
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident`: `PASS`
  - Comparison contact sheet: `.agent_temp/diagnostics/icon_alpha_check/approved_design_correction/comparison_contact_sheet_original_wrong_corrected_and_frames.png`

## Unreleased - 2026-05-23 (Phase 1D Taskbar Icon Variant)
- Owner: NCD / M
- Author: Codex
- Type: Visual QA Fix
- Reason: Transparency passed but icon readability/quality needed taskbar optimization before commit.
- Scope:
  - `System/Documentation/Images/NCD Photo Markup Icon v1.5-taskbar-master.png`
  - `app/assets/branding/icon_v1_5.png`
  - `app/windows/runner/resources/app_icon.ico`
  - Validation/session documentation updates
- Changes:
  - Audited icon source quality and confirmed high-resolution source availability.
  - Built a taskbar-optimized transparent master variant with larger central mark and removed tiny `NCD PM` text dependency.
  - Regenerated multi-size ICO (`16,24,32,48,64,128,256`) from the new taskbar master.
  - Generated required size contact-sheet artifacts for owner visual QA review.
- Validation Evidence:
  - `flutter clean`: `PASS`
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident`: `PASS`
  - Contact sheet: `.agent_temp/diagnostics/icon_alpha_check/generated_quality_preview/contact_sheet_sizes_16_256_pixel_preview.png`

## Unreleased - 2026-05-23 (Phase 1D Icon Quality Refinement)
- Owner: NCD / M
- Author: Codex
- Type: Fix
- Reason: Improve Windows icon quality while preserving transparency before Phase 1D commit.
- Scope:
  - `System/Documentation/Images/NCD Photo Markup Icon v1.5-transparent-master.png`
  - `app/assets/branding/icon_v1_5.png`
  - `app/windows/runner/resources/app_icon.ico`
  - Ops/doc validation updates
- Changes:
  - Audited all icon candidates for resolution/alpha/suitability.
  - Selected high-resolution `v1.5` original artwork as source and derived a new transparent master.
  - Generated per-size icon frames (`16,24,32,48,64,128,256`) directly from master using LanczosSharp + light unsharp.
  - Rebuilt Windows ICO from those master-derived frames and captured quality preview contact sheets.
  - Re-ran full Flutter validation cycle after icon quality refresh.
- Validation Evidence:
  - `flutter clean`: `PASS`
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident`: `PASS`
  - Diagnostics: `.agent_temp/diagnostics/icon_alpha_check/generated_quality_preview/`

## Unreleased - 2026-05-23 (Phase 1D Blocking Fixes)
- Owner: NCD / M
- Author: Codex
- Type: Fix
- Reason: Resolve Phase 1D blockers before commit (label save crash + icon transparency).
- Scope:
  - `app/lib/main.dart`
  - `app/windows/runner/resources/app_icon.ico`
  - `System/Documentation/Images/NCD Photo Markup Icon v1.5-transparent.png`
  - `Operations/*` and `System/Documentation/*` updates
- Changes:
  - Reworked dimension label dialog into a dialog-owned stateful widget so controller lifecycle is safe.
  - Unified Enter and Save through one submit path; Skip/Cancel return safely with no controller reuse.
  - Verified all existing icon candidates were opaque, then derived a true transparent v1.5 source by removing edge-connected square background.
  - Regenerated Windows ICO from transparent source with common sizes (`16,24,32,48,64,128,256`) and verified alpha in extracted frames.
- Validation Evidence:
  - `flutter clean`: `PASS`
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS`
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident`: `PASS`
  - ICO diagnostics: `.agent_temp/diagnostics/icon_alpha_check/current_ico_preview/` and `.agent_temp/diagnostics/icon_alpha_check/generated_ico_preview/`
- Risks / Known Gaps:
  - Windows shell/taskbar may still cache older icon visuals until icon cache refresh.

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

## Unreleased - 2026-05-23 (Phase 1D)
- Owner: NCD / M
- Author: Codex
- Type: Feature
- Reason: Add manual text labels to dimension lines with lightweight measurement formatting.
- Scope:
  - `app/lib/main.dart`
  - `app/lib/core/constants/app_constants.dart`
  - `app/lib/features/markup/models/dimension_line.dart`
  - `app/lib/features/markup/widgets/dimension_lines_overlay.dart`
  - `app/lib/features/markup/utils/dimension_label_formatter.dart`
  - `app/test/dimension_label_formatter_test.dart`
  - Required project/governance docs
- Changes:
  - Added touch-friendly label entry dialog after creating each dimension line:
    - title: `Dimension Label`
    - hint: `Example: 72" or 6'-0"`
    - actions: `Save` and `Skip`
  - Added manual label storage on each dimension line.
  - Added label rendering near line midpoint with high-contrast background chip.
  - Added clamp logic so label chip stays inside displayed image bounds as much as practical.
  - Added tap-to-edit support for existing dimension line labels.
  - Kept undo behavior intact: undo removes latest line and its label.
  - Added lightweight formatter support for common manual inputs:
    - `72`, `72 in`, `72 inches`, `72"` -> `72"`
    - `6 0` -> `72"`
    - `6 6` -> `78"`
    - `5 10` -> `70"`
    - `6 ft`, `6'`, `6'-0"` -> inches output
  - Kept free-text labels unchanged when they are not numeric measurement-only input.
  - Centralized dialog/label style tunables in constants.
  - Added Enter/Done submit behavior in label dialog to match Save button action.
  - Fixed blocking label-save crash by moving `TextEditingController` ownership into a dedicated stateful dialog widget lifecycle.
  - Updated measurement quick-entry normalization to inches output:
    - `6 0` -> `72"`
    - `6 6` -> `78"`
    - `5 10` -> `70"`
  - Verified icon transparency request and found source-asset blocker:
    - Icon candidates checked: v1.0, v1.2, v1.3, v1.4, v1.4b, v1.5.
    - All icon candidates currently have no alpha channel (`srgb 3.0`, `opaque=True`).
    - Existing generated ICO scenes are fully opaque alpha.
- Validation Evidence:
  - `flutter pub get`: `PASS`
  - `flutter analyze`: `PASS`
  - `flutter test`: `PASS` (formatter + widget suite)
  - `flutter build windows --debug`: `PASS`
  - `flutter run -d windows --debug --no-resident`: `PASS`
  - Screenshot artifact: `C:\apps\NCD_Photo_Markup\.agent_temp\screenshots\phase1d_dimension_label_runtime_screen.png`
  - Icon source/ICO transparency checks: `FAIL` (blocked by source icon alpha absence)
  - Full interactive manual label workflow: `NOT_VALIDATED` in this environment
  - Android runtime/device behavior: `NOT_VALIDATED`
- Risks / Known Gaps:
  - Owner-side interactive field validation is still required for full line-label entry/edit confirmation.
  - Voice-to-text and advanced measurement parsing remain deferred.

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

## v0.5 - 2026-05-23
- Owner: Documentation Maintainers
- Author: defre
- Type: Documentation
- Reason: Approve Phase 1C Dimension Line MVP and branding polish
- Changes:
  - Updated release version.
- Validation Evidence:
  - Automated version bump script: PASS
- Rollback Notes:
  - Revert the version bump commit and delete the matching tag.

## v0.6 - 2026-05-23
- Owner: Documentation Maintainers
- Author: defre
- Type: Documentation
- Reason: Approve Phase 1D Dimension Labels and defer icon redesign
- Changes:
  - Updated release version.
- Validation Evidence:
  - Automated version bump script: PASS
- Rollback Notes:
  - Revert the version bump commit and delete the matching tag.

## v0.7 - 2026-05-24
- Owner: Documentation Maintainers
- Author: defre
- Type: Documentation
- Reason: Approve Phase 1E PNG Export MVP
- Changes:
  - Updated release version.
- Validation Evidence:
  - Automated version bump script: PASS
- Rollback Notes:
  - Revert the version bump commit and delete the matching tag.

## v0.8 - 2026-05-24
- Owner: Documentation Maintainers
- Author: defre
- Type: Documentation
- Reason: Approve splash version sync fix
- Changes:
  - Updated release version.
- Validation Evidence:
  - Automated version bump script: PASS
- Rollback Notes:
  - Revert the version bump commit and delete the matching tag.
