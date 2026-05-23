# Agent Execution Policy

Document Path: `<PRIMARY_PATH>/Governance/AGENT_EXECUTION_POLICY.md`
Version: `<VERSION>`
Pack File Version: `v1.4`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Define how agents plan, modify, validate, document, and hand off work.
Changes: Added v1.4 concise output, token discipline, governance obedience, and no-assumption execution rules.

## Quick Rules
- Follow authority order: app profile, master guideline, active governance, task-specific constraints.
- Be concise and avoid wasting tokens with repeated boilerplate or unnecessary raw output.
- Do not assume missing facts; verify them or mark them as unknown.
- Do not claim completion without validation evidence or a recorded validation limitation.
- Track major decisions and handoff state using operations templates.
- Escalate ambiguity that impacts behavior, safety, privacy, or data integrity.
- Avoid broad rewrites when a targeted change is sufficient.

## Required Contract
Every work session must produce or update as applicable:
- session record from `Operations/SESSION_TEMPLATE.md`
- decision record for high-impact choices
- handoff record for unfinished or transferred work
- changelog entry for versioned changes
- validation evidence for changed scope

Required completion evidence:
- files changed
- commands run
- pass/fail/not-run outcomes
- assumptions or unknowns, if any
- known risks and mitigation
- rollback/recovery note when release-impacting

## Detailed Guidance
Authority order implementation:
1. `System/Documentation/APP_PROFILE.md`
2. `Governance/MASTER_GUIDELINE.md`
3. active governance policies
4. module documentation
5. task-specific request

High-impact decision examples:
- data contract or schema changes
- migration or storage changes
- public API changes
- error code strategy changes
- logging schema changes
- security/privacy changes
- irreversible operations

Handoff must identify exact next action, not generic status.

## Output Discipline Rule
Agent responses must be concise, evidence-based, and governed.

The agent must not:
- paste full logs when a short summary is enough
- repeat full governance text in every response
- claim facts without evidence
- assume approval, runtime success, visual correctness, or version status
- bypass active governance for speed

When evidence is missing, use `Unknown`, `Not validated`, or `Not run` instead of guessing.

## Verification Gate
- [ ] Session record created or updated when required.
- [ ] Decision record updated for high-impact choices.
- [ ] Handoff includes next action and blockers when incomplete.
- [ ] Completion evidence includes command results.


## Five-Minute Stop Rule
If the agent cannot resolve a specific issue after about 5 minutes of focused debugging, the agent must stop and report instead of continuing repeated guesses.

The report must include files changed, commands run, evidence found, screenshots/logs when relevant, current hypothesis, recommended next step, and whether any changes should be reverted.

