# Engine Testing Template

Document Path: `<PRIMARY_PATH>/Templates/Engine_Module/TESTING.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define test matrix, validation commands, and regression risks for the Engine module.
Changes: Initial module template baseline.

## Quick Rules
- Map tests to behavior and contracts.
- Include success, failure, and boundary scenarios.
- Record command-level evidence.
- Track known gaps with owner and date.

## Required Contract
Include test matrix with:
- Scenario ID
- Scenario Description
- Type (`Unit|Integration|Contract|Manual|Build|Privacy|Logging`)
- Expected Result
- Command/Method
- Status
- Evidence Path

## Test Matrix
| Scenario ID | Description | Type | Expected Result | Command/Method | Status | Evidence Path |
|---|---|---|---|---|---|---|
| `<TEST_ID>` | `<DESCRIPTION>` | `<TYPE>` | `<EXPECTED>` | `<COMMAND>` | `<PASS|FAIL|NOT_RUN>` | `<PATH>` |

## Detailed Guidance
- Include negative-path tests for logging/error behavior.
- Include compatibility tests for changed schemas.
- Keep regression section focused on high-risk surfaces.
- Include manual validation steps for workflows that cannot be fully automated.

## Verification Gate
- [ ] Matrix covers happy path, errors, and boundaries.
- [ ] Commands/methods are reproducible.
- [ ] Known gaps are documented with owner/date.
- [ ] Evidence paths are valid or intentionally marked N/A.

