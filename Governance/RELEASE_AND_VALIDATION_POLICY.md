# Release and Validation Policy

Document Path: `<PRIMARY_PATH>/Governance/RELEASE_AND_VALIDATION_POLICY.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Define validation evidence required before closing work or releasing app changes.
Changes: Added v1.5 separate workstream, data, UI, and version bump commit guidance.

## Quick Rules
- No release without validation evidence.
- No undocumented behavior change.
- No unresolved release-blocking defect without waiver.
- Validation commands must be copied exactly from `APP_PROFILE.md` or the validation matrix.
- If a command cannot be run, record why and who owns follow-up.
- Build success does not equal app validation.
- Runtime startup validation is required when a change can affect app launch, assets, routing, configuration, storage, platform setup, engine initialization, dependency loading, or the first user-visible screen.
- Visual QA is required when a change affects UI layout, screen scaling, maps, sprites, animation, gameplay pathing, image placement, visual assets, or user-visible behavior.
- Responsive layout validation is required when desktop window behavior, canvas scaling, game rendering, HUD positioning, or screen resize behavior may be affected.

## Required Contract
Every release-impacting change must include:
- version and changelog entry
- validation matrix update or confirmation no change needed
- test/lint/build results
- runtime startup smoke test result when required
- log review result when runtime startup was performed
- release readiness checklist
- risks and rollback/recovery notes
- decision record for breaking changes

Minimum validation categories:
- dependency restore
- syntax/static analysis
- unit or contract tests
- integration/manual validation for touched workflow
- build/package validation when UI, runtime, dependencies, or release files change
- runtime startup smoke test when startup, assets, routing, config, platform, engine, storage, dependency loading, or first screen may be affected
- runtime log review after launch
- visual QA evidence when user-visible behavior changed
- responsive layout validation when sizing, scaling, or desktop window behavior changed
- privacy/logging validation when data or logs are touched

## Build Passed Does Not Mean App Validated
A build proves the app can compile or package.

A runtime startup smoke test proves the app can actually start, load required startup resources, and reach the first expected user-visible state.

Both are required before a full green light when runtime behavior may be affected.

The agent must not report `PASS`, `validated`, `ready`, `complete`, `green light`, or equivalent language unless every required validation level has passed or is documented as not applicable.

If runtime startup validation was not performed, the agent must state:

```text
Build validation passed, but runtime startup validation was not performed. This is not a full green light.
```

## Visual QA Gate
When a change affects UI layout, screen scaling, maps, sprites, animation, gameplay pathing, image placement, visual assets, or user-visible behavior, automated checks are not enough.

Required visual evidence:
- screenshot of the affected screen or scene
- screenshot at a normal/non-fullscreen window size when responsive behavior is relevant
- screenshot with debug overlay enabled when pathing, hitboxes, placement zones, or map alignment are affected
- screenshot with debug overlay disabled for normal player view

The agent must compare visual evidence against the task acceptance criteria and record pass/fail for each visual requirement.

The agent must not commit or push visual work until owner approval is given when the task specifically requires screenshot approval.

## Responsive Layout Validation Gate
Responsive validation is required when a change affects screen layout, map scaling, canvas/game rendering, HUD positioning, or desktop window behavior.

Validation must include:
- fullscreen or maximized view
- non-fullscreen normal window
- smaller resized window
- confirmation that required content is not cropped
- confirmation that primary controls remain visible and usable
- confirmation that gameplay coordinates still match the rendered map when applicable

Expected result: the required scene or screen remains visible using contain-fit, letterboxing, responsive reflow, or another documented scaling strategy. Cropping is only acceptable when intentionally documented.

## Runtime Startup Smoke Test Triggers
Runtime startup validation is required after any change involving:
- app startup or bootstrapping
- first screen, first route, first scene, shell, or navigation setup
- images, fonts, media, maps, sprites, static assets, or bundled files
- configuration files, environment files, or asset manifests
- platform-specific setup
- dependency updates
- engine initialization or game/app loop startup
- data loading, seed data, local files, storage, or permissions
- logging, error handling, or crash handling
- build scripts or packaging paths

## Detailed Guidance
Evidence block format:

```md
- Command: <COMMAND_OR_METHOD>
- Result: <PASS|FAIL|NOT_RUN|NOT_APPLICABLE>
- Notes: <DETAIL>
- Date: <DATE_YYYY-MM-DD>
- Run By: <NAME_OR_AGENT>
- Evidence Path: <LOG_SCREENSHOT_ARTIFACT_OR_NONE>
```

Runtime startup evidence must include:
- launch command or method
- platform/device used
- expected first screen, scene, route, workflow, or healthcheck
- actual observed result
- log source reviewed
- blocking errors found or explicit `None found`

Validation strength should match risk:
- documentation-only: link/placeholders and review check
- UI-only: static analysis plus runtime/manual screenshot or behavior check when visible behavior changes
- visual/gameplay: screenshot evidence plus owner approval status when requested
- responsive/layout: fullscreen, normal window, and smaller-window checks when applicable
- data/schema: contract tests, migration tests, rollback notes
- auth/privacy: redaction, secret scan, negative tests
- assets/resources: asset existence check plus runtime startup smoke test
- release packaging: clean build plus runtime startup smoke test

## Release Output Discipline
Release and validation summaries must be concise but complete.

Required reporting behavior:
- summarize each validation step as PASS, FAIL, NOT_RUN, or N/A
- include only relevant error lines, not full logs, unless requested
- label missing evidence as `Not validated`
- do not assume runtime success, visual approval, or release readiness from build success
- do not bypass governance gates for speed

## Verification Gate
- [ ] Required validation categories are covered.
- [ ] Evidence blocks include command/method, result, notes, date, runner, and evidence path.
- [ ] Runtime startup smoke test is recorded when required.
- [ ] Runtime logs were reviewed when the app was launched.
- [ ] Visual QA evidence is present when user-visible behavior changed.
- [ ] Responsive layout evidence is present when sizing/scaling/window behavior changed.
- [ ] Release checklist is complete for release-impacting work.
- [ ] Known failures have owner-approved waiver or remediation plan.
- [ ] Green-light language is not used unless all required gates passed.

## v1.5 Separate Commit Guidance
When applicable, separate these into distinct commits:
- live data commits
- business logic commits
- UI/design-system commits
- documentation commits
- version bump commits

Do not mix UI modernization with business-logic fixes unless the owner explicitly approves. If live data is changed during validation, follow the project backup and data-commit rules before committing code.

