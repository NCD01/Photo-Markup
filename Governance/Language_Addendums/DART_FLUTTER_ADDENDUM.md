# Dart and Flutter Addendum

Document Path: `C:\apps\NCD_Photo_Markup\Governance\Language_Addendums\DART_FLUTTER_ADDENDUM.md`
Version: `v0.3`
Pack File Version: `v1.7`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Optional Dart/Flutter-specific rules for apps using Flutter or Dart.
Changes: Adopted Dart/Flutter tunable-constants governance standard and aligned repo document references.

## Quick Rules
- Use this addendum only for Dart/Flutter projects.
- Keep widget layout constants centralized.
- Avoid inline literals for repeatable UI values.
- Keep UI, API, engine, and data concerns separated.
- Run Flutter/Dart validation commands listed in `System/Documentation/APP_PROFILE.md`.
- Do not treat `flutter build` as proof that the app can launch.
- Run a runtime startup smoke test when startup, assets, routes, platform setup, dependencies, or first screen/scene may be affected.

## Required Contract
Recommended file order for governed Dart files:
1. file header/comment when required
2. imports
3. constants/tokens
4. enums/models/classes
5. public methods/functions
6. private helpers

Common validation commands:
```bash
flutter pub get
flutter analyze
flutter test
flutter build windows --debug
flutter run -d windows --debug
```

The final command may use a different target device/platform when documented in `System/Documentation/APP_PROFILE.md`.

## Flutter Asset Validation
Flutter and Flame asset paths must be documented and tested according to the app's asset-loading method.

For standard Flutter `rootBundle` or widget assets, paths usually use the project asset path as listed in `pubspec.yaml`.

For Flame image loading, image cache paths are commonly relative to the configured images root. If the images root is `assets/images/`, do not repeat `assets/images/` inside Flame image constants.

Example Flame image path rule:

```text
Correct: maps/map_1_round_and_round_v1_1.png
Wrong: assets/images/maps/map_1_round_and_round_v1_1.png
```

The app documentation must define which asset path style is used and must include a validation check that prevents double-prefix paths, missing assets, and empty asset files.

## Asset Registry Requirement
Flutter/Flame apps must centralize asset keys in one registry/config file when assets are loaded by code.

The registry must separate:
- production asset path as listed in `pubspec.yaml`
- Flame image key or loader-specific key used by runtime loaders
- friendly display name for logs/errors

Example:

```text
Pubspec path: assets/images/maps/map_1_round_and_round_v1_3.png
Flame key: maps/map_1_round_and_round_v1_3.png
Display name: Round and Round map background
```

Tests or validation checks must fail when:
- a Flame image key starts with `assets/`
- a path contains `assets/images/assets/images/`
- a configured asset file is missing
- a configured asset file is empty

The app documentation must explain which asset path is used by each loader.

## Runtime Startup Smoke Test
For Flutter apps, runtime validation must confirm:
- app launches on the target platform/device
- first screen/scene/route loads
- required startup assets load
- no missing asset or missing file error appears
- no unhandled exception appears
- no Flutter framework exception blocks startup
- logs were reviewed after launch

For game apps, runtime validation must also confirm:
- first scene or level loads
- required map/background assets load
- required startup sprite or entity assets load
- first expected gameplay log/event occurs when applicable
- no hard crash occurs during startup

## Detailed Guidance
- Shared values belong in global token classes when reused.
- Feature-specific values may live in feature constants blocks.
- Define a top-level file constants block (or feature config file) for tunable UI/behavior values that are expected to change.
- Keep tunable constants grouped by domain, for example:
  - timing/debounce/retry
  - layout/spacing/sizing
  - copy/labels/tooltips
  - default sort/filter/paging values
- Avoid repeating the same literal values across widgets/services. Promote repeated literals into constants.
- Name constants for intent (for example `kAutosaveDebounceMs`) instead of raw value meaning.
- Use stable DTOs between UI/API/Engine/Data layers.
- Keep generated files and manual files clearly separated.
- Document platform-specific behavior, especially Windows desktop vs mobile differences.
- When using Flame, centralize configured asset paths and expose a list that tests can validate.
- When using Flame or custom renderers, also review `Governance/Language_Addendums/GAME_UI_RUNTIME_ADDENDUM.md`.
- When runtime validation cannot be run, mark it `NOT_RUN` and do not claim full green light.

## Verification Gate
- [ ] Addendum is only active for Dart/Flutter projects.
- [ ] Dart/Flutter commands are listed in `System/Documentation/APP_PROFILE.md`.
- [ ] Runtime startup command/method is listed in `System/Documentation/APP_PROFILE.md`.
- [ ] UI layout constants are centralized.
- [ ] Tunable Flutter/Dart values are centralized in constants/config blocks.
- [ ] Asset path style is documented for the app.
- [ ] Asset registry separates pubspec path, runtime key, and display name.
- [ ] Module docs match implementation boundaries.
- [ ] No full green light is reported unless required runtime startup validation passed.
