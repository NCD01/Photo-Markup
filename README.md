# NCD Photo Markup

A markup tool for site photos. You take a photo on a job, open it here, draw on
it, and send it out. It is built for one situation: a tablet held in one hand,
outdoors, in daylight, by someone wearing gloves.

Windows is the primary target. There is an Android runner in the repo as well.

---

## Run it

You need the Flutter SDK. From `app/`:

```
flutter pub get
flutter run -d windows --debug
```

Other commands you will want:

```
flutter analyze                 # static analysis
flutter test                    # the full test suite
flutter build windows --release # a build to hand out
```

Build from a local drive. A checkout on a network share fails during the
Windows build because the Flutter plugin step cannot create the symlinks it
needs there. Keep a working copy on `C:\` and build from that.

The app can also be launched with a photo already open, which is how NCD
Control Center starts it:

```
ncd_photo_markup.exe --sourceImagePath="C:\Jobs\Smith\IMG_2434.jpg"
```

It accepts `--clientName`, `--projectCode`, `--sourceLabel`,
`--suggestedExportFolder`, `--suggestedEditableMarkupFolder`,
`--launchedFromControlCenter` and `--launchContextPath` (a JSON file carrying
the same fields). Anything it does not recognise is ignored.

---

## Using it

Open a photo, pick a tool, draw. That is the whole thing.

The rail down the left edge holds the tools. It never covers the photo:
expanding it narrows the canvas instead of floating a panel over the image. The
bar along the bottom always states which tool, which colour and which stroke
width are active, and changes any of them in one tap.

### Tools

| Tool | What it does |
|---|---|
| **Open Photo** | Loads a JPG, PNG, WEBP, HEIC/HEIF or DWG. HEIC is converted for display and cached. DWG uses an embedded preview or a configured offline converter. |
| **Open Markup** | Reopens a saved `.ncdmarkup.json` file with all its marks still editable. |
| **Save Markup** | Writes that editable file. It references the photo rather than copying it. |
| **Export** | One tap. Writes a flattened PNG next to the photo, named after it, at the photo's own resolution. Never overwrites: a second export becomes `... 2.png`. |
| **Export As...** | The same, but you choose where it goes. |
| **Dimension** | Drag a measured line with end ticks, then label it. The label can be dragged away from the line and a leader is drawn to it. |
| **Text Note** | Tap the photo and type. Sits in a chip so it reads on any background. |
| **Arrow** | Drag. Point at the thing. |
| **Line** | An arrow with no head. |
| **Rectangle** | Drag a box. Outline or filled. |
| **Circle** | Drag an ellipse. Outline or filled. |
| **Freehand** | Draw with a finger or a pen. The stroke is cleaned up when you lift, so a shaky one-handed line comes out smooth. |
| **Highlighter** | A wide translucent stroke that sits under everything else, so it emphasises without hiding. |
| **Callout** | Tap to drop an auto-numbered pin. For punch lists. Numbers or letters. |
| **Blur** | Drag a box over a face, a plate, an address or a name. The photo underneath is blurred, on screen and in the export. |
| **Set Scale** | See "Field Scale" below. |
| **Style** | Font, size, fill on/off, and how callouts are labelled. Colour and width live in the bottom bar. |
| **Undo / Redo** | Real multi-step, covering draws, moves, resizes, deletes, text edits, style changes and rotation. |
| **Erase** | Deletes the selected mark. |
| **Clear All** | Removes everything, after asking. One undo brings it all back. |
| **Rotate Left / Right** | Turns the photo and every mark on it. |
| **Marker Mode** | See "Marker Mode" below. |

### Editing what you drew

Press `V` or tap the active tool again to go back to select mode. Then:

- Tap a mark to select it.
- Drag it to move it.
- Drag a corner or an end handle to resize or reshape it.
- `Delete` removes it, or use Erase.
- Tap a selected text note to edit its text; tap a selected dimension label to
  change the label.
- With something selected, changing the colour or width in the bottom bar
  applies to that mark rather than to the next one you draw.

### Colour, width and contrast

Seven colours: NCD Blue, Orange, Red, Yellow, Green, White, Black. Every tool
draws in the colour you picked.

Four widths: Fine, Medium, Bold, Heavy. They multiply every tool's weight, so
one setting covers arrows, boxes, freehand and dimensions.

Every stroke is drawn with a contrast outline behind it, dark behind a light
stroke and light behind a dark one. That is why yellow reads on a concrete slab
and black reads on asphalt without you thinking about the background.

### Zoom and pan

Zoom runs from fit to 12x. Two fingers on the photo pan and pinch even while a
drawing tool is active; the stroke in progress is dropped rather than turned
into a stray mark. There is also a pan toggle in the bottom bar for mouse use,
and `Ctrl` plus the scroll wheel zooms.

Marks are stored against the photo, not the screen, so zooming, resizing the
window and reopening the file never move them.

### Field Scale

Pick **Set Scale** and drag across something whose size you know: a four-foot
level, an eight-foot stud, a 36-inch door, a course of brick. Type what it is.

From then on, every dimension line you draw on that photo opens its label
already filled in with the measured length, so you accept it instead of typing
it. It reads `8`, `8"`, `8 in`, `4'`, `4 ft`, `6'2"`, `6-2` and `6 2`.

The reference is measured against the photo's diagonal, so a vertical or
diagonal measurement is as correct as a horizontal one. It is saved in the
markup file. Tap the Scale readout in the bottom bar to change or clear it.

Accuracy is only as good as the reference and the camera angle. Something in
the same plane as what you are measuring, photographed square on, is close.
Something at a different depth or a steep angle is not, and no software fixes
that.

### Marker Mode

Renders every stroke as if drawn by hand: a slight wobble, corners that
overshoot, and a second lighter pass that gives lines an inked look.

A perfectly straight machine line on a client's photo reads as a decision that
has already been made. The same line drawn with a marker reads as a suggestion.
Use it for the homeowner, not for the sub.

It is **off by default** because it changes what an export looks like. It is
under Photo in the rail.

### Never losing work

In-progress markup is autosaved three seconds after the last edit, and
immediately when the app is backgrounded, the screen locks or the window is
closing. If the app dies, the next launch offers to restore it. Saving a markup
file or exporting clears the draft, because the work is safe by then.

An amber dot next to the file name in the header means there are unsaved
changes.

Your tool, colour, width, fill setting, callout style and rail state are
remembered between runs, so the second photo of the day needs no setting up.

---

## Keyboard shortcuts

| Key | Action |
|---|---|
| `V` | Select mode |
| `D` | Dimension |
| `T` | Text Note |
| `A` | Arrow |
| `L` | Line |
| `R` | Rectangle |
| `C` | Circle |
| `F` | Freehand |
| `H` | Highlighter |
| `N` | Callout pin |
| `B` | Blur |
| `Esc` | Leave the current tool, or clear the selection |
| `Delete` / `Backspace` | Delete the selected mark |
| `Enter` | Edit the selected dimension's label |
| `Ctrl+Z` | Undo |
| `Ctrl+Shift+Z` or `Ctrl+Y` | Redo |
| `Ctrl+O` | Open a photo |
| `Ctrl+S` | Save the markup file |
| `Ctrl+E` | Export next to the photo |
| `Ctrl+Shift+E` | Export As |
| `[` / `]` | Rotate left / right |
| `Tab` | Show or hide the tool labels |
| `Ctrl` `+` / `-` / `0` | Zoom in, out, fit |

Keys are ignored while a text field has focus, so typing a note does not switch
tools.

## Gestures

| Gesture | Action |
|---|---|
| One finger on the photo | Draw with the active tool, or select and move in select mode |
| Two fingers on the photo | Pan and pinch to zoom, even mid-tool |
| Swipe right on the rail | Show the tool labels |
| Swipe left on the rail | Collapse back to icons |
| Tap the splash | Skip it |

A second tap in the same place within a third of a second is treated as a slip,
so a fumbled tap does not stack two pins or open two note dialogs.

---

## Architecture

```
app/lib/
  main.dart                            The shell: state, gestures, layout.
  core/
    constants/app_constants.dart       Every tunable value and every string.
    theme/design_tokens.dart           Colours, spacing, type, motion, sizes.
  features/
    markup/
      models/                          One class per markup type. Coordinates
                                       are normalised 0..1 against the photo.
      models/markup_snapshot.dart      An immutable copy of all markup. Undo,
                                       redo and rotation all move these around.
      models/photo_scale.dart          Field Scale.
      models/editable_markup_document  The .ncdmarkup.json schema.
      rendering/markup_scene_renderer  All drawing. Used by the screen and by
                                       the exporter, so they cannot diverge.
      rendering/marker_mode.dart       The hand-drawn pass.
      services/markup_history.dart     Undo and redo stacks.
      utils/                           Hit tests, layout, smoothing, rotation.
      widgets/                         The interactive overlay, the blur layer.
    export/services/
      full_resolution_export_service   Decodes the source photo and paints the
                                       scene onto it at full size.
      markup_export_path_service       Default names, duplicate-safe paths.
    import/services/                   HEIC conversion with an on-disk cache,
                                       DWG preview extraction.
    session/                           Remembered settings, autosave, recovery.
    integration/                       Control Center launch arguments.
    sidebar/                           Toolbar icons.
    view/utils/                        Zoom and pan maths for the canvas.
```

### Where to change things

| To change | Go to |
|---|---|
| A colour, a size, a duration, a string | `core/constants/app_constants.dart` |
| How the app looks overall | `core/theme/design_tokens.dart` |
| How a mark is drawn | `features/markup/rendering/markup_scene_renderer.dart` |
| What lands in an exported PNG | `features/export/services/full_resolution_export_service.dart` |
| What is saved in a markup file | `features/markup/models/editable_markup_document.dart` |
| Which tools appear and in what order | `ToolbarConstants` in the constants file |
| A tool's icon | `features/sidebar/models/sidebar_icon_pack.dart` |
| Keyboard shortcuts | `_onShellKeyEvent` in `main.dart` and `KeyboardShortcutConstants` |

### Two things worth knowing before you change anything

**Coordinates are normalised.** Every mark stores its position as a fraction of
the photo, not as pixels. That is what keeps marks anchored when the window
resizes, when you zoom, and when a file is reopened on a different screen. If
you add a markup type, store normalised coordinates.

**One renderer.** `MarkupSceneRenderer` draws both the screen and the export.
It takes an image rectangle and a scale factor: on screen the rectangle is the
fitted photo and the scale is 1; on export the rectangle is the photo's real
pixel size and the scale is how much bigger that is. Do not add a second
drawing path, or the export will stop matching the screen.

### Markup file format

`.ncdmarkup.json`, schema version 1.0. It references the source photo by path
rather than embedding it, records the photo's pixel size, the rotation, the
scale calibration, and every mark with its normalised coordinates.

Fields added after 1.0 shipped are optional on read, so a file written by a
newer build still opens in an older one and the other way round. Keep it that
way: adding an optional field is safe, changing the meaning of an existing one
is not.

### Dependencies

- `file_selector` for the native open and save dialogs.
- `heic_to_png_jpg` for HEIC decoding, with an ImageMagick fallback if it is
  on the machine.
- `cupertino_icons`.

Nothing was added tonight except a bundled font. The app has no network calls
and works entirely offline, which is the normal condition on a job site.

The UI font is Barlow, bundled in `app/assets/fonts/` under the SIL Open Font
License, so the app looks the same on every machine and needs no network.

---

## Known limitations

- **No crop.** Cropping needs the photo drawn from a decoded image rather than
  an image widget, which is a rewrite of the one thing that must never break.
  Rotate covers sideways phone photos, which is the common case.
- **Exports are PNG only.** At full resolution, a PNG of a 24MP phone photo can
  be tens of megabytes, which is awkward to email from a job site. A JPEG
  option needs a new dependency.
- **Annotation weight follows the window.** The export matches what was on
  screen, so marking up in a small window and then maximising it would export
  slightly thinner lines. Predictable, but worth knowing.
- **Dimension labels are normalised to inches.** Typing `6'-0"` stores `72"`.
  That is existing behaviour and Field Scale follows it.
- **EXIF orientation is handled by the platform decoder.** It behaved correctly
  in testing on a photo with a rotation flag, in both the display and the
  export, but it has not been checked against a real camera file.
- **Blur, not pixelate.** One good blur beats two half-done effects. It is a
  heavy Gaussian, which is what actually obscures a face or a plate.
- **The tests run on Windows and Linux, with one exception.**
  `markup_export_path_service_test` asserts a Windows path separator, so it
  fails on Linux and passes on Windows. It is a test portability issue, not an
  app defect.
- **Very large photos hold their full pixels in memory during export.** A
  6000x4000 photo is fine. Something far beyond that has not been tried.

---

## Changelog: the overnight run

Three passes. Every commit leaves the app running.

The pass tags are local to whoever ran the work; they were not pushed, because
the build machine's credential was scoped to the branch ref. To recreate them
after fetching the branch:

```
git tag pass-1-features 94a7b05
git tag pass-2-design c490148
git tag pass-3-flow claude/photo-markup-overnight-enjgup
```

### Pass 1: features (`pass-1-features`)

- Real multi-step undo and redo over whole-markup snapshots, covering draws,
  moves, resizes, deletes, text edits, style changes and rotation. Replaced an
  "undo" that only deleted the highest-numbered annotation and had no redo.
- Clear All behind a confirmation, as a single undo step.
- One colour per preset. Every preset used to carry a different hue per tool,
  so "Blue" drew blue dimensions, green arrows, orange boxes and purple
  freehand. Added Orange and Green; retuned the rest for site photos.
- Stroke width: Fine, Medium, Bold, Heavy, applied to every tool.
- An auto-contrast outline behind every stroke, so any colour reads on any
  photo.
- Two new tools that cost no new machinery: Line (an arrow with no head) and
  Highlighter (a freehand stroke drawn wide, translucent and underneath).
- Callout pins, auto-numbered or lettered, for punch lists.
- A blur tool for faces, plates and addresses, baked into the export.
- Freehand smoothing: tremor is dropped, corners are rounded, the ends stay
  where the finger did.
- **Export at the photo's own resolution.** It used to screen-grab the canvas,
  so a 6000x4000 photo came out under 1000px wide. It now decodes the source
  and paints the same scene onto it at full size.
- Rotate left and right, baked into the stored coordinates so everything
  downstream works unchanged.
- Zoom to 12x instead of 5x.
- Filled rectangles and ellipses.

### Pass 2: design (`pass-2-design`)

- A dark, high-contrast interface built on one set of design tokens.
- Barlow bundled as the UI face.
- The rail no longer covers the photo. Expanding it narrows the canvas rather
  than floating a panel over the image, which is what used to swallow the first
  stroke after picking a tool.
- Touch targets from 42px to 56px, icons from 21px to 26px.
- A status bar that states tool, colour, width, scale and zoom at all times and
  changes any of them in one tap.
- The zoom controls moved off the corner of the photo.
- One icon system, tinted by state.
- Contrast ratios and layout at four window sizes are asserted in tests.

### Pass 3: flow (`pass-3-flow`)

- Launch to first mark went from seven interactions to four, and to three on
  the second photo of the day.
- The splash is skippable, shorter, and skipped entirely when a photo was
  handed in.
- Tool, colour, width and the rest are remembered between runs.
- Autosave and crash recovery.
- One-tap export next to the photo; Export As for choosing.
- A full keyboard shortcut set.
- Two-finger pan and pinch mid-tool, and a double-tap guard.
- Two wildcards: **Field Scale** and **Marker Mode**.

Test count went from 93 to 223. All 223 pass on Windows. On Linux one of them
fails, `markup_export_path_service_test`, because it asserts a Windows path
separator.

---

## Something for later

Press the version number in the top-right corner seven times inside three
seconds.

It is a 12pt label in the corner of the header, nowhere near the photo or any
control, and it takes seven presses. It does not touch your photo, your markup
or anything that gets exported. Dismiss it and carry on.
