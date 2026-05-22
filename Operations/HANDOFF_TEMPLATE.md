# Handoff Template

Document Path: `<PRIMARY_PATH>/Operations/HANDOFF_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Template for handing work to another person or agent without losing context.
Changes: Added v1.5 multi-coder handoff and coordination evidence fields.

## Quick Rules
- Handoff must be executable by the next agent without guesswork.
- Include exact state, evidence, risks, and immediate next command/action.
- Keep handoff concise; summarize logs and avoid repeated boilerplate.
- Separate confirmed facts from assumptions and unknowns.
- Keep next action precise and bounded.
- State whether runtime startup validation was performed.
- Do not imply green light if required runtime validation is missing.
- Include visual approval status when screenshots or owner review are required.
- Stop and report after about 5 minutes if a specific issue is not resolving.

## Required Contract
```md
# HANDOFF_<DATE_YYYY-MM-DD>_<HHMM>_<AREA>

## Current State
- App: <APP_NAME>
- Branch/Workspace: <BRANCH_OR_PATH>
- Scope completed: <SUMMARY>
- Scope pending: <SUMMARY>
- Green-light status: <FULL|PARTIAL|NO>
- Reason: <WHY_THIS_STATUS_IS_ACCURATE>
- Assumptions: <NONE_OR_LIST>
- Unknowns: <NONE_OR_LIST>

## Decisions Applied
- <DECISION_ID>: <SUMMARY>

## Output Discipline Check
- Concise handoff: <YES|NO>
- Raw logs/files omitted unless needed: <YES|NO>
- Governance followed: <YES|NO>
- Unsupported assumptions removed or labeled: <YES|NO>

## Validation Evidence
| Validation Type | Command/Method | Result | Evidence Path | Notes |
|---|---|---|---|---|
| Dependency restore | <COMMAND_OR_N/A> | <PASS|FAIL|NOT_RUN|N/A> | <PATH_OR_NONE> | <NOTES> |
| Static analysis/lint | <COMMAND_OR_N/A> | <PASS|FAIL|NOT_RUN|N/A> | <PATH_OR_NONE> | <NOTES> |
| Automated tests | <COMMAND_OR_N/A> | <PASS|FAIL|NOT_RUN|N/A> | <PATH_OR_NONE> | <NOTES> |
| Build/package | <COMMAND_OR_N/A> | <PASS|FAIL|NOT_RUN|N/A> | <PATH_OR_NONE> | <NOTES> |
| Runtime startup smoke test | <COMMAND_OR_METHOD_OR_N/A> | <PASS|FAIL|NOT_RUN|N/A> | <PATH_OR_NONE> | <NOTES> |
| Runtime log review | <LOG_SOURCE_OR_N/A> | <PASS|FAIL|NOT_RUN|N/A> | <PATH_OR_NONE> | <NOTES> |
| Visual QA | <SCREENSHOT_OR_REVIEW_METHOD_OR_N/A> | <PASS|FAIL|NOT_RUN|N/A> | <PATH_OR_NONE> | <NOTES> |
| Responsive layout | <SCREEN_SIZE_REVIEW_METHOD_OR_N/A> | <PASS|FAIL|NOT_RUN|N/A> | <PATH_OR_NONE> | <NOTES> |

## Runtime Startup Summary
- Runtime startup required: <YES|NO>
- Startup command/method: <COMMAND_OR_METHOD_OR_N/A>
- Platform/device: <PLATFORM_OR_DEVICE_OR_N/A>
- Expected first screen/scene/route: <EXPECTED_OR_N/A>
- Actual result: <OBSERVED_OR_N/A>
- Blocking errors found: <NONE_OR_LIST_OR_NOT_RUN>


## Visual Approval Evidence
- Visual approval required: <YES|NO>
- Screenshot with debug overlay: <PATH_OR_N/A>
- Screenshot without debug overlay: <PATH_OR_N/A>
- Responsive screenshot: <PATH_OR_N/A>
- Owner approved screenshot: <YES|NO|PENDING|N/A>
- Visual blockers: <NONE_OR_LIST>

## Temporary Artifact Summary
- Temporary files created: <YES|NO>
- Temp root used: <PATH_OR_N/A>
- Screenshots path: <PATH_OR_N/A>
- Diagnostics path: <PATH_OR_N/A>
- Scratch/generated files path: <PATH_OR_N/A>
- Cleanup completed: <YES|NO|N/A>
- Files intentionally kept for evidence: <LIST_OR_NONE>

## Five-Minute Stop Report
Complete this section if the agent stopped because an issue could not be resolved after about 5 minutes of focused debugging.

- Stop rule triggered: <YES|NO>
- Issue being debugged: <SUMMARY_OR_N/A>
- Files changed: <LIST_OR_N/A>
- Commands run: <LIST_OR_N/A>
- Evidence found: <SUMMARY_OR_N/A>
- Screenshots/logs: <PATHS_OR_N/A>
- Current hypothesis: <HYPOTHESIS_OR_N/A>
- Recommended next step: <NEXT_STEP_OR_N/A>
- Revert recommended: <YES|NO|PARTIAL|N/A>

## Files and Contracts Affected
- <PATH_OR_DOC>: <CHANGE_SUMMARY>

## Known Risks
- <RISK_OR_NONE>

## Blockers
- <BLOCKER_OR_NONE>

## Immediate Next Action
- <EXACT_NEXT_STEP>
```

## Detailed Guidance
- `Scope pending` must be precise and finite.
- Include dependency notes for parallel teams.
- Mention any temporary waiver and expiration.
- Do not use handoff as a substitute for changelog when a versioned change occurred.
- If runtime startup validation was not performed, state that build validation is not a full green light.
- If visual approval was required but not received, mark green-light status as `PARTIAL` or `NO`.
- If the five-minute stop rule triggered, do not continue in the same direction without owner direction.

## Verification Gate
- [ ] State reflects latest validated work.
- [ ] Evidence section includes command/method outcomes.
- [ ] Runtime startup and log review status are included.
- [ ] Visual approval status is included when relevant.
- [ ] Temporary artifact summary is included when relevant.
- [ ] Five-minute stop report is included when triggered.
- [ ] Green-light status is accurate and not overstated.
- [ ] Immediate next action is clear and testable.

## v1.5 Multi-Coder Handoff Fields
Add these fields when more than one coder/agent is active:

- Coder/Agent: `<CODER_ID>`
- Workstream: `<UI|Feature|Data|Docs|Other>`
- Files owned by this workstream: `<LIST>`
- Files not to touch: `<LIST>`
- Other coder current status: `<KNOWN_STATUS_OR_UNKNOWN>`
- Pull/sync required before continuing: `<YES|NO>`
- Dirty files classification: `<NONE_OR_LIST>`

