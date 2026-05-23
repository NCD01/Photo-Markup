# Data Schema Template

Document Path: `<PRIMARY_PATH>/Templates/Data_Module/SCHEMA.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Document canonical schema, entities, payloads, and field contracts for the Data module.
Changes: Initial module template baseline.

## Quick Rules
- Document canonical entities and field contracts.
- Mark optional vs required fields clearly.
- Include compatibility notes for changes.
- Do not rename serialized or persisted fields without migration notes.

## Required Contract
For each schema item include:
- Name
- Direction (`Input|Output|Internal|Persisted`)
- Fields: name, type, required, default, constraints
- Validation rules
- Serialization/persistence key when applicable
- Version/migration notes

## Schema Items
| Name | Direction | Field | Type | Required | Default | Constraints | Key | Notes |
|---|---|---|---|---|---|---|---|---|
| `<SCHEMA_NAME>` | `<DIRECTION>` | `<FIELD>` | `<TYPE>` | `<Yes|No>` | `<DEFAULT>` | `<RULES>` | `<KEY>` | `<NOTES>` |

## Detailed Guidance
- List enum/value domains explicitly.
- Note deprecated fields and sunset timeline.
- Document serialization keys if externally consumed.
- Reference decisions for breaking schema changes.

## Verification Gate
- [ ] Required/optional fields are explicit.
- [ ] Validation rules are testable.
- [ ] Migration notes exist for changed contracts.
- [ ] Serialization/persistence keys are documented.

