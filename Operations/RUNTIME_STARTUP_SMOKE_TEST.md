# Runtime Startup Smoke Test

Document Path: `C:\apps\NCD_Photo_Markup\Operations\RUNTIME_STARTUP_SMOKE_TEST.md`
Version: `v0.2`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Define and record runtime startup validation evidence.
Changes: Recorded successful Phase 1A startup run and screenshot evidence.

## Startup Contract
| Item | Value |
|---|---|
| App Name | `NCD Photo Markup` |
| Platform/Device | `Windows` |
| Launch Command/Method | `cd app && flutter run -d windows --debug --no-resident` |
| Expected First Screen/Scene/Route | `Shell screen with app bar, canvas placeholder, and toolbar placeholders` |
| Required Startup Assets/Files | `app/lib/main.dart and default Flutter shell assets` |
| Required Startup Services | `None in Phase 1A` |
| Expected Startup Log Message | `Syncing files to device Windows...` |
| Log Source Reviewed | `Flutter run terminal output` |
| Screenshot Required | `YES` |
| Owner | `NCD / M` |

## Latest Run
- Date: 2026-05-22
- Run By: Codex
- Platform/Device: Windows
- Launch Command/Method: `cd app && flutter run -d windows --debug --no-resident`
- Expected First Screen/Scene/Route: Shell UI
- Actual Result: App built and launched successfully
- Log Source Reviewed: Flutter run/build terminal output
- Blocking Errors Found: None
- Result: PASS
- Evidence Path: `C:\apps\NCD_Photo_Markup\.agent_temp\screenshots\phase1a_shell_startup.png`

