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
