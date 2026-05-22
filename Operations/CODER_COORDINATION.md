# Coder Coordination

Document Path: `C:\apps\NCD_Photo_Markup\Operations\CODER_COORDINATION.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Coordinate multi-coder workstreams safely.
Changes: Initialized coordination baseline.

## Current Coordination State
- Master coordination chat/doc: `C:\apps\NCD_Photo_Markup\Operations\SESSION.md`
- Current branch: `master`
- Current app version: `v0.1`
- Last clean checkpoint: `Phase 0 bootstrap workspace initialized; no commits yet`

## Workstreams
| Coder | Scope | Allowed Areas | Current Task | Status |
|---|---|---|---|---|
| `Coder 1` | `Docs/Governance` | `Root docs, Operations, Governance` | `Phase 0 bootstrap` | `Done` |
| `Coder 2` | `UI Runtime` | `Not active yet` | `N/A` | `Idle` |

## Guardrails
- Run `git status --short` before each new update.
- Do not start with unexplained dirty files.
- Separate runtime/data/settings, code/docs/tests, and version bump commits.
- Do not commit or push without explicit owner approval.
