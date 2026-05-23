# Visual QA Template

Document Path: `<PRIMARY_PATH>/Operations/VISUAL_QA_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.3`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Record visual evidence and owner approval status for UI, game, map, sprite, layout, and user-visible changes.
Changes: Initial v1.3 template.

## Quick Rules
- Automated checks do not prove visual correctness.
- Capture screenshots for visual/user-facing changes.
- Use debug overlays when pathing, hitboxes, placement zones, or map alignment are affected.
- Do not commit or push visual work when owner screenshot approval was required but not granted.

## Required Contract
| Field | Value |
|---|---|
| Task / Change | `<SUMMARY>` |
| Visual QA Required | `<YES|NO>` |
| Owner Approval Required | `<YES|NO>` |
| Affected Screen / Scene | `<NAME>` |
| Normal Screenshot | `<PATH_OR_N/A>` |
| Debug Overlay Screenshot | `<PATH_OR_N/A>` |
| Responsive Screenshot | `<PATH_OR_N/A>` |
| Owner Approved Screenshot | `<YES|NO|PENDING|N/A>` |
| Visual Blockers | `<NONE_OR_LIST>` |

## Acceptance Criteria Comparison
| Requirement | Evidence | Result | Notes |
|---|---|---|---|
| `<VISUAL_REQUIREMENT>` | `<SCREENSHOT_OR_LOG>` | `<PASS|FAIL|PENDING>` | `<NOTES>` |

## Verification Gate
- [ ] Required screenshots are captured.
- [ ] Screenshot paths are recorded.
- [ ] Debug overlay evidence is included when relevant.
- [ ] Acceptance criteria are compared one by one.
- [ ] Owner approval status is recorded when required.
- [ ] Visual blockers are listed or explicitly marked `None`.

