# ncd_photo_markup

Flutter app for NCD Photo Markup. Windows desktop is the built target.

Project documentation, repo map, tool list, file outputs, and launch arguments
are in the repo root `README.md`. This file covers only the app folder.

## Commands
Run these from this folder:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build windows --debug`
- `flutter run -d windows --debug --no-resident`

`flutter build windows` and `flutter run -d windows` need a local-drive checkout.
They fail on the `H:` network share because the Flutter tool cannot create the
plugin symlinks under `windows/flutter/ephemeral/.plugin_symlinks`. See the root
`README.md` for the detail.

## Layout
- `lib/main.dart`: app shell, sidebar wiring, tool state, dialogs, file actions.
- `lib/core/constants/app_constants.dart`: all tunable constants and user-facing copy.
- `lib/features/markup/`: mark models, measurement math, canvas overlay, sidecar service.
- `lib/features/import/`: image import, HEIC and DWG preview conversion.
- `lib/features/export/`: PNG export and export path naming.
- `lib/features/integration/`: Control Center launch context parsing.
- `lib/features/sidebar/`: sidebar icon and label mapping.
- `test/`: widget, service, and measurement tests.

## Rules
- Put user-facing text and tunable numbers in `app_constants.dart`, not inline.
- Keep mark coordinates normalized (`0..1`) against the source image.
- Do not write to the source photo. Exports and markup files are separate outputs.
