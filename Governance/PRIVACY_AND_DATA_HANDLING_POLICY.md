# Privacy and Data Handling Policy

Document Path: `<PRIMARY_PATH>/Governance/PRIVACY_AND_DATA_HANDLING_POLICY.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define how app data, sensitive fields, local files, logs, and exports must be handled.
Changes: Initial privacy/data policy added to generic pack.

## Quick Rules
- Classify data before implementation or import.
- Minimize collection, storage, logging, and export of sensitive data.
- Use redaction by default for logs, screenshots, exports, and diagnostics.
- Do not use production data locally unless the app profile allows it.
- Document who owns cleanup, retention, and recovery.

## Required Contract
Data classification levels:
- `Public`: safe to share externally.
- `Internal`: business/project information not intended for public release.
- `Confidential`: client, employee, financial, operational, or proprietary information.
- `Sensitive`: secrets, credentials, payment data, regulated information, or highly personal information.

Every module handling data must document:
- data owner
- data class
- storage location
- retention period
- backup/recovery path
- redaction rules
- export/share rules
- deletion/archive process

Forbidden by default:
- logging secrets or tokens
- committing real credentials
- storing unencrypted sensitive data without owner approval
- sending production data to unapproved tools or services
- sharing raw client/user data in screenshots or debug artifacts

## Detailed Guidance
- Use fake or sanitized fixtures for tests.
- Keep `.env`, secrets, and local credentials out of repos.
- Redact emails, phone numbers, addresses, IDs, tokens, and payment fields unless full values are required and approved.
- When a data contract changes, update schema docs, migration notes, changelog, and validation tests.
- If a privacy requirement conflicts with a convenience workflow, privacy wins unless the owner explicitly approves a safer exception.

## Verification Gate
- [ ] Data classification is documented in `System/Documentation/APP_PROFILE.md`.
- [ ] Sensitive fields are identified and redacted where appropriate.
- [ ] Test fixtures avoid real production data.
- [ ] Retention and cleanup path is documented.
- [ ] No secrets are present in docs, logs, or committed files.

