# Governance Index

Document Path: `<PRIMARY_PATH>/Governance/README.md`
Version: `<VERSION>`
Pack File Version: `v1.4`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Index of active governance policies for the documentation pack.
Changes: Added output discipline governance for concise, evidence-based, no-assumption agent responses.

## Quick Rules
- Governance files are policy authority for this pack.
- If template content conflicts with governance, governance wins.
- Keep section names stable across governance files.
- Keep language-specific requirements in `Language_Addendums/`.

## Required Contract
Policy set:
- `AGENT_EXECUTION_POLICY.md`
- `AGENT_OUTPUT_DISCIPLINE_POLICY.md`
- `CODE_FILE_STRUCTURE_POLICY.md`
- `LOGGING_AND_ERROR_POLICY.md`
- `PRIVACY_AND_DATA_HANDLING_POLICY.md`
- `RELEASE_AND_VALIDATION_POLICY.md`
- `TEXT_QUALITY_POLICY.md`
- `VERSIONING_AND_CHANGE_CONTROL.md`

Optional language/framework addendums:
- `Language_Addendums/DART_FLUTTER_ADDENDUM.md`

## Detailed Guidance
Open in this order:
1. `AGENT_EXECUTION_POLICY.md`
2. `AGENT_OUTPUT_DISCIPLINE_POLICY.md`
3. `VERSIONING_AND_CHANGE_CONTROL.md`
4. `RELEASE_AND_VALIDATION_POLICY.md`
5. `LOGGING_AND_ERROR_POLICY.md`
6. `PRIVACY_AND_DATA_HANDLING_POLICY.md`
7. `TEXT_QUALITY_POLICY.md`
8. `CODE_FILE_STRUCTURE_POLICY.md`
9. relevant language/framework addendum

## Verification Gate
- [ ] All policy files exist.
- [ ] Cross-links resolve.
- [ ] Language-specific rules are not forced on unrelated stacks.
- [ ] Policy sections include contracts and gates.


## v1.3 Added Governance
- `TEMPORARY_ARTIFACT_POLICY.md` defines where agents may place screenshots, diagnostics, generated files, and scratch outputs.
- `Language_Addendums/GAME_UI_RUNTIME_ADDENDUM.md` defines coordinate-system, visual QA, responsive layout, and game runtime evidence rules for game/map/canvas projects.


## v1.4 Added Governance
- `AGENT_OUTPUT_DISCIPLINE_POLICY.md` defines concise output, token discipline, governance obedience, and no-assumption behavior for agents.
