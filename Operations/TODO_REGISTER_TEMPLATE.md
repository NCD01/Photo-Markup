# TODO Register Template

Document Path: `<PRIMARY_PATH>/Operations/TODO_REGISTER_TEMPLATE.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Track deferred work without hiding gaps inside chat history or code comments.
Changes: Added v1.5 ordered TODO/workstream tracking guidance.

## Quick Rules
- Record deferred items as soon as they are deferred.
- Assign owner and priority.
- Link TODOs to decisions, risks, or changelog entries when relevant.
- Review TODOs before release.

## Required Contract
| TODO ID | Area | Item | Priority | Owner | Status | Related Risk/Decision | Target Date |
|---|---|---|---|---|---|---|---|
| `TODO-001` | `<AREA>` | `<ITEM>` | `<Low|Medium|High>` | `<OWNER>` | `<Open|In Progress|Done|Deferred>` | `<ID_OR_N/A>` | `<DATE_OR_N/A>` |

## Detailed Guidance
- Use TODOs for known work, not vague ideas.
- Promote TODOs to risk items when they can block release or damage data.
- Do not mark done without a file, commit, command, or evidence reference.

## Verification Gate
- [ ] Every TODO has owner and status.
- [ ] Release-impacting TODOs are resolved or waived.
- [ ] Done items include evidence reference.

## Ordered Workstream TODOs
When work must proceed in a strict order, record the sequence explicitly.

| Order | Workstream | Item | Status | Blocked By | Evidence |
|---|---|---|---|---|---|
| `1` | `<WORKSTREAM>` | `<ITEM>` | `<Open|In Progress|Done|Deferred>` | `<DEPENDENCY_OR_NONE>` | `<COMMIT_OR_VALIDATION>` |

Rules:
- Do not jump ahead unless the owner changes priority.
- Keep unrelated parked actions visible so they are not lost.
- Record whether an item is audit-only, implementation, validation, or commit/closeout.


