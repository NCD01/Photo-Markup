# Data Module README Template

Document Path: `<PRIMARY_PATH>/Templates/Data_Module/README.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define Data module scope, dependencies, ownership, and public contracts.
Changes: Initial module template baseline.

## Quick Rules
- Define module scope, dependencies, and ownership.
- Keep contracts aligned with adjacent module boundaries.
- Update this file when behavior changes.
- Link to companion docs rather than duplicating detailed contracts.

## Required Contract
- Module Name: `<MODULE_NAME>`
- Owner: `<OWNER>`
- Source Path: `<PRIMARY_PATH>`
- Dependencies: `<DEPENDENCY_LIST>`
- Public Interfaces: `<INTERFACE_LIST>`
- Error Code Domain: `<DOMAIN_OR_N/A>`
- Data Classification: `<CLASSIFICATION_OR_N/A>`

Required companion docs:
- `SCHEMA.md`
- `FUNCTIONS.md`
- `TESTING.md`
- `DTO_ALIGNMENT.md`
- `CHANGELOG.md`

## Detailed Guidance
- Scope should state what this module does and does not do.
- Public interface list should reference exact symbols, routes, contracts, or screens.
- Include logging and error-code responsibilities for this module.
- Document dependencies on external services, storage, config, or global tokens.

## Verification Gate
- [ ] Scope and ownership are explicit.
- [ ] Companion docs exist and are populated.
- [ ] Interfaces match implementation contracts.
- [ ] Data/logging/error responsibilities are clear.
