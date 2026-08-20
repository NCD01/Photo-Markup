# SUMMARY

What happened overnight. Read this first, then DECISIONS.md, then QUESTIONS.md.

The app runs. Every commit runs. Tags let you roll back to any point.

---

## 1. Assumptions I made because you were asleep

1. **Windows is the target.** The repo says Windows first, Android later, so
   every layout decision was made for a Windows tablet. Android was not tested.
2. **The markup file format must stay compatible.** I added fields but kept
   schema version 1.0 and made everything new optional on read, so a file
   written tonight still opens in your current build and the other way round.
   Bumping the version would have made the reader reject every file you have.
3. **NCD Blue stays the brand and the default colour.** I retuned it for
   contrast on photos but did not replace it. Safety Orange is the one that
   reads on the widest range of backgrounds, so it is offered but not forced.
4. **Full resolution matters more than file size.** Export now writes at the
   photo's own pixel size. That produces large PNGs. I did not switch the
   format to JPEG because that needs a new dependency and it changes what you
   hand clients. Question 1.
5. **You want fewer taps more than you want a settings screen.** Tool, colour
   and width are remembered between runs, and export writes next to the photo
   without asking. Both are reversible if you disagree.
6. **A stray mark is cheaper than a missing tool.** The app reopens in the tool
   you last used, so it is ready to draw. Undo is real now, so a stray mark
   costs one key. Tools that create something on a single tap are deliberately
   excluded from that. Question 8.
7. **Your custom sidebar icons could be replaced by a consistent set.** They
   cannot be tinted, so on the dark rail they cannot show active, disabled or
   destructive state, and there was no artwork for the new tools. Your artwork
   is still in the repo and one constant switches it back. Question 6.
8. **Governance rules still apply.** Tunables stayed in the constants file, the
   version file was not bumped (you approve versions), and no analytics,
   accounts, sync or monetisation were added.

---

## 2. What is new, by pass

### Pass 1: features (tag `pass-1-features`)

**The big one: export at full resolution.** Export used to screen-grab the
canvas widget and crop it, so a 6000x4000 site photo came out at roughly
whatever the canvas happened to be, often under 1000px wide. It now decodes the
source photo, paints it at its own pixel size, and runs the same drawing code
over it scaled up by the same factor. What lands in the file is what was on
screen, at the resolution the camera captured. The success message states the
exported pixel size, so a downscale could never be silent again.

**Real undo and redo.** Undo used to delete the highest-numbered annotation and
nothing else: it could not undo a move, a resize, a text edit, a style change
or a delete, and there was no redo. It is now a snapshot history covering every
one of those, plus rotation, eighty steps deep. A whole drag is one step.

**Picking a colour now picks the colour.** Every preset used to carry a
different hue per tool, so "Style: Blue" drew blue dimensions, green arrows,
orange rectangles, red ellipses and purple freehand. One colour per preset now.
Added Safety Orange and Hi-Vis Green.

**Stroke width**, four weights, applied to every tool at once.

**An auto-contrast outline behind every stroke.** Dark behind a light stroke,
light behind a dark one. This is why yellow now reads on a concrete slab and
black reads on asphalt without you thinking about the background.

**New tools:** Line, Highlighter, Callout pins (auto-numbered or lettered, for
punch lists), Blur (faces, plates, addresses), filled shapes.

**Freehand smoothing.** Tremor is dropped and corners rounded when you lift, so
a one-handed line comes out clean. The ends stay exactly where your finger did.

**Rotate left and right**, baked into the stored coordinates so everything
downstream keeps working, and undoable together with the marks.

**Clear All** behind a confirmation, as one undo step. **Zoom to 12x** instead
of 5x.

### Pass 2: design (tag `pass-2-design`)

**Dark, high-contrast, built on one set of tokens.** The photo is now the
brightest thing on screen. The white canvas box and saturated cyan bar are
gone. Barlow is bundled as the UI face so it looks the same everywhere and
needs no network.

**The rail no longer covers the photo.** Expanding it narrows the canvas
instead of floating a panel over the image. This also fixed a real bug: the old
expanded drawer had an invisible full-canvas scrim behind it, so after picking
a tool your first stroke on the photo was swallowed and the drawer stayed open.
I hit that within a minute of first using the app.

**Touch targets from 42px to 56px**, icons from 21px to 26px.

**A status bar that always states tool, colour, width, scale and zoom**, and
changes any of them in one tap. Colour and width used to be three taps into a
dialog, and stroke width did not exist. The zoom controls moved off the corner
of the photo where they used to sit on the part you were marking up.

Contrast ratios and the layout at four window sizes, including your documented
1024x768 minimum, are asserted in tests rather than eyeballed.

### Pass 3: flow (tag `pass-3-flow`)

**Launch to first mark: seven interactions, now four.**

| | Before | After |
|---|---|---|
| Splash | 2.2s, unskippable | 1.1s, tap to skip, skipped entirely when a photo is handed in |
| Open the photo | tap hamburger, tap Open Photo, pick file | tap the big Open Photo button, pick file |
| Pick a tool | tap hamburger, tap the tool | tap the tool, or press its key |
| Start drawing | tap once more to dismiss the drawer that ate your first stroke | draw |
| **Total** | **7 taps** | **4 taps** |

On the second photo of the day it is three, because the tool, colour and width
you were using are already set.

**Never losing work.** Markup autosaves three seconds after the last edit, and
immediately when the app is backgrounded, the screen locks or the window
closes. It is written to a temporary name and renamed, so a process that dies
mid-write leaves the previous good draft rather than a broken file. Next launch
offers to restore it. Saving or exporting clears the draft.

**One-tap export.** Writes next to the photo, named after it, never
overwriting. Export As still opens the dialog.

**Keyboard shortcuts** for every tool and command. **Two-finger pan and pinch**
mid-tool. **A double-tap guard** so a fumbled tap does not stack two pins.

---

## 3. What I cut, and why

- **Crop.** It needs the photo drawn from a decoded image instead of the
  current image widget, which is a rewrite of the single thing that must never
  break: showing the photo. Rotate is in and covers the sideways phone photo,
  which is the common real case. Question 3.
- **Pixelate, as a separate tool from blur.** One good blur beats two half-done
  effects. A heavy Gaussian is what actually obscures a face or a plate.
- **A JPEG export option.** It needs a new dependency and it changes what you
  hand clients. Question 1.
- **Rewriting the six parallel markup lists into one.** It is the ugliest thing
  in the code, but rewriting it would have touched hit-testing, moving,
  resizing, saving, loading and every test at once, on a working app. The
  snapshot history gets the benefit (uniform undo across all types, and the
  next markup type costs one field) without the risk.
- **Fixing the one Linux test failure.** It asserts a Windows path separator
  and is correct on the platform you ship.
- **Drag and drop a photo onto the window.** Needs a plugin. I removed the copy
  that promised it rather than shipping a promise with nothing behind it.

---

## 4. The two wildcards

### Field Scale

Drag the Set Scale tool across something whose size you know: a four-foot
level, an eight-foot stud, a 36-inch door, a course of brick. Type what it is.
Every dimension line you draw on that photo afterwards opens its label already
filled in with the measured length.

**Why.** You are a contractor with a dimension tool that makes you type every
number. This is the thing that turns a photo into a document you can measure
from. CompanyCam, Fieldwire and iOS Markup do not ship it, which is what makes
it a wildcard rather than a checklist item, but it is the least gimmicky
feature in the run. It parses `8`, `8"`, `4'`, `6'2"`, `6-2` and `6 2`, because
that is the range of ways a length actually gets written down.

It measures against the photo's diagonal rather than its width, so a vertical
or diagonal measurement is as correct as a horizontal one. It saves in the
markup file. It changes nothing until you calibrate, and clearing it is one
tap.

The honest caveat, which is in the README: accuracy is only as good as the
reference and the camera angle. Something in the same plane, shot square on, is
close. A steep angle is not, and no software fixes that.

### Marker Mode

Renders every stroke as if drawn by hand: a slight wobble, corners that
overshoot, a second lighter pass that gives lines an inked look.

**Why.** A perfectly straight machine line on a client's photo reads as a
decision that has already been made. The same line drawn with a marker reads as
a suggestion. That is a real difference in how a homeowner receives a photo,
and it costs nothing to offer. Use the machine line for a punch list going to a
sub, and the marker for an idea going to a client.

It is off by default because it changes what an export looks like. The wobble
is derived from each annotation's own id, never from a random number, so lines
do not crawl while they are on screen and the export is identical to what you
saw.

---

## 5. What I confirmed by running versus by reading

I installed Flutter 3.47.0 (it was not on the machine), and because the repo
has no Linux target I ran the app from a scratch copy of `app/` outside the
repo with a Linux runner added. Screenshots were taken from that running app
under Xvfb. Everything else was verified with tests that drive the real widget
tree, the real painter and real files on disk.

**CONFIRMED BY RUNNING (the app, on screen, with screenshots):**

- The app launches, loads a photo, and draws with freehand, highlighter,
  rectangle, ellipse, arrow, dimension, callout pins and blur.
- The old drawer swallowed the first stroke after picking a tool. Reproduced,
  then fixed, then re-checked.
- Blur really blurs the photo on screen.
- Callout pins auto-increment 1, 2, 3, 4.
- Rotating a portrait photo turns the photo and the marks together, with the
  corner markers ending up where a clockwise turn puts them.
- Field Scale: calibrated the full width of a photo as 8 feet, drew a line
  across half of it, and the label dialog opened pre-filled with `4'-0"`.
- Marker Mode changes rectangles, ellipses, arrows and freehand into
  hand-drawn strokes, fill included.
- Crash recovery: killed the app with unsaved markup, relaunched, and it
  offered to restore the work on the right photo.
- One-tap export via Ctrl+E writes `<photo name> - Markup.png` next to the
  photo.
- A photo with an EXIF rotation flag displays rotated and exports rotated, at
  the oriented pixel size, with the annotation in the right place. Verified by
  reading the exported pixels.

**CONFIRMED BY RUNNING (automated, driving the real widget tree):**

223 tests pass on Windows. The ones that carry the important claims:

- Every tool draws, all twelve marks save to a markup file, and reopening it
  returns every mark identical.
- Select, move, resize and delete a mark after drawing it; undo brings it back.
- Zooming in and back out does not move a single mark.
- A 6000x4000 photo exports at 6000x4000. A 1500x2400 portrait exports at
  1500x2400. A rotated photo exports with its axes swapped.
- Annotations land on the same part of the photo in the export as on screen,
  checked by reading exported pixels, and their thickness scales with the photo
  instead of coming out hairline.
- A blur region really destroys detail in the exported pixels: the contrast
  range inside it collapses while the untouched half still swings full black to
  white, and it stays destroyed at an 8x export scale.
- Selection handles never appear in an export.
- Undo and redo across create, move, erase and clear-all.
- Autosave round trip, including a corrupt file, a moved photo and a
  half-written draft.
- Preferences persist and a tap-to-create tool is not restored.
- One-tap export does not open a dialog and does not overwrite.
- Tool shortcut keys, escape, bracket rotation, Ctrl+Z and Ctrl+Shift+Z.
- The double-tap guard, and two-finger gestures not leaving a mark.
- Contrast ratios for every text colour on every surface, and no layout
  overflow at 1024x768, 1280x800, 1920x1080 and a portrait tablet.
- The rail moves the canvas rather than covering it.

**VERIFIED BY READING CODE ONLY:**

- The Windows and Android release builds. `flutter analyze` and the whole test
  suite have since been run on the Windows machine and both are clean, but
  `flutter build windows --release` has not been produced, and Android has not
  been touched at all. The code is platform-neutral Dart and Flutter and no
  platform channel or native file changed.
- HEIC and DWG import. The existing services and their tests are untouched and
  still pass, but I had no HEIC or DWG file to open.
- The Control Center launch handshake. Its tests still pass and the argument
  parsing is unchanged; I did not run Control Center.
- File picker dialogs. The open and save dialogs come from `file_selector` and
  were exercised only through the injection points the app already had.
- Behaviour on a real touchscreen. Multi-touch was tested with synthetic
  pointers, not fingers.

**FINAL CHECK, ON A FRESH CLONE:**

After the last commit I cloned the branch into a clean directory, built from
that clone, and ran the whole flow again on a build made from nothing but what
is pushed:

- First launch with no saved settings at all: opens to the dark empty state,
  Arrow ready, blue, medium width.
- Portrait photo: arrow, rectangle, circle, freehand, highlighter, line, two
  callout pins, blur, text note, dimension, all drawn and all correct.
- Field Scale calibrated at 8'-0" across a known width, then a second line drawn
  at half that length pre-filled as 4'-0". Right answer.
- Undo twice, redo twice, both correct.
- Selected an ellipse, moved it, resized it by a corner handle, selected the
  blur and deleted it.
- Zoomed to 200 percent, drew an arrow while zoomed, returned to fit. The mark
  stayed on the same part of the photo.
- Marker Mode on, then exported: the file is 1200x1600, the same size as the
  source, and the wobble in the export matches the wobble that was on screen.
- 6000x4000 photo: opened, marked, killed with SIGKILL mid-session, relaunched.
  The app offered the draft by name, restored it, and exported at 6000x4000 with
  the mark in the right place and all four corner markers intact.

**ONE TEST THAT ONLY PASSES ON WINDOWS:**
`markup_export_path_service_test > buildSafeMarkupExportPath appends increment
for duplicate output` fails on Linux and passes on Windows. It asserts a `\`
separator and the service builds paths with `Platform.pathSeparator`. It failed
the same way before I touched anything. Left alone. Running the suite on the
Windows machine afterwards gave 223 passed and none failed.

---

## 6. Rollback map

Every commit below leaves the app running. Roll back with
`git checkout <hash>`.

The three pass tags exist in the branch I built on, but this machine's push
credential is scoped to the branch ref only, so pushing tags came back 403 and
they did not reach GitHub. The hashes below are the same information. If you
want the tags back on your own machine, after pulling the branch run:

```
git tag pass-1-features 94a7b05
git tag pass-2-design c490148
git tag pass-3-flow claude/photo-markup-overnight-enjgup
```

| Commit | Tag | State |
|---|---|---|
| `3e4da98` | | **Where you left it.** v0.32, before the run. |
| `2dc227a` | | Baseline recon written. No app code changed. Identical behaviour to `3e4da98`. |
| `9d8df2e` | | Real undo and redo, clear-all. Everything else unchanged. |
| `d97a6b8` | | One colour per preset, stroke width, contrast halo, Line, Highlighter, freehand smoothing, shared renderer. |
| `8e63fcd` | | Full-resolution export. **The single most important commit in the run.** |
| `998148f` | | Callout pins and blur. |
| `94a7b05` | `pass-1-features` | Rotate, wider zoom. **End of Pass 1: all the features, still the old light interface.** |
| `4dfc212` | | Pass 1 decisions and questions written. No code change. |
| `c490148` | `pass-2-design` | **End of Pass 2: dark interface, new toolbar, status bar.** Roll back to `pass-1-features` if you want the features without the redesign. |
| `f7a4cd9` | | Shortcuts, autosave, recovery, one-tap export, gestures. |
| `0fbc0d4` | | Field Scale and Marker Mode. |
| `ec09d3f` | | End-to-end verification tests. No behaviour change. |
| `78b9622` | | README rewritten, logs finished. No code change. |
| branch tip | `pass-3-flow` | **End of the run.** The morning report and this verification. |

If something is wrong in the morning and you need the app working in thirty
seconds: `git checkout 3e4da98`. If the features are fine but you hate the dark
interface: `git checkout 94a7b05`.

---

## 7. Open questions

Ten of them, in QUESTIONS.md, each with the specific answer I need. The three
worth reading first:

1. **Export file size.** Full-resolution PNG of a 24MP phone photo is tens of
   megabytes. Do you want a JPEG option, and should it be the default?
2. **Your sidebar icons.** They are still in the repo but not in use, for a
   mechanical reason (they cannot be tinted, so they cannot show state). Do you
   want them back?
3. **Starting in a drawing tool.** The app now reopens ready to draw. That
   saves a tap and risks a stray mark. Is that the trade you want?

The rest cover crop, EXIF on a real camera file, the default colour, dimension
labels in feet versus inches, Android, and how big a photo you realistically
open.
