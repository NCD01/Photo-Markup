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
