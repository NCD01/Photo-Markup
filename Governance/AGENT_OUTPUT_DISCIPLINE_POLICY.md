# Agent Output Discipline Policy

Document Path: `<PRIMARY_PATH>/Governance/AGENT_OUTPUT_DISCIPLINE_POLICY.md`
Version: `<VERSION>`
Pack File Version: `v1.4`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `2026-05-09`
Purpose: Define concise, evidence-based agent communication so agents do not waste tokens, bypass governance, or assume missing facts.
Changes: Added initial concise output, token discipline, governance obedience, and no-assumption rules.

## Quick Rules
- Be concise by default. Provide only what is needed to move the task forward.
- Do not paste full logs, full files, or repeated standards unless the owner asks for them.
- Obey active governance before speed, convenience, or assumptions.
- Do not assume missing facts. Verify from source files, logs, runtime evidence, or owner-provided context.
- Separate known facts from assumptions, unknowns, and recommendations.
- State blockers clearly and give one exact next action when work is incomplete.

## Required Contract
Before reporting progress or completion, the agent must:
- confirm the task scope in its own working notes
- identify which governance rules apply
- use the shortest useful response that still includes required evidence
- summarize long output instead of dumping it
- cite or list exact evidence paths when files, screenshots, or logs support the result
- state `Unknown` or `Not validated` rather than guessing
- avoid claiming approval, visual correctness, runtime success, or owner acceptance without evidence

## Token Discipline
Agents must avoid token waste by following these rules:
- Do not repeat the full governance block in every response.
- Do not restate unchanged requirements unless they are directly relevant to the result.
- Do not include raw command output when a short pass/fail summary is enough.
- Include only the important error lines from logs unless the owner requests the full log.
- Use compact bullets or tables for status summaries.
- Keep handoff summaries brief but complete.

## No-Assumption Rule
The agent must not assume:
- file paths
- versions
- asset names
- user approval
- successful runtime behavior
- visual correctness
- data schema meaning
- API behavior
- platform behavior
- whether a validation step is optional

If a fact is not available, the agent must either verify it or label it as unknown. Low-risk assumptions may be used only when explicitly marked and when they do not weaken governance, validation, privacy, data handling, or user approval requirements.

## Governance Obedience Rule
When task instructions conflict with active governance, the agent must stop and report the conflict instead of silently bypassing the rule.

The agent must not skip required validation, changelog updates, version bumps, privacy rules, visual approval gates, runtime smoke tests, or handoff requirements unless the owner explicitly approves an exception and the exception is documented.

## Verification Gate
- [ ] Response is concise and avoids repeated boilerplate.
- [ ] Required evidence is summarized, not dumped.
- [ ] Known facts, unknowns, and assumptions are separated.
- [ ] Active governance was followed or any conflict was reported.
- [ ] No full green light is claimed without required evidence.
