# Session Template

Document Path: `<PRIMARY_PATH>/Operations/SESSION_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Template for recording work session scope, actions, validation, and next steps.
Changes: Added v1.5 workstream ownership and source-of-truth session fields.

## Quick Rules
- One session file per meaningful work window.
- Record facts, commands, outcomes, and next action.
- Do not mark complete without evidence or a validation limitation note.

## Required Contract
Use this template:

```md
# SESSION_<DATE_YYYY-MM-DD>_<HHMM>_<AREA>_<TOPIC>

## Context
- App: <APP_NAME>
- Owner: <OWNER>
- Agent/Author: <AGENT_OR_AUTHOR>
- Start: <DATE_YYYY-MM-DD HH:MM>
- Branch/Workspace: <BRANCH_OR_PATH>

## Goals
- <GOAL_1>

## Work Log
- <TIMESTAMP> <ACTION>

## Changed Files
- <PATH>: <CHANGE_SUMMARY>

## Documentation Updates
- <PATH>: <UPDATE_SUMMARY_OR_NONE>

## Validation
- <COMMAND>: <PASS|FAIL|NOT_RUN + NOTE>

## Risks and Blockers
- <RISK_OR_BLOCKER_OR_NONE>

## Next Action
- <ONE_EXACT_NEXT_STEP>

## Closeout
- End: <DATE_YYYY-MM-DD HH:MM>
- Status: <COMPLETE|PARTIAL|BLOCKED>
```

## Detailed Guidance
- Keep `Next Action` executable in one step.
- Use exact command text in validation.
- If blocked, include unblock owner and dependency.
- Include documentation updates even when the answer is `None required`.

## Output Discipline
- Response style used: `<CONCISE|DETAILED_WITH_REASON>`
- Assumptions made: `<NONE_OR_LIST>`
- Unknowns remaining: `<NONE_OR_LIST>`
- Governance conflicts: `<NONE_OR_LIST>`

## Verification Gate
- [ ] Template fields completed.
- [ ] Validation evidence recorded.
- [ ] Changed files are listed.
- [ ] Next action is explicit and bounded.

## v1.5 Workstream Fields
When multiple coders/agents are active, each session must record:
- coder/agent identifier
- workstream
- master source of truth
- current app version at start
- git status at start
- whether another coder pushed during the session
- final sync requirement for other coders

