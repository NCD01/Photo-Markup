# DECISIONS

Every fork hit during the overnight run, what I chose, and why. Newest at the
bottom of each pass.

## Step 0: recon

- **Flutter was not installed.** Installed Flutter 3.47.0 stable to
  `/opt/flutter` rather than working blind. The repo pins Dart `^3.11.5`;
  3.47.0 ships Dart 3.13.0, which satisfies it.
- **The repo has no Linux desktop target,** so I could not run it here
  directly. Rather than add a `linux/` runner to his repo (platform folders he
  does not build and would have to maintain), I copied `app/` to a scratch
  directory outside the repo, ran `flutter create --platforms=linux` there, and
  ran that. The repo stays Windows/Android only.
- **`flutter pub get` rewrote `pubspec.lock` and `analysis_options.yaml`.**
  Reverted both. His lock file is what his Windows machine resolved; a lock
  churned by a different Flutter version is noise he did not ask for.
- **One pre-existing test fails on Linux** (`markup_export_path_service_test`
  asserts a `\` separator). It is a test portability issue and passes on his
  Windows target. Left it alone rather than "fixing" a test that is not broken
  on the platform he ships.

## Pass 1: features

- **Undo: snapshot history, not per-type edit commands.** Snapshotting every
  markup list on each edit means a new markup type costs one field in
  `MarkupSnapshot` and nothing at all in the undo path. Annotations are small,
  so the memory cost of 80 steps is trivial. The alternative, a command stack,
  would have needed an undo and redo implementation per type per operation.
- **Kept the six parallel typed lists.** They are the ugliest thing in the
  code, but rewriting them into one polymorphic list would have touched
  hit-testing, moving, resizing, saving, loading and every test, all at once,
  on a working app. Snapshot history gets the benefit (uniform undo across all
  types) without the risk. This is worth revisiting when there is time to test
  it properly.
- **One colour per preset, and kept NCD Blue as the default.** A tool-specific
  hue per preset was actively confusing (Blue drew purple freehand). Changing
  the default colour would have been a second surprise on top, so the default
  stays on brand and the auto-contrast halo is what makes every colour legible.
- **Auto-contrast halo rather than a "pick a colour that suits the photo"
  prompt.** Drawing every stroke twice costs nothing and removes a decision
  from the field.
- **Line is an arrow with no head; Highlighter is a freehand stroke with a
  flag.** Two more tools, no new lists, no new hit-testing, no new save/load
  code, no new undo code.
- **Markup file schema stays at version 1.0.** All new fields are optional on
  read. A file written tonight opens in the old build (it ignores what it does
  not know) and a file written by the old build opens here. Bumping the version
  would have made the reader reject every existing file, since it compares for
  exact equality.
- **Export stays PNG.** Full resolution was the requirement; changing the file
  format is a separate decision and it is his to make. Parked in QUESTIONS.md,
  because a full-resolution PNG of a 24MP phone photo is a big file to email.
- **Export scale is exportWidth / on-screen width.** That makes the export
  exactly what was on screen, just sharper. It does mean annotation weight
  depends on the window size at the moment of export, which is the WYSIWYG
  trade and the one a user can predict.
- **Blur, not pixelate.** One implementation that works properly beats two that
  half work. A heavy Gaussian is what actually obscures a face or a plate.
  On screen it is a BackdropFilter layer; on export the same regions are baked
  in with the same maths.
- **Rotation is baked into coordinates, not carried as a transform.** One
  rewrite at rotate time instead of a rotation term in every hit test forever.
- **Crop is cut.** Cropping needs the photo drawn from a decoded image rather
  than an `Image.file` widget, which is a rewrite of the one thing that must
  never break: showing the photo. Rotate covers the common real case (a phone
  photo saved sideways). See SUMMARY.md.
- **Deleted `marked_up_image_export_service`.** Nothing calls it now that
  export renders from the source file. Leaving a second, worse exporter in the
  tree is how someone wires the wrong one back up later.

## Pass 2: design

- **Bundled Barlow rather than using the platform font.** 250KB for three
  weights buys a consistent look on Windows and Android and a face that is not
  the same one every other app is wearing. SIL OFL, bundled not fetched, so the
  app still works with no network.
- **Kept NCD Blue as the accent, moved everything else dark.** The brand mark
  is still the brand mark; it just stopped being the background.
- **Rail pushes the canvas instead of floating over it.** This is the fix for
  the bug where the first stroke after picking a tool was swallowed by an
  invisible scrim. A layout shift is also easier to understand than a panel
  that appears over your work.
- **Switched the rail to one monochrome icon set, with the NCD artwork kept.**
  The NCD tiles were drawn for the light sidebar and cannot pick up the
  selected, disabled or destructive tint that now carries state, and there is
  no NCD artwork for the tools added tonight. `useNcdArtworkPack` in
  `sidebar_icon_pack.dart` switches back in one line. Asked about it in
  QUESTIONS.md.
- **Colour and width moved out of the Style dialog into the bottom bar.** They
  are the two things changed most often; a dialog for them is three taps for a
  one-tap decision. The dialog kept font, size, fill and callout style.
- **Dropped the footer that repeated the file name.** It was already in the
  header.
- **Contrast is asserted in tests rather than eyeballed.** Every text colour
  against every surface it sits on, plus every markup preset's chip.

## Pass 3: flow

- **Wrote preferences with dart:io rather than adding shared_preferences.** All
  that was needed was one writable folder path. APPDATA on Windows,
  XDG_CONFIG_HOME or ~/.config elsewhere, with a temp-dir fallback so a missing
  environment variable degrades to not remembering rather than crashing.
- **Autosave writes to a temporary name and renames.** A process that dies
  mid-write leaves the previous good draft instead of a truncated file.
- **Text Note and Callout are not restored as the active tool on launch.** Both
  create something on a single tap. Coming back into one would turn a stray tap
  on the photo into an annotation before the user decided anything. Every other
  tool needs a deliberate drag, so those are safe to restore.
- **Draft recovery is skipped when a photo was handed in on the command line.**
  Found while testing: the preferences load and the image load race, and the
  recovery dialog appeared over a photo Control Center had just opened. If
  there is a job in hand, a leftover draft waits.
- **Export became one tap, with Export As kept.** The save dialog was the
  slowest step in the loop and the answer was almost always "next to the
  photo". It never overwrites, so a second export is a second file.
- **Two-finger gestures abandon the stroke in progress rather than finishing
  it.** A second finger means pan or pinch. Finishing the stroke would leave a
  mark the user did not ask for, and undoing it is a step they should not have
  to take.
- **The double-tap guard is by position and time, not by a gesture
  recogniser.** A tap within 28px and a third of a second of the last one is a
  slip. A deliberate second pin somewhere else still lands immediately.

## Wildcards

- **Field Scale over a fixed unit setting.** A photo has no inherent scale; a
  known object in it does. Calibrating from something in the shot is the only
  honest way to get real numbers, and it is one drag.
- **Scale is normalised against the diagonal, not the width.** Normalising
  against width makes vertical measurements wrong on any photo that is not
  square. This cost nothing and is covered by a test.
- **Marker Mode's wobble comes from the annotation id, not a random number.**
  A random wobble would crawl while it is on screen and would produce a
  different export from what the user saw. Deterministic noise fixes both.
- **Marker Mode is off by default and Field Scale changes nothing until
  calibrated.** Neither alters an export unless it was deliberately turned on.

## Verification

- **Widget tests are the primary harness, screenshots the secondary one.**
  The repo has no Linux target, so the running app used for screenshots is a
  scratch copy outside the repo. A widget test drives the real widget tree, the
  real painter and real files, and it is repeatable, so that is where the
  correctness claims are made. Screenshots are how the design was judged.
- **Left the one pre-existing Linux test failure alone.**
  `markup_export_path_service_test` asserts a `\` separator, which is right on
  the platform he ships. "Fixing" it would be changing a correct test to suit a
  machine he does not use.
