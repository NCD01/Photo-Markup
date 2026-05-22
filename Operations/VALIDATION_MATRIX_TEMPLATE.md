# Validation Matrix Template

Document Path: `<PRIMARY_PATH>/Operations/VALIDATION_MATRIX_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.4`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Track required validation checks, commands, owners, and evidence for the app.
Changes: Added visual QA, responsive layout, and temporary artifact validation rows.

## Quick Rules
- Keep commands exact and current.
- Map validation to risks and modules.
- Record `NOT_RUN` honestly with owner and follow-up.
- Do not rely on memory for release evidence.
- Do not mark full validation complete unless required runtime startup and log review gates passed.

## Required Contract
| Check ID | Area | Command/Method | Required When | Expected Result | Owner | Last Result | Evidence Path |
|---|---|---|---|---|---|---|---|
| `VAL-001` | Dependency Restore | `<COMMAND>` | Packages/dependencies may be affected | Dependencies restore successfully | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-002` | Static Analysis | `<COMMAND>` | Code or config changed | No blocking analysis/lint issues | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-003` | Automated Tests | `<COMMAND>` | Test-covered behavior may be affected | Tests pass | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-004` | Build/Package | `<COMMAND>` | Build, UI, runtime, dependencies, or release files may be affected | Build succeeds | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-005` | Runtime Startup Smoke Test | `<COMMAND_OR_MANUAL_METHOD>` | Startup, assets, routing, config, platform, engine, dependency loading, first screen, data loading, storage, permissions, or logs may be affected | App launches and reaches expected first screen/scene/workflow | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-006` | Runtime Log Review | `<LOG_SOURCE_OR_METHOD>` | Runtime startup smoke test is run | No blocking runtime errors found | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-007` | Privacy/Redaction | `<COMMAND_OR_REVIEW_METHOD>` | Data, logs, screenshots, exports, auth, or telemetry may be affected | No sensitive data exposure | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-008` | Docs/Changelog | `<REVIEW_METHOD>` | Any versioned change | Docs and changelog match actual changes | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-009` | Visual QA | `<SCREENSHOT_OR_REVIEW_METHOD>` | UI layout, maps, sprites, animations, image placement, gameplay pathing, or user-visible behavior changed | Screenshots prove the requested visual behavior or list blockers | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-010` | Responsive Layout | `<SCREEN_SIZE_REVIEW_METHOD>` | Screen resize, desktop window behavior, canvas/game rendering, HUD, map scaling, or responsive layout changed | Required content remains visible and aligned at required sizes | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |
| `VAL-011` | Temporary Artifact Review | `<FOLDER_REVIEW_METHOD>` | Screenshots, diagnostics, generated files, or scratch outputs were created | Temporary files are stored in approved scratch folders and summarized/cleaned up | `<OWNER>` | `<PASS|FAIL|NOT_RUN|N/A>` | `<PATH>` |

## Green-Light Rule
The agent may only report a full green light when all required checks are `PASS` or `N/A` with a valid reason.

A successful build does not prove runtime success.

A runtime startup smoke test must pass when the change touches or may affect:
- app startup
- routing/navigation
- assets, images, fonts, media, static files, or bundled resources
- configuration files
- platform setup
- engine initialization
- dependency updates
- UI shell or first user-visible screen
- data loading
- storage, permissions, or file paths
- logging/error handling

If runtime startup validation is required but not run, the result must be `NOT_RUN`, and the agent must state that this is not a full green light.

## Visual QA Rule
Visual QA must be marked `PASS`, `FAIL`, `NOT_RUN`, or `N/A` separately from build/runtime validation.

Visual QA is required when the task affects:
- UI layout or visible styling
- screen scaling or responsive behavior
- maps, sprites, animation, placement, or pathing
- image placement or visual assets
- user-visible behavior that cannot be proven from logs alone

## Responsive Layout Rule
Responsive layout validation must include fullscreen/maximized, normal non-fullscreen, and smaller resized states when resize behavior is relevant.

The evidence must confirm:
- required content is not unintentionally cropped
- primary controls remain visible and usable
- visual overlays, gameplay routes, hitboxes, and placement zones still align where applicable

## Temporary Artifact Rule
If evidence files are created, the matrix must point to approved temp/evidence locations. Temporary work must not be placed in production asset, image, data, or documentation folders unless approved as a governed artifact.

## Detailed Guidance
Suggested areas:
- `Docs`
- `Static Analysis`
- `Unit Tests`
- `Contract Tests`
- `Integration Tests`
- `Manual Workflow`
- `Visual QA`
- `Responsive Layout`
- `Build/Package`
- `Runtime Startup`
- `Runtime Log Review`
- `Privacy/Redaction`
- `Logging/Error Codes`
- `Migration/Recovery`

Runtime startup evidence should include:
- launch command or method
- platform/device
- expected first screen/scene/route/workflow
- actual observed result
- log source reviewed
- blocking error result

## Evidence Summary Rule
Validation results must be concise and evidence-based.

For each row, use only:
- `PASS`
- `FAIL`
- `NOT_RUN`
- `N/A`

Do not assume a validation result. If a command, launch, screenshot, or log review was not performed, mark it `NOT_RUN` and explain briefly.

Do not paste full logs into the matrix. Link or reference the evidence path and include only the important error lines in notes.

## Verification Gate
- [ ] Every critical module has validation coverage.
- [ ] Commands match `APP_PROFILE.md`.
- [ ] Runtime startup smoke test exists for apps with a runtime UI/service/game loop.
- [ ] Visual QA row exists for UI/game/user-visible work.
- [ ] Responsive layout row exists for screen resize or desktop window work.
- [ ] Temporary artifact review row exists when screenshots/diagnostics/scratch files were created.
- [ ] Last result is current for release-impacting checks.
- [ ] Evidence paths are valid.
- [ ] No full green light is reported when required runtime validation is missing.
