# QUESTIONS

Things I could not resolve without you. Each one says the specific answer I
need. Nothing here is blocking; I made a call and kept going, and the call is
stated so you can reverse it cheaply.

## 1. Should export offer JPEG as well as PNG?

Export now writes at the photo's real resolution, which is what you asked for
implicitly by taking 24MP photos. The side effect is file size: a full
resolution PNG of a 6000x4000 photo can be 30 to 80MB, which is awkward to
email to a client from a job site on a phone hotspot.

**What I need:** do you want a JPEG option (roughly 2 to 5MB at the same pixel
size, with a small quality loss), and if so should it be the default, an option
in the save dialog, or a setting? I did not add one because Flutter cannot
encode JPEG without a new dependency, and adding a dependency to change your
default output format is not a call I should make while you are asleep.

## 2. Is the export meant to match the window, or the photo?

Annotation thickness in the export is scaled by exportWidth / on-screen width,
so the export is exactly what you saw, just at full resolution. That means if
you mark up with the window small and then maximise it, the same annotation
would export slightly thinner. The alternative is to define stroke widths as a
fraction of the photo, which is stable across window sizes but no longer
matches what is on screen.

**What I need:** which matters more to you, that the export matches the screen,
or that two photos marked up on different days come out with identical line
weights?

## 3. Crop

I did not build it. It needs the photo drawn from a decoded image instead of
the current image widget, which is a rewrite of the single thing that must
never break. Rotate is in, which covers sideways phone photos.

**What I need:** do you actually crop on site, or was that mostly about
straightening sideways photos? If you do crop, is it "cut off the parked car at
the edge" (a simple rectangle) or something more?

## 4. EXIF orientation

Flutter reads the raw pixels and does not apply the rotation flag some cameras
write. I could not test this properly because I had no camera-original photo
with a rotation flag set. Rotate covers it manually, but it should probably be
automatic.

**What I need:** send me one photo straight off your phone that shows up
sideways, and I can make the import read the flag.

## 5. Default colour

The presets are now Blue (default), Orange, Red, Yellow, Green, White, Black,
and every tool draws in the chosen colour. Safety Orange is the one that reads
on the widest range of backgrounds. Blue is on brand.

**What I need:** do you want Orange as the default instead of NCD Blue? One
line to change.

## 6. The sidebar icons

Your NCD icon pack is still in the repo but the rail now uses a single
monochrome set. The reason is mechanical rather than aesthetic: the NCD tiles
are full-colour artwork that cannot be tinted, so on the dark rail they cannot
show which tool is active, which command is unavailable, or which one is
destructive. There is also no NCD artwork for the seven tools added tonight, so
the rail was half tiles and half glyphs.

**What I need:** do you want the NCD pack back? If yes, flip
`SidebarIconRegistry.useNcdArtworkPack` to true, and either accept that the new
tools use glyphs or send me artwork for Line, Highlighter, Callout, Blur, Set
Scale, Redo, Clear All, Rotate and Marker Mode. If you would rather keep one
consistent set, nothing to do.

## 7. Dimension labels are still normalised to inches

Your existing formatter turns `6'-0"` into `72"`, and its tests assert that. I
left it alone, so a Field Scale measurement that computes as `4'-0"` is stored
and displayed as `48"`. On a 20-foot wall that reads as `240"`.

**What I need:** should long dimensions display as feet and inches instead? It
is a small change to `DimensionLabelFormatter`, but it changes existing
behaviour and two of your tests, so it is your call.

## 8. Should the default tool on launch be Arrow?

The app now reopens with whatever tool you last used, and a fresh install
starts on Arrow. That means opening a photo puts you straight into drawing,
which saves a tap, but it also means a stray drag on the photo makes a mark.
It is undoable, and tap-to-create tools are deliberately excluded.

**What I need:** is starting in a drawing tool right, or would you rather it
always start in select mode and you pick a tool deliberately?

## 9. Android

The repo has an Android runner. Nothing tonight was tested on it, only on the
Windows-shaped desktop layout. The bottom status bar and the 56px targets
should suit a tablet better than the old rail did, but a phone-width screen
will make the status bar scroll horizontally and I do not know whether that
feels right in your hand.

**What I need:** are you actually running this on the Samsung tablet yet, or is
Windows still the only target? If Android matters, I would want to lay the
status bar out differently below a certain width.

## 10. What happens to a very large photo

The full-resolution export decodes the whole photo into memory. A 6000x4000
photo is tested and fine. A 100-megapixel panorama or a stitched drone image is
not tested and could run the tablet out of memory.

**What I need:** what is the biggest file you would realistically open? If
anything above about 50MP is plausible, the exporter should cap and say so
rather than trying and failing.
