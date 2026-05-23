# NCD Photo Markup

Document Path: `C:\apps\NCD_Photo_Markup\README.md`
Version: `v0.3`
Pack File Version: `v1.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Project entry point and setup for the Windows-first Flutter app.
Changes: Added Phase 1B image import setup and validation notes.

## Overview
NCD Photo Markup is a standalone Flutter field markup app. Current runtime supports opening a local photo into the canvas (Windows-first) with placeholder-only markup controls.

## Current Status
- Governance/documentation baseline exists (Phase 0).
- Flutter shell exists (Phase 1A).
- Open Photo imports and displays local image in canvas (Phase 1B).
- Markup/drawing tool behavior is still not implemented.

## Repository Layout
- Governance/docs root: `C:\apps\NCD_Photo_Markup`
- Flutter app root: `C:\apps\NCD_Photo_Markup\app`
- Temp artifacts: `C:\apps\NCD_Photo_Markup\.agent_temp`

## Run and Validate
From `C:\apps\NCD_Photo_Markup\app`:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build windows --debug`
- `flutter run -d windows --debug --no-resident`

Optional validation-only startup image preload:
- `flutter run -d windows --debug --no-resident --dart-define=NCD_STARTUP_IMAGE_PATH=[ABSOLUTE_IMAGE_PATH]`

## Dependencies Added in Phase 1B
- `file_selector` for Windows-compatible image picking.

## Version Rules
- Current version: `v0.3`
- Use two-part versions only (`v0.1`, `v0.2`, `v0.3`, `v0.4`, ...)
- Do not bump version before owner validation/approval.



