# Decision Log Template

Document Path: `<PRIMARY_PATH>/Operations/DECISION_LOG_TEMPLATE.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Template for recording high-impact project decisions.
Changes: Added status and review fields.

## Quick Rules
- Record high-impact choices at decision time.
- Include alternatives and rationale.
- Include rollback or reversal strategy.
- Link the decision to changelog and affected files.

## Required Contract
Use this entry block:

```md
## DECISION_<ID>
- Date: <DATE_YYYY-MM-DD>
- Status: <Proposed|Accepted|Superseded|Rejected>
- Owner: <OWNER>
- Area: <AREA>
- Decision: <WHAT_WAS_CHOSEN>
- Alternatives Considered:
  - <ALT_1>
  - <ALT_2>
- Rationale: <WHY_THIS_OPTION>
- Impact: <EXPECTED_EFFECT>
- Rollback or Reversal: <HOW_TO_REVERSE>
- Related Changes: <CHANGELOG_VERSION_OR_PATH>
- Review Date: <DATE_YYYY-MM-DD_OR_N/A>
```

## Detailed Guidance
- Use one decision entry per independent choice.
- Avoid mixing unrelated concerns in one entry.
- Link decisions to changelog/release artifacts.
- Supersede rather than delete historical decisions.

## Verification Gate
- [ ] Required fields are complete.
- [ ] Alternatives are meaningful.
- [ ] Rollback/reversal is actionable.
- [ ] Related changes are linked.

