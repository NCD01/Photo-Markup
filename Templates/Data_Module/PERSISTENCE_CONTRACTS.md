# Data Persistence Contracts Template

Document Path: `<PRIMARY_PATH>/Templates/Data_Module/PERSISTENCE_CONTRACTS.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Document storage ownership, migrations, backups, retention, cleanup, and recovery for data modules.
Changes: Initial data persistence template added.

## Quick Rules
- Define the canonical source of truth.
- Document migration and recovery before schema changes.
- Keep backups and retention rules explicit.
- Do not store sensitive data without classification and protection rules.

## Required Contract
| Data Set | Source of Truth | Storage Path/Service | Data Class | Backup | Retention | Migration Owner | Recovery Method |
|---|---|---|---|---|---|---|---|
| `<DATA_SET>` | `<SOURCE>` | `<PATH_OR_SERVICE>` | `<CLASS>` | `<BACKUP_RULE>` | `<RETENTION>` | `<OWNER>` | `<METHOD>` |

## Detailed Guidance
- Document local, test, and production storage differences.
- Include backup frequency and restore steps.
- Add tests or manual validation steps for migrations.
- Link schema changes to changelog and decision logs.

## Verification Gate
- [ ] Source of truth is clear.
- [ ] Migration path is documented for changed data.
- [ ] Backup and recovery steps are testable.
- [ ] Retention and cleanup rules are defined.
