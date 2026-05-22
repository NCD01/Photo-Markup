# API Error Codes Template

Document Path: `<PRIMARY_PATH>/Templates/API_Module/ERROR_CODES.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Define stable API error code domains, meanings, user-safe messages, and technical diagnostics.
Changes: Initial API error code template added.

## Quick Rules
- Keep error codes stable.
- Do not reuse one code for unrelated failures.
- Separate user-safe message from technical details.
- Link error codes to logs and tests.

## Required Contract
| Error Code | User-Safe Message | Technical Meaning | Retryable | Logged Event | Test ID |
|---|---|---|---|---|---|
| `<DOMAIN-0001>` | `<MESSAGE>` | `<TECHNICAL_MEANING>` | `<Yes|No>` | `<EVENT>` | `<TEST_ID>` |

## Detailed Guidance
- Use domain prefixes that match the module or workflow.
- Do not expose stack traces, secrets, or raw payloads to the user.
- Add regression tests when adding or changing error code behavior.

## Verification Gate
- [ ] Error codes are unique.
- [ ] User-safe messages are clear.
- [ ] Technical meanings are actionable.
- [ ] Tests cover error paths.
