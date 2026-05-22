# NCD Photo Markup

Document Path: `C:\apps\NCD_Photo_Markup\README.md`
Version: `v0.1`
Pack File Version: `v1.5`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Project entry point and setup for the Windows-first Flutter shell.
Changes: Added Phase 1A Flutter shell setup/run details.

## Overview
NCD Photo Markup is a standalone Flutter field markup app. Phase 1A establishes a Windows-first shell with touch-friendly placeholders only.

## Current Status
- Governance/documentation baseline exists (Phase 0).
- Flutter shell created in `app/` (Phase 1A).
- No markup/drawing behavior implemented yet.

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

## Version Rules
- Current version: `v0.1`
- Use two-part versions only (`v0.1`, `v0.2`, ...)
- Do not bump version before owner validation/approval.
