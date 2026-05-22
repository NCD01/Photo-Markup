# Data DTO Alignment Template

Document Path: `<PRIMARY_PATH>/Templates/Data_Module/DTO_ALIGNMENT.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Keep DTO definitions synchronized across module boundaries for the Data module.
Changes: Initial module template baseline.

## Quick Rules
- Keep DTO definitions synchronized across layers.
- Document mapping rules and transformation ownership.
- Track compatibility impacts for DTO changes.
- Avoid lossy transformations unless documented and approved.

## Required Contract
For each DTO include:
- DTO Name
- Source Layer
- Target Layer
- Field Mapping
- Transform Rules
- Nullability/Default Rules
- Compatibility Notes
- Migration Notes when changed

## DTO Matrix
| DTO | Source | Target | Field Mapping | Transform Rules | Nullability/Defaults | Compatibility Notes |
|---|---|---|---|---|---|---|
| `<DTO_NAME>` | `<SOURCE>` | `<TARGET>` | `<MAPPING>` | `<RULES>` | `<NULL_DEFAULTS>` | `<NOTES>` |

## Detailed Guidance
- Explicitly note lossy transformations.
- Document canonical source-of-truth field names.
- Include migration path when renaming serialized fields.
- Link changed DTOs to schema docs and changelog entries.

## Verification Gate
- [ ] All active DTOs are listed.
- [ ] Mapping rules are complete.
- [ ] Compatibility notes are present for changed DTOs.
- [ ] Migration notes exist for renamed/removed fields.
