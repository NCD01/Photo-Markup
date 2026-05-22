# Operations README

Document Path: `<PRIMARY_PATH>/Operations/README.md`
Version: `<VERSION>`
Pack File Version: `v1.3`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Explain operational documents used to plan, validate, hand off, and release app work.
Changes: Added references to visual QA and responsive layout operation templates.

## Quick Rules
- Keep operational evidence current.
- Use templates to make handoffs and releases repeatable.
- Do not treat undocumented validation as completed validation.
- Do not report full green light when runtime startup validation was required but not performed.

## Required Contract
| Document | Purpose |
|---|---|
| `CHECKLIST_NEW_APP_BOOTSTRAP.md` | Confirm a new app documentation baseline is ready. |
| `CHECKLIST_RELEASE_READINESS.md` | Confirm release readiness and closeout evidence. |
| `DECISION_LOG_TEMPLATE.md` | Record decisions that affect behavior, architecture, governance, or risk. |
| `HANDOFF_TEMPLATE.md` | Transfer work to another person or agent with clear state and next action. |
| `RISK_REGISTER_TEMPLATE.md` | Track risks, mitigations, owners, and status. |
| `RUNTIME_STARTUP_SMOKE_TEST_TEMPLATE.md` | Define launch proof required before full app validation. |
| `SESSION_TEMPLATE.md` | Record focused work sessions. |
| `TODO_REGISTER_TEMPLATE.md` | Track open items and follow-ups. |
| `VALIDATION_MATRIX_TEMPLATE.md` | Track validation commands, triggers, results, and evidence. |

## Detailed Guidance
Operational docs should be updated during work, not reconstructed after the fact. Validation evidence should be concrete enough that another person can repeat the check.

Runtime startup validation is required when a change may affect launch, assets, first screen/scene, routing, config, platform setup, dependency loading, storage, or logging.

## Verification Gate
- [ ] Operations folder contains active templates.
- [ ] App-specific copies are created during adoption.
- [ ] Runtime startup validation is defined where applicable.
- [ ] Handoff and release evidence are traceable.


## v1.3 Added Operations Templates
- `VISUAL_QA_TEMPLATE.md` records screenshot evidence, visual pass/fail checks, and owner approval status.
- `RESPONSIVE_LAYOUT_VALIDATION_TEMPLATE.md` records fullscreen, normal-window, and small-window validation evidence.
