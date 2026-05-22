# Coder Coordination Template

Document Path: `<PRIMARY_PATH>/Operations/CODER_COORDINATION_TEMPLATE.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Coordinate multiple agents/coders without mixing workstreams, files, commits, or responsibilities.
Changes: Added v1.5 multi-coder coordination template.

## Purpose
Use this template when two or more coders/agents are active in the same project.

## Source of Truth
- Master coordination chat/doc: `<SOURCE_OF_TRUTH>`
- Current branch: `<BRANCH>`
- Current app version: `<VERSION>`
- Last clean checkpoint: `<COMMIT_OR_SUMMARY>`

## Workstream Ownership
| Coder/Agent | Scope | Must Not Touch | Current Task | Status |
|---|---|---|---|---|
| `Coder 1` | `<FEATURE_OR_BUSINESS_LOGIC>` | `<FILES_OR_AREAS>` | `<TASK>` | `<STATUS>` |
| `Coder 2` | `<UI_OR_DESIGN_SYSTEM>` | `<FILES_OR_AREAS>` | `<TASK>` | `<STATUS>` |

## Coordination Rules
- One chat/doc must remain the master source of truth.
- No coder starts from a dirty working tree unless explicitly approved.
- No coder edits files owned by another active workstream.
- No coder reverts, stashes, or commits another coder's files without approval.
- If one coder pushes, the other must pull/sync before continuing.
- Keep UI commits separate from business-logic commits.
- Keep data commits separate from code commits.
- Keep version bumps as separate commits unless project governance says otherwise.
- Stop and report on merge conflicts, stale locks, unexpected dirty files, or validation failures.

## Clean Start Check
Before starting:
```text
git status --short
```

Expected result:
```text
<empty>
```

If not clean, classify files:
- runtime/UI state
- live data
- generated/cache
- current workstream files
- other coder files
- unknown/unexpected

## Checkpoint Report Format
```md
Task name:
Coder:
Current app version:
Git status at start:
Files inspected:
Files changed:
Validation run:
Commit hash, if committed:
Version bump hash, if bumped:
New app version, if bumped:
Final git status --short:
Risks/blockers:
Next action:
```

## Verification Gate
- [ ] Workstream ownership is clear.
- [ ] Git status is checked before work.
- [ ] Files are not mixed across coders.
- [ ] Commit plan separates UI, business logic, data, docs, and version bump.
- [ ] Other active coder is told to sync after pushes.
