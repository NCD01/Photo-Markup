# Release Readiness Checklist Template

Document Path: `<PRIMARY_PATH>/Operations/CHECKLIST_RELEASE_READINESS.md`
Version: `<VERSION>`
Pack File Version: `v1.3`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Checklist for validating release readiness before app delivery or deployment.
Changes: Added visual QA, responsive layout, and temporary artifact readiness checks.

## Quick Rules
- No release without validation evidence.
- No unresolved `ERROR` severity defect without waiver.
- No undocumented behavior changes.
- No sensitive data exposure in logs, screenshots, or release artifacts.
- No full green light based only on build success.

## Required Contract
- [ ] Version and changelog entries are complete.
- [ ] Release notes include scope and risks.
- [ ] Tests and analysis results are recorded.
- [ ] Build/package result is recorded where applicable.
- [ ] Runtime startup smoke test is recorded where required.
- [ ] Runtime log review is recorded where runtime launch was performed.
- [ ] Logging/error policy compliance confirmed.
- [ ] Privacy/data handling compliance confirmed.
- [ ] Breaking changes include migration and rollback notes.
- [ ] Handoff notes complete for post-release monitoring.
- [ ] Any `NOT_RUN` validation item has owner, reason, and follow-up.

## Runtime Validation Gate
Before calling a release or handoff fully validated, confirm:
- [ ] App launched on the required platform/device.
- [ ] First screen, scene, route, workflow, or healthcheck loaded.
- [ ] Required startup assets/files loaded or were not applicable.
- [ ] Required startup services initialized or were not applicable.
- [ ] Runtime logs were reviewed.
- [ ] No blocking runtime errors were found.
- [ ] Any runtime error has waiver or remediation plan.

## Detailed Guidance
Evidence block format:
- `Command/Method`: `<COMMAND_OR_METHOD>`
- `Result`: `<PASS|FAIL|NOT_RUN|N/A>`
- `Notes`: `<DETAIL>`
- `Date`: `<DATE_YYYY-MM-DD>`
- `Run By`: `<NAME_OR_AGENT>`
- `Evidence Path`: `<PATH_OR_NONE>`

Post-release readiness:
- monitoring owner
- rollback trigger conditions
- rollback execution owner
- known risk watch list

## Verification Gate
- [ ] All required checks marked complete.
- [ ] Evidence blocks present for every required command or method.
- [ ] Runtime startup evidence is present when required.
- [ ] Runtime log review is present when startup validation was performed.
- [ ] Risks and rollback ownership assigned.
- [ ] No full green light is claimed if required runtime validation is missing.


## Visual and Responsive QA
- [ ] Visual QA required? `<YES|NO>`
- [ ] Screenshot evidence captured when visual behavior changed.
- [ ] Debug-overlay screenshot captured when pathing, hitboxes, placement zones, or map alignment changed.
- [ ] Normal player/user-view screenshot captured when visual behavior changed.
- [ ] Responsive layout checked at fullscreen/maximized, normal non-fullscreen, and smaller resized states when relevant.
- [ ] Owner screenshot approval recorded when required before commit/push.

## Temporary Artifact Review
- [ ] Temporary screenshots/diagnostics/scratch files were stored in the approved temp folder.
- [ ] Temporary folder is ignored by source control unless approved otherwise.
- [ ] Temporary files were cleaned up or summarized in the handoff.
