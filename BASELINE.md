# BASELINE

Recorded before any change was made in the overnight run.

- Repo: `/home/user/Photo-Markup`
- Branch: `claude/photo-markup-overnight-enjgup`
- Commit at start of run: `3e4da983e06ba54574863105bd62ef36bbd65925` ("Bump app version to v0.32")
- Working tree at start of run: clean. No pre-run snapshot commit was needed.
- App version string in code: `v0.32`

## What the app is

NCD Photo Markup is a Flutter desktop app for marking up site photos. It is
built Windows-first (there is a `windows/` runner and an `android/` runner in
the repo; no iOS, macOS, Linux or web target). It is a single-window tool: you
open one photo, draw on it, and either export a flattened PNG or save an
editable `.ncdmarkup.json` sidecar that can be reopened later.

It is designed to be launched either standalone or from another NCD app
("Control Center") which passes client/project context and suggested output
folders on the command line or through a JSON context file.

## Stack

- Flutter, Dart. `pubspec.yaml` requires Dart SDK `^3.11.5`.
- Runtime dependencies: `file_selector` (open/save dialogs),
  `heic_to_png_jpg` (HEIC decode), `cupertino_icons`.
- No state management package, no database, no network. Everything is
  `setState` inside one big `StatefulWidget`.
- 13 unit/widget test files, 93 tests.

## Architecture as it actually is

```
app/lib/
  main.dart                        4,902 lines. The whole UI and all interaction
                                   logic lives in _PhotoMarkupShellScreenState.
  core/constants/app_constants.dart 690 lines. Every tunable: colors, sizes,
                                   strings, timeouts. Governance requires that
                                   no literal tunables live in logic files.
  features/
    markup/models/                 One model class per markup type:
                                   dimension_line, arrow_markup,
                                   rectangle_markup, oval_markup,
                                   freehand_markup, text_note_markup.
                                   Each stores coordinates NORMALIZED (0..1)
                                   against the displayed image rect, plus a
                                   style preset id.
    markup/models/editable_markup_document.dart
                                   The .ncdmarkup.json schema (v1.0) and its
                                   JSON reader/writer.
    markup/widgets/dimension_lines_overlay.dart
                                   A Listener + CustomPainter that draws every
                                   markup type and forwards pointer events up
                                   to the shell state.
    markup/utils/                  Hit-testing, text layout, move clamping,
                                   handle resize math, typography clamping,
                                   dimension label formatting (72 -> 72", 6 0
                                   -> 72").
    import/services/               image_import_service (HEIC conversion with
                                   an on-disk cache and an ImageMagick
                                   fallback), dwg_preview_conversion_service
                                   (1,045 lines; pulls an embedded preview out
                                   of a DWG or shells out to a configured
                                   offline converter, with a quality gate).
    export/services/               marked_up_image_export_service (captures the
                                   on-screen RepaintBoundary and crops it),
                                   markup_export_path_service (default names,
                                   duplicate-safe paths).
    integration/services/          launch_context_service (arg + JSON context
                                   parsing from Control Center).
    view/utils/                    zoom clamp/step math.
    sidebar/models/                maps toolbar labels to custom PNG icons.
```

Key architectural fact: there is no single annotation list. There are six
parallel typed lists and six separate `_selectedXId` fields, and every
operation (undo, erase, move, resize, style, hit test, save, load) is a
switch or an if-chain across all six. That is the thing that makes new tools
expensive to add.

Coordinates are normalized against the *displayed* image rectangle, which is
recomputed from the canvas size with `applyBoxFit(BoxFit.contain, ...)`. That
part is good: annotations stay anchored to the photo when the window resizes.

## What works well today

- Normalized coordinates. Annotations stay put across window resize.
- The editable `.ncdmarkup.json` sidecar. Real reopen-and-keep-editing support,
  with schema versioning and a "locate the source image" recovery dialog when
  the referenced photo has moved.
- Unsaved-changes guard on open, on markup-open, and on window close.
- Select, move, and resize an existing annotation, with endpoint and corner
  handles. Drag activation thresholds mean a tap does not accidentally nudge.
- HEIC import with a content-hashed disk cache and stale-file cleanup.
- Import failures give specific, human messages instead of a generic error.
- Constants discipline. Almost nothing is hard-coded in logic files.
- A real test suite that covers the geometry and the service layer.

## Verified by running it

Flutter is not installed on this machine by default. I installed Flutter
3.47.0 stable to `/opt/flutter`, added a Linux desktop runner in a scratch copy
of `app/` outside the repo (the repo itself has no Linux target), built it, and
ran it under Xvfb with a generated test photo. Screenshots confirmed the
findings below.

- `flutter test` on the untouched repo: **92 passed, 1 failed.**
  The one failure is `markup_export_path_service_test.dart >
  buildSafeMarkupExportPath appends increment for duplicate output`. It asserts
  a Windows path separator and the service builds the path with
  `Platform.pathSeparator`, so it passes on Windows and fails on Linux. It is a
  test portability issue, not an app defect. Left alone.

## Clunky parts I hit by using it

1. **Picking a tool does not close the tool drawer.** The expanded drawer is
   250px wide with a full-canvas invisible scrim behind it. After you tap
   "Freehand" the drawer stays open, and the next stroke you make on the photo
   is swallowed by the scrim. You have to tap once to dismiss, then draw. In
   the field that reads as "the app ignored me".
2. **Export silently downscales the photo.** Export captures the on-screen
   `RepaintBoundary` at the device pixel ratio and crops it. A 6000x4000 site
   photo displayed in a ~700pt canvas exports at roughly 700-2100px wide. The
   original resolution is thrown away.
3. **The colour preset does not control the colour.** "Style: Blue" draws blue
   dimension lines, **green** arrows, **orange** rectangles, **red** ellipses
   and **purple** freehand. Each tool has its own hard-coded hue inside each
   preset. Confirmed on screen: with Blue selected, a freehand stroke came out
   purple.
4. **No redo.** And "Undo" is not really undo: it deletes the highest-numbered
   annotation. It cannot undo a move, a resize, a text edit, a style change or
   a delete.
5. **No clear-all.**
6. **No stroke width control anywhere.** One weight for everything.
7. **No highlighter, no blur/pixelate, no callout numbers, no crop, no rotate.**
   Faces, plates and house numbers cannot be obscured.
8. **Freehand is raw.** Points are recorded every 4px and joined with straight
   segments. A one-handed line on a tablet comes out visibly shaky and faceted.
9. **Zoom is capped at 5x and cannot go below 100%.** You cannot zoom out to see
   a whole tall photo, and 5x is not enough to place a mark precisely on a
   6000px photo.
10. **The zoom panel sits on top of the photo,** top-right inside the canvas,
    over exactly the corner you often need.
11. **Pan is a mode you have to turn on,** and it is a separate toggle from the
    tool. Two-finger pan while a tool is active is not available.
12. **Text is a modal dialog.** You tap the photo, a dialog opens, you type,
    you press Save. There is no direct on-canvas typing and no size/contrast
    control at the point of use.
13. **Touch targets are small.** The collapsed rail is 54px wide with 42px tall
    buttons and no labels; the style indicator is an 8px dot. The zoom buttons
    are 38px. That is mouse-sized, not glove-sized.
14. **Bright white UI.** White canvas surround, a saturated cyan app bar, light
    grey sidebar. On a tablet in sun this is glare, and the chrome competes
    with the photo.
15. **Nothing is remembered.** Tool, colour, and in-progress markup are all lost
    if the app closes. There is no autosave.
16. **Two-step export.** Export always opens a save dialog. There is no
    one-tap "save next to the photo".
17. **The footer repeats the file name** that is already in the title bar.
18. **No keyboard shortcuts for tools.** Only Ctrl +/-/0 for zoom and
    Delete/Backspace for erase.
19. **EXIF orientation is ignored.** `Image.file` and `ui.ImageDescriptor` both
    read raw pixel dimensions; a phone photo saved with a rotation flag will
    display sideways.
20. **The startup splash is a hard 2.2 second delay** before the app is usable.

## Governance context found in the repo

`Governance/` and `Operations/` hold a documentation pack (constants policy,
file structure policy, versioning rules, validation matrices). The relevant
hard rules for code: keep tunables in the constants file, use two-part
versions (`v0.x`), and do not bump the version before owner approval. This run
follows the constants rule and does not bump `VERSION`.
