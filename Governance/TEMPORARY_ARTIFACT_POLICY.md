# Temporary Artifact Policy

Document Path: `<PRIMARY_PATH>/Governance/TEMPORARY_ARTIFACT_POLICY.md`
Version: `<VERSION>`
Pack File Version: `v1.5`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Define where agents may place screenshots, diagnostics, generated files, and scratch outputs.
Changes: Added v1.5 multi-agent temporary artifact and screenshot routing guidance.

## Quick Rules
- Do not place temporary files in production asset, image, data, source, or documentation folders unless the file is intended to become a governed artifact.
- Each app must define an agent temporary work folder in `System/Documentation/APP_PROFILE.md`.
- Temporary folders should be ignored by source control unless the owner approves tracking specific evidence files.
- Handoffs must summarize temporary files created, kept, cleaned up, or intentionally promoted.

## Required Contract
Each app must define:

| Temp Artifact Type | Required Folder |
|---|---|
| Scratch root | `<APP_ROOT>/.agent_temp` |
| Screenshots | `<APP_ROOT>/.agent_temp/screenshots` |
| Diagnostics/log copies | `<APP_ROOT>/.agent_temp/diagnostics` |
| Scratch/generated files | `<APP_ROOT>/.agent_temp/scratch` |

The source-control ignore rules must include:

```text
.agent_temp/
```

unless the owner approves a different pattern.

## Forbidden Temporary Locations
Agents must not store scratch or generated files in:
- production assets folders
- production image folders
- source code folders, unless creating real source files
- data/persistence folders
- governed documentation folders, unless creating approved documentation
- user-provided input folders

## Handoff Requirement
When temporary files are created, the handoff must include:
- temp root used
- screenshot folder used
- diagnostics folder used
- scratch folder used
- cleanup status
- evidence files intentionally kept
- files promoted into governed project folders, if any

## Verification Gate
- [ ] Temporary folders are defined in `System/Documentation/APP_PROFILE.md`.
- [ ] Temporary folders are ignored by source control.
- [ ] No scratch files are stored in production folders.
- [ ] Handoff summarizes cleanup/evidence status.

## v1.5 Multi-Agent Temporary Artifact Rule
When multiple agents are active, temporary files must include enough naming context to identify the task or workstream, such as:
- `.agent_temp/screenshots/<phase>_<before_or_after>_<screen>.png`
- `.agent_temp/<workstream>_<timestamp>/`

Agents must not place screenshots, diagnostics, or scratch outputs in another workstream's production folders.


