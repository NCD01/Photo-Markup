# Changelog Template

Document Path: `<PRIMARY_PATH>/Templates/Project_Docs/CHANGELOG_TEMPLATE.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Canonical changelog template for project and module changes.
Changes: Strengthened validation and rollback fields.

## Quick Rules
- One entry per approved change set.
- Version tags must be monotonic.
- Changelog, release notes, and artifact versions must agree.
- Include validation evidence and rollback/recovery notes each time.

## Required Contract
Use this entry block for every change:

```md
## <VERSION> - <DATE_YYYY-MM-DD>
- Owner: <OWNER>
- Author: <AUTHOR>
- Type: <Feature|Fix|Refactor|Documentation|Logging|Structural|Security|Data>
- Reason: <WHY_CHANGE_WAS_NEEDED>
- Scope:
  - <FILE_OR_MODULE_1>
  - <FILE_OR_MODULE_2>
- Changes:
  - <CHANGE_1>
  - <CHANGE_2>
- Validation Evidence:
  - <COMMAND>: <PASS|FAIL|NOT_RUN + NOTE>
  - <COMMAND>: <PASS|FAIL|NOT_RUN + NOTE>
- Risks / Known Gaps:
  - <RISK_OR_NONE>
- Rollback / Recovery Notes:
  - <ROLLBACK_PLAN_OR_RECOVERY_STEP>
```

## Detailed Guidance
- `Type` should describe the primary intent, not side effects.
- `Reason` must explain user or system impact.
- `Scope` should list exact files/modules touched.
- Validation evidence must include exact command labels.
- If validation was not run, record why and who owns follow-up.
- Rollback notes must be actionable within one deployment cycle.

## Verification Gate
- [ ] Entry includes all required fields.
- [ ] Version matches release artifacts.
- [ ] Validation evidence is concrete.
- [ ] Risks/gaps are explicit.
- [ ] Rollback or recovery notes are executable.

