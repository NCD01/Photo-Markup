# Runtime Startup Smoke Test Template

Document Path: `<PRIMARY_PATH>/Operations/RUNTIME_STARTUP_SMOKE_TEST_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.3`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Define the minimum runtime launch proof required before an app can be called fully validated.
Changes: Linked startup validation to visual and responsive follow-up checks.

## Quick Rules
- Build success is not full validation.
- The app must launch and reach the required first screen, scene, route, workflow, or healthcheck before full green light.
- Runtime logs must be reviewed after launch.
- Missing assets, missing files, startup exceptions, and hard crashes are validation failures.

## Required Contract
| Field | Value |
|---|---|
| App Name | `<APP_NAME>` |
| Platform/Device | `<PLATFORM_OR_DEVICE>` |
| Launch Command/Method | `<COMMAND_OR_STEPS>` |
| Expected First Screen/Scene/Route | `<EXPECTED_STARTUP_STATE>` |
| Required Startup Assets/Files | `<LIST_OR_NONE>` |
| Required Startup Services | `<LIST_OR_NONE>` |
| Expected Startup Log Message | `<EXPECTED_LOG_OR_NONE>` |
| Log Source Reviewed | `<CONSOLE_LOG_FILE_DEVTOOLS_CI_LOG_OR_OTHER>` |
| Screenshot Required | `<YES_NO_OR_WHEN_AVAILABLE>` |
| Owner | `<OWNER>` |

## Required Result Format
```md
## Runtime Startup Smoke Test Result
- Date: <DATE_YYYY-MM-DD>
- Run By: <NAME_OR_AGENT>
- Platform/Device: <PLATFORM_OR_DEVICE>
- Launch Command/Method: <COMMAND_OR_STEPS>
- Expected First Screen/Scene/Route: <EXPECTED>
- Actual Result: <OBSERVED>
- Log Source Reviewed: <SOURCE>
- Blocking Errors Found: <NONE_OR_LIST>
- Result: <PASS|FAIL|NOT_RUN>
- Evidence Path: <PATH_OR_NONE>
```

## Blocking Error Patterns
The agent must check logs for:
- `Unhandled Exception`
- `EXCEPTION CAUGHT`
- `Unable to load asset`
- missing asset, missing file, or empty data
- missing configuration
- `MissingPluginException`
- `Null check operator used on a null value`
- `LateInitializationError`
- `FileSystemException`
- permission denied
- failed assertion
- first screen/scene failed to render
- hard crash or process exit
- blank screen that blocks required startup state

## Required Triggers
Run this smoke test after changes involving:
- app startup
- first screen, scene, route, or shell
- navigation/routing
- assets, images, fonts, maps, sprites, static files, or bundled resources
- configuration files or manifests
- platform setup
- dependency updates
- engine initialization
- data loading
- local storage, permissions, file paths, or seed files
- logging, error handling, or crash handling
- build scripts or packaging paths

## Green-Light Statement
If this test passes and every other required validation gate passes, the agent may report full validation.

If this test is required but not run, the agent must state:

```text
Build validation passed, but runtime startup validation was not performed. This is not a full green light.
```

## Verification Gate
- [ ] Startup command or method is defined.
- [ ] Expected first screen/scene/route is defined.
- [ ] Required assets/files/services are listed or marked none.
- [ ] Log source is defined and reviewed.
- [ ] Blocking error patterns were checked.
- [ ] Result is documented as `PASS`, `FAIL`, or `NOT_RUN`.


## Visual Follow-Up
If startup reaches the first screen/scene but the change affected visuals, layout, maps, sprites, or user-visible behavior, runtime startup alone is not enough.

Complete `Operations/VISUAL_QA_TEMPLATE.md` and `Operations/RESPONSIVE_LAYOUT_VALIDATION_TEMPLATE.md` when applicable.

