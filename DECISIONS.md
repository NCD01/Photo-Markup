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
