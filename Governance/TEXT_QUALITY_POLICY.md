# Text Quality Policy

Document Path: `<PRIMARY_PATH>/Governance/TEXT_QUALITY_POLICY.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define spelling, grammar, naming, and protected identifier rules for app text and docs.
Changes: Added compatibility exception handling.

## Quick Rules
- Correct spelling and grammar in user-facing text.
- Preserve intent while improving clarity.
- Do not silently rename protected public identifiers.
- Log approved as-is exceptions in the exception register.

## Required Contract
Protected identifiers requiring migration governance:
- public API keys
- serialized payload keys
- route keys
- database field names
- externally consumed enum/value codes
- command names and flags
- file paths consumed by automation

Required process for wording updates:
1. detect text source
2. correct grammar and spelling
3. confirm protected identifiers are unaffected
4. document exceptions when exact text must remain
5. update screenshots/help text when visible UI copy changes

## Detailed Guidance
- If user text is ambiguous, normalize wording and add a note to the change summary.
- If exact legal, branded, quoted, or compatibility phrasing is required, preserve exact phrase and log it.
- Internal/private identifiers in touched files should be corrected unless constrained by compatibility.
- Prefer clear, direct messages over technical language in user-facing errors.

## Verification Gate
- [ ] User-facing text reviewed.
- [ ] Protected identifiers unchanged or formally migrated.
- [ ] As-is exceptions documented when used.
- [ ] Change summary records text-quality decisions.

