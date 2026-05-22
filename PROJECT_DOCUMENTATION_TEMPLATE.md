# Project Documentation Template

Document Path: `<PRIMARY_PATH>/PROJECT_DOCUMENTATION_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.3`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Canonical project runtime, architecture, and behavior record template.
Changes: Added visual/runtime behavior documentation section.

## Quick Rules
- Document architecture by subsystem.
- Define feature behavior in testable language.
- Include logging, privacy, persistence, and error strategy summaries.
- Include verification commands and expected outcomes.

## Required Contract
Required sections:
- `Overview`
- `Runtime Architecture`
- `Core Features`
- `Data and Persistence Boundaries`
- `Logging and Error Controls`
- `Privacy and Sensitive Data Controls`
- `Governance and Release Artifacts`
- `Verification Commands`
- `Known Risks and Deferred Items`

## Overview
- App Name: `<APP_NAME>`
- Purpose: `<PURPOSE>`
- Primary Users: `<USER_TYPES>`
- Supported Platforms: `<PLATFORMS>`

## Runtime Architecture
| Subsystem | Responsibility | Source Path | Owner |
|---|---|---|---|
| UI | `<RESPONSIBILITY>` | `<PATH>` | `<OWNER>` |
| API | `<RESPONSIBILITY>` | `<PATH>` | `<OWNER>` |
| Engine | `<RESPONSIBILITY>` | `<PATH>` | `<OWNER>` |
| Data | `<RESPONSIBILITY>` | `<PATH>` | `<OWNER>` |

## Core Features
| Feature | Behavior | Primary Module | Test Evidence |
|---|---|---|---|
| `<FEATURE>` | `<TESTABLE_BEHAVIOR>` | `<MODULE>` | `<COMMAND_OR_TEST_ID>` |

## Data and Persistence Boundaries
- Canonical data source: `<SOURCE>`
- Local cache policy: `<POLICY>`
- Migration policy: `<POLICY>`
- Backup/recovery policy: `<POLICY>`

## Logging and Error Controls
- Log schema: `<PATH_OR_POLICY>`
- Error code domain(s): `<DOMAIN_LIST>`
- User-safe error behavior: `<SUMMARY>`

## Privacy and Sensitive Data Controls
- Data classification: `<CLASSIFICATION>`
- Redaction rules: `<SUMMARY>`
- Production data local-use policy: `<POLICY>`

## Verification Commands
| Command | Purpose | Expected Result |
|---|---|---|
| `<COMMAND>` | `<PURPOSE>` | `<EXPECTED_RESULT>` |

## Known Risks and Deferred Items
| ID | Risk/Item | Owner | Target Date | Notes |
|---|---|---|---|---|
| `<ID>` | `<SUMMARY>` | `<OWNER>` | `<DATE>` | `<NOTES>` |

## Verification Gate
- [ ] All required sections present.
- [ ] Architecture paths are valid.
- [ ] Feature list matches implemented behavior.
- [ ] Data/persistence boundaries are clear.
- [ ] Verification commands execute in target environment.


## Visual and Runtime Behavior
Document user-visible behavior that must be preserved:
- first screen/scene/route
- required visual assets
- layout/responsive expectations
- desktop window requirements when applicable
- map/canvas/game coordinate system when applicable
- visual QA evidence requirements
