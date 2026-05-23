# Engine State Flow Template

Document Path: `<PRIMARY_PATH>/Templates/Engine_Module/STATE_FLOW.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Document workflow states, transitions, events, side effects, and trace/log behavior for engine logic.
Changes: Initial engine state-flow template added.

## Quick Rules
- Define states and transitions explicitly.
- Do not hide side effects inside state changes.
- Log entry, transition, success, and failure events.
- Include rollback/recovery behavior for failed transitions.

## Required Contract
| State | Event | Next State | Guard/Validation | Side Effects | Log Event | Error Code |
|---|---|---|---|---|---|---|
| `<STATE>` | `<EVENT>` | `<NEXT_STATE>` | `<RULE>` | `<SIDE_EFFECTS>` | `<LOG_EVENT>` | `<ERROR_CODE>` |

## Detailed Guidance
- Keep state names stable when persisted or used externally.
- Add decision records for major state machine changes.
- Include negative-path behavior and retry rules.

## Verification Gate
- [ ] All states are listed.
- [ ] Invalid transitions are documented or rejected.
- [ ] Side effects are visible.
- [ ] Logging/error behavior is testable.

