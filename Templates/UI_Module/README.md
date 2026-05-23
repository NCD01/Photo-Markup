# UI Module README Template

Document Path: `<PRIMARY_PATH>/Templates/UI_Module/README.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define UI module scope, dependencies, ownership, and public contracts.
Changes: Added v1.5 UI standards, form definitions, and token source-of-truth companion docs.

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
- `System/Documentation/CHANGELOG.md`

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

## v1.5 Companion UI Governance Docs
Recommended companion docs for UI modules:
- `DESIGN_TOKENS.md`
- `UI_STANDARDS_TEMPLATE.md`
- `UI_STANDARDS_SELECTION_FORM_TEMPLATE.md`
- `FORM_DEFINITIONS_TEMPLATE.md`

Use UI standards and token docs before broad visual changes. Use form definitions to document forms/screens, child components, routes, services, and data sources.


