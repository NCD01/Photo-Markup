# Logging and Error Policy

Document Path: `<PRIMARY_PATH>/Governance/LOGGING_AND_ERROR_POLICY.md`
Version: `<VERSION>`
Pack File Version: `v1.3`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Define structured logging, trace continuity, error-code, user-safe error, and runtime log review requirements.
Changes: Added user-safe runtime failure screen requirement.

## Quick Rules
- Use structured logging for app workflows.
- Maintain trace continuity across module boundaries.
- Separate user-safe errors from technical diagnostics.
- Never log secrets, credentials, raw tokens, or sensitive raw payloads.
- Keep error codes stable and documented.
- Review runtime logs before reporting a runtime validation pass.

## Required Contract
Required log schema:

```json
{
  "timestamp": "<ISO_8601_UTC>",
  "level": "<DEBUG|INFO|WARN|ERROR>",
  "trace_id": "<TRACE_ID>",
  "parent_trace_id": "<PARENT_TRACE_ID_OR_NULL>",
  "module": "<MODULE_NAME>",
  "function": "<FUNCTION_NAME>",
  "event": "<EVENT_NAME>",
  "message": "<HUMAN_READABLE_SUMMARY>",
  "error_code": "<DOMAIN-NNNN_OR_NULL>",
  "metadata": {}
}
```

Error contract:
- user-safe channel: short actionable message
- technical channel: code, context, diagnostics
- stable error code format: `<DOMAIN>-<NNNN>`

Minimum required log events:
- workflow entry and exit
- state transitions
- external call start and finish
- persistence start/success/failure
- startup initialization start/success/failure
- startup resource load start/success/failure where resources are required
- handled and unhandled error paths
- validation failures that block save/release

Forbidden logging content:
- credentials, tokens, secrets
- full PII payloads
- raw payment data
- unredacted auth headers
- private documents or full message bodies unless explicitly approved and redacted

Retention contract:
- define retention window
- define cleanup trigger
- document storage path and ownership
- document local vs production retention differences

## Runtime Log Review Requirement
After every runtime launch used for validation, the agent must review console output, log files, and available crash/error output before reporting success.

The agent must specifically check for blocking patterns such as:
- `Unhandled Exception`
- `EXCEPTION CAUGHT`
- `Unable to load asset`
- missing asset, missing file, or empty data
- missing configuration
- `MissingPluginException`
- `Null check operator used on a null value`
- `LateInitializationError`
- `FileSystemException`
- permission denied
- failed assertion
- render/layout failure that blocks the required first screen or scene
- platform-specific startup failure
- hard crash, process exit, frozen launch, or blank first screen

If any blocking pattern appears, the runtime validation result is `FAIL` unless an owner-approved waiver explains why the error is unrelated and non-blocking.

If runtime launch was not performed, log review must be marked `NOT_RUN`, and the agent must not report a full green light.

## User-Safe Runtime Failure Screen
If a required startup asset, config file, route, service, or first scene fails to load, the app must show a clean user-facing error state instead of an unhandled stack trace when the platform allows it.

The user-facing message should be short, actionable, and free of internal secrets.

Example:

```text
The app could not load a required file. Please check the asset or configuration listed in the log.
```

Technical details must be logged separately with an error code, failed resource display name, and diagnostic context.

## Detailed Guidance
Severity mapping:
- `DEBUG`: local investigation and non-critical internals
- `INFO`: normal business milestones
- `WARN`: degraded but recoverable behavior
- `ERROR`: failure that impacts user or system reliability

Trace continuity rules:
- create one root `trace_id` per workflow
- propagate `trace_id` through nested module calls
- child module logs should keep parent trace link where supported

Validation approach:
- schema lint against required keys
- error code uniqueness check
- negative tests for redaction failures
- review sampling to confirm severity consistency
- runtime startup log review for blocking patterns

Anti-patterns:
- free-form string logs without schema keys
- reusing one error code for unrelated failures
- emitting user-facing technical stack traces
- swallowing failures without emitting an `ERROR` log
- claiming runtime validation without reviewing logs
- treating a successful build as proof that startup logs are clean

## Verification Gate
- [ ] All required schema keys present in produced logs.
- [ ] Trace IDs are propagated across boundaries.
- [ ] Error codes are stable and uniquely documented.
- [ ] Redaction checks pass for sensitive fields.
- [ ] Runtime log review was performed when runtime validation was required.
- [ ] Blocking startup/runtime patterns were checked.
- [ ] Retention and cleanup behavior documented.

