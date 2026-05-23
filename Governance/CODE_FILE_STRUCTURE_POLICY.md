# Code File Structure Policy

Document Path: `C:\apps\NCD_Photo_Markup\Governance\CODE_FILE_STRUCTURE_POLICY.md`
Version: `v0.3`
Pack File Version: `v1.7`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Define generic source file organization and module documentation requirements across app stacks.
Changes: Adopted tunable-constants governance standard from latest governance sync and aligned paths to this repo.

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
- `System/Documentation/CHANGELOG.md`

## Detailed Guidance
- Shared values belong in global token/config classes or centralized constants files.
- Feature-specific values may live in feature constants blocks.
- Tunable values (for example: spacing, timing, debounce windows, retry limits, page sizes, sort defaults, control labels, and feature flags) should be grouped in a clearly named constants/config block instead of scattered inline.
- Prefer one edit point per behavior family so maintainers can change values without searching through business logic.
- Inline literals are allowed only for obvious one-off values; repeated literals are considered debt and should be promoted into constants.
- If a file-level constants block grows large, split it into a dedicated feature config/constants file with stable naming.
- Public identifiers include routes, payload keys, database fields, exported class names, and externally consumed enum values.
- Do not rename public identifiers without migration notes and a decision log entry.
- Keep UI layout constants reusable enough that later design changes do not require hunting through screens.

## Verification Gate
- [ ] File organization is understandable and consistent.
- [ ] Inline literal debt is tracked or removed.
- [ ] Tunable values are centralized and editable without hunting through logic.
- [ ] Module doc set exists and is current.
- [ ] Protected public identifiers are unchanged or formally migrated.
- [ ] Deviations are documented with expiration/review date.
