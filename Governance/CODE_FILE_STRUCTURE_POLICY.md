# Code File Structure Policy

Document Path: `<PRIMARY_PATH>/Governance/CODE_FILE_STRUCTURE_POLICY.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define generic source file organization and module documentation requirements across app stacks.
Changes: Replaced required Dart-only file structure with stack-neutral policy.

## Quick Rules
- Centralize repeated constants, tokens, strings, and layout values.
- Separate UI, API, engine/business logic, and data/persistence concerns.
- Keep public contracts documented near the module that owns them.
- Track intentional deviations with rationale and review date.

## Required Contract
Each governed source file should make these areas easy to identify:
1. file header or module comment when project standard requires it
2. imports/dependencies
3. constants/tokens/configuration
4. types/classes/interfaces
5. public functions/methods
6. private helpers

Required module documentation set:
- `README.md`
- `SCHEMA.md`
- `FUNCTIONS.md`
- `TESTING.md`
- `DTO_ALIGNMENT.md`
- `CHANGELOG.md`

## Detailed Guidance
- Shared values belong in global token/config classes or centralized constants files.
- Feature-specific values may live in feature constants blocks.
- Public identifiers include routes, payload keys, database fields, exported class names, and externally consumed enum values.
- Do not rename public identifiers without migration notes and a decision log entry.
- Keep UI layout constants reusable enough that later design changes do not require hunting through screens.

## Verification Gate
- [ ] File organization is understandable and consistent.
- [ ] Inline literal debt is tracked or removed.
- [ ] Module doc set exists and is current.
- [ ] Protected public identifiers are unchanged or formally migrated.
- [ ] Deviations are documented with expiration/review date.
