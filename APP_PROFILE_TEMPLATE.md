# App Profile Template

Document Path: `<PRIMARY_PATH>/APP_PROFILE_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Store project-specific facts that should not be hard-coded into generic governance documents.
Changes: Added v1.5 source-of-truth, multi-coder, data handling, and UI standards profile fields.

## Quick Rules
- Keep this file project-specific and current.
- Do not duplicate app facts across governance files.
- Update this file when commands, paths, owners, environments, release rules, or runtime startup rules change.
- Treat this file as the first source checked by any agent working on the app.
- Define the minimum startup proof required before the app can be called fully validated.

## Required Contract
| Field | Value |
|---|---|
| App Name | `<APP_NAME>` |
| App Purpose | `<ONE_PARAGRAPH_PURPOSE>` |
| Product Owner | `<OWNER>` |
| Technical Owner | `<TECH_OWNER>` |
| Primary Repo | `<REPO_URL_OR_LOCAL_PATH>` |
| Primary Branch | `<BRANCH_NAME>` |
| Primary Workspace Path | `<LOCAL_PATH>` |
| Target Platforms | `<Windows|macOS|iOS|Android|Web|Server|Other>` |
| Main Stack | `<Flutter|React|Python|.NET|Node|Other>` |
| Package Manager | `<pub|npm|pip|nuget|cargo|other>` |
| Data Classification | `<Public|Internal|Confidential|Sensitive>` |
| Production Data Allowed Locally | `<Yes|No|Restricted>` |
| Release Owner | `<OWNER>` |
| Temporary Work Root | `<PATH_TO_AGENT_TEMP_FOLDER>` |
| Screenshots Temp Folder | `<PATH_TO_AGENT_TEMP_SCREENSHOTS>` |
| Diagnostics Temp Folder | `<PATH_TO_AGENT_TEMP_DIAGNOSTICS>` |
| Source Control Ignore Rule | `<TEMP_FOLDER_IGNORED_YES_NO>` |
| Minimum Window Size | `<WIDTH_X_HEIGHT_OR_N/A>` |
| Desktop Focus Requirement | `<YES_NO_N/A>` |

## Required Commands
| Purpose | Command | Expected Result |
|---|---|---|
| Dependency install | `<COMMAND>` | `<EXPECTED_RESULT>` |
| Static analysis/lint | `<COMMAND>` | `<EXPECTED_RESULT>` |
| Unit tests | `<COMMAND>` | `<EXPECTED_RESULT>` |
| Integration tests | `<COMMAND>` | `<EXPECTED_RESULT>` |
| Build/package | `<COMMAND>` | `<EXPECTED_RESULT>` |
| Runtime startup smoke test | `<COMMAND_OR_MANUAL_METHOD>` | `<EXPECTED_FIRST_SCREEN_SCENE_OR_HEALTHCHECK>` |
| Runtime log review | `<COMMAND_OR_LOG_PATH>` | `No blocking runtime errors found` |
| Visual QA capture | `<COMMAND_OR_MANUAL_METHOD>` | `<SCREENSHOT_PATHS_OR_N/A>` |
| Responsive layout validation | `<COMMAND_OR_MANUAL_METHOD>` | `<PASS_FAIL_CRITERIA>` |
| Link/placeholders check | `<COMMAND>` | `<EXPECTED_RESULT>` |

## Runtime Startup Smoke Test
Each app must define its minimum startup proof. Build success alone is not full validation.

### Required Startup Proof
| Item | Value |
|---|---|
| Launch command or method | `<COMMAND_OR_STEPS>` |
| Target platform/device | `<PLATFORM_OR_DEVICE>` |
| Expected first screen/scene/route | `<EXPECTED_STARTUP_STATE>` |
| Expected startup log message | `<EXPECTED_LOG_OR_NONE>` |
| Required startup assets/files | `<ASSETS_FILES_OR_NONE>` |
| Required startup services | `<SERVICES_OR_NONE>` |
| Log source to review | `<CONSOLE_LOG_FILE_OR_TOOL>` |
| Blocking error patterns | `Unhandled Exception; EXCEPTION CAUGHT; missing asset; missing file; failed assertion; startup crash` |
| Screenshot/log evidence required | `<Yes|No|When available>` |

### Green-Light Requirement
The startup smoke test must pass before the agent can report the app as fully validated whenever the change touches or may affect:
- app startup
- routing/navigation
- assets, images, fonts, files, or bundled resources
- configuration files
- platform setup
- engine initialization
- dependency updates
- UI shell or first screen
- data loading
- storage, permissions, or file paths
- logging/error handling

If runtime startup validation is not run, the agent must mark it `NOT_RUN` and must not report a full green light.

## Visual QA Requirements
Define when screenshots are required and where they must be saved.

| Item | Value |
|---|---|
| Visual QA required for UI/layout/gameplay changes | `<YES|NO>` |
| Screenshot folder | `<PATH>` |
| Debug overlay available | `<YES|NO|N/A>` |
| Debug overlay screenshot required when | `<PATHING_HITBOX_PLACEMENT_OR_N/A>` |
| Normal player-view screenshot required when | `<UI_OR_GAMEPLAY_VISUAL_CHANGE_OR_N/A>` |
| Owner screenshot approval required before commit | `<YES|NO|WHEN_REQUESTED>` |

## Responsive Layout Validation
Required when a change affects screen layout, map scaling, canvas/game rendering, HUD positioning, or desktop window behavior.

Validation must include:
- fullscreen or maximized view
- non-fullscreen normal window
- smaller resized window
- confirmation that required content is not cropped
- confirmation that HUD or primary controls remain visible and usable
- confirmation that gameplay coordinates still match the rendered map when applicable

Expected scaling strategy:
- `<CONTAIN_FIT|LETTERBOX|CROP_BY_DESIGN|RESPONSIVE_REFLOW|OTHER>`

## Desktop Window Requirements
Required for Windows/macOS/Linux desktop apps when applicable:
- app opens visibly in front of other windows when launched, if supported by the platform
- app receives focus on launch, if supported by the platform
- app is resizable unless intentionally locked
- app maintains required visible content when resized
- minimum window size is documented if needed
- fullscreen/maximized behavior is documented

## Temporary Artifact Folders
Agents must use the folders below for scratch work and must not place temporary files in production asset, data, or documentation folders.

| Temp Artifact Type | Required Folder |
|---|---|
| Scratch root | `<APP_ROOT>/.agent_temp` |
| Screenshots | `<APP_ROOT>/.agent_temp/screenshots` |
| Diagnostics/log copies | `<APP_ROOT>/.agent_temp/diagnostics` |
| Scratch/generated files | `<APP_ROOT>/.agent_temp/scratch` |

Source control rule:
- `<APP_ROOT>/.agent_temp/` should be ignored unless the owner approves tracking specific evidence files.

## Environment Map
| Environment | URL/Path | Data Used | Owner | Notes |
|---|---|---|---|---|
| Local | `<PATH>` | `<DATA_CLASS>` | `<OWNER>` | `<NOTES>` |
| Test | `<URL_OR_PATH>` | `<DATA_CLASS>` | `<OWNER>` | `<NOTES>` |
| Production | `<URL_OR_PATH>` | `<DATA_CLASS>` | `<OWNER>` | `<NOTES>` |

## Documentation Map
| Document | Canonical Path | Notes |
|---|---|---|
| Master Guideline | `<PRIMARY_PATH>/MASTER_GUIDELINE.md` | `<NOTES>` |
| Changelog | `<PRIMARY_PATH>/CHANGELOG.md` | `<NOTES>` |
| Decision Log | `<PRIMARY_PATH>/Operations/DECISION_LOG.md` | `<NOTES>` |
| Validation Matrix | `<PRIMARY_PATH>/Operations/VALIDATION_MATRIX.md` | `<NOTES>` |
| Runtime Startup Smoke Test | `<PRIMARY_PATH>/Operations/RUNTIME_STARTUP_SMOKE_TEST.md` | `<NOTES>` |
| Release Checklist | `<PRIMARY_PATH>/Operations/CHECKLIST_RELEASE_READINESS.md` | `<NOTES>` |

## Agent Output Preferences
- Concise summaries required: `<YES|NO>`
- Raw log/file dumps allowed by default: `<YES|NO>`
- If evidence is missing, agent should: `<VERIFY|STATE_UNKNOWN|ASK_OWNER>`
- Assumptions allowed without labeling: `NO`
- Governance may be bypassed for speed: `NO`
- Required closeout style: `<BRIEF_STATUS_WITH_EVIDENCE|FULL_REPORT>`

Project-specific communication notes:
- `<NOTE_1>`
- `<NOTE_2>`

## Verification Gate
- [ ] App ownership and paths are complete.
- [ ] Commands are real and current.
- [ ] Runtime startup smoke test is defined.
- [ ] Visual QA requirements are defined.
- [ ] Responsive layout validation requirements are defined where applicable.
- [ ] Desktop window requirements are defined where applicable.
- [ ] Temporary artifact folders are defined and ignored by source control.
- [ ] Blocking runtime error patterns are defined.
- [ ] Data classification is set.
- [ ] Environment map is complete.
- [ ] Documentation map points to real files.

## v1.5 Coordination and Documentation Sources
| Field | Value |
|---|---|
| Master Coordination Source | `<CHAT_OR_DOC_PATH>` |
| Active Workstreams | `<CODER_1_SCOPE; CODER_2_SCOPE; ...>` |
| UI Standards Document | `<PATH_OR_N/A>` |
| UI Standards Selection Form | `<PATH_OR_N/A>` |
| Form Definitions Document | `<PATH_OR_N/A>` |
| TODO Register | `<PATH_OR_N/A>` |
| Live Data Commit Rule | `<RULE_FOR_DATA_CHANGES>` |
| Runtime/UI State Files | `<FILES_TO_REVERT_UNLESS_APPROVED>` |
| Required Data Backup Scope | `<DATA_CONFIG_SYSTEM_DATA_OR_OTHER>` |

Data handling must be project-specific. Agents must not assume that `Data/` changes are disposable; the owner must define whether data changes are kept, reverted, or backed up and committed separately.

