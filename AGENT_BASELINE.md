# Agent Baseline 

Document Path: `C:\apps\NCD_Photo_Markup/AGENT_BASELINE.md`
Version: `v0.1`
Pack File Version: `v1.5`
Owner: `NCD / M`
Last Updated By: `Sarah`
Last Updated: `2026-05-15`
Purpose: Short reusable instruction block for code/documentation agents working inside this app.
Changes: Added v1.5 workstream separation, UI standards, form definitions, and data/runtime separation requirements.

## Quick Rules
- Read `APP_PROFILE.md`, `MASTER_GUIDELINE.md`, and active governance before changing files.
- Make the smallest safe change that satisfies the task.
- Be concise; do not waste tokens with repeated standards, raw dumps, or unnecessary explanation.
- Obey governance first. If a task conflicts with governance, report the conflict instead of bypassing it.
- Do not assume missing facts. Verify them from source files, logs, runtime evidence, or owner-provided context.
- Do not weaken governance, validation, privacy, logging, or versioning rules without owner approval.
- Do not claim completion without command-level validation evidence or a clear reason validation could not be run.
- Do not treat a successful build as full app validation.
- Keep app-specific assumptions out of generic templates.
- Do not claim visual/UI/gameplay work is complete without required visual evidence.
- Stop and report if a focused issue cannot be resolved after about 5 minutes of debugging.
- Keep temporary screenshots, diagnostics, generated files, and scratch outputs out of production folders.

## Required Contract
Every agent work session must:
- identify files changed
- identify docs that need updates
- update changelog or explain why no versioned change was made
- keep progress and closeout notes concise while preserving required evidence
- separate known facts from assumptions, unknowns, and recommendations
- run or record required validation commands
- run runtime startup validation when the change can affect app launch, assets, routing, configuration, storage, platform setup, engine initialization, dependency loading, or the first user-visible screen
- review logs before reporting success
- preserve protected identifiers unless migration is approved
- produce handoff notes when work is incomplete

## No False Green Light Policy
The agent must not report `PASS`, `validated`, `ready`, `complete`, `green light`, or equivalent language based only on dependency restore, static analysis, automated tests, or build success.

Before reporting full completion, the agent must confirm:
- dependency restore passed, where applicable
- static analysis or lint passed, where applicable
- automated tests passed, where applicable
- build/package passed, where applicable
- the app launched successfully, where runtime validation is required
- the first required screen, scene, route, or workflow loaded
- logs were reviewed after launch
- no unhandled exception, missing asset, missing file, configuration error, or startup crash appeared in logs
- validation evidence was documented

If runtime startup validation was not performed, the agent must state:

```text
Build validation passed, but runtime startup validation was not performed. This is not a full green light.
```

## Output Discipline and No-Assumption Rule
The agent must keep responses brief, evidence-based, and governed.

Required behavior:
- summarize long logs instead of pasting full logs
- list exact changed files instead of explaining unchanged areas
- state `Unknown` or `Not validated` when evidence is missing
- never assume visual approval, runtime success, asset validity, path correctness, version status, or owner acceptance
- use one clear next action when the work is incomplete

If the agent cannot verify a fact, it must not present that fact as confirmed.


## Visual QA Gate
When a change affects UI layout, screen scaling, maps, sprites, animation, gameplay pathing, image placement, visual assets, or user-visible behavior, automated checks are not enough.

The agent must provide visual evidence before claiming the work is complete.

Required visual evidence:
- screenshot of the affected screen or scene
- screenshot at a normal/non-fullscreen window size when responsive behavior is relevant
- screenshot with debug overlay enabled when pathing, hitboxes, placement zones, or map alignment are affected
- screenshot with debug overlay disabled for normal player view

The agent must compare the screenshot against the task acceptance criteria and state whether each visual requirement passed or failed.

The agent must not commit or push visual work until owner approval is given when the task specifically requires screenshot approval.

## Five-Minute Stop Rule
If the agent cannot resolve a specific issue after about 5 minutes of focused debugging, the agent must stop and report instead of continuing with repeated guesses.

The stop report must include:
- issue being debugged
- files changed
- commands run
- evidence found
- screenshots/logs if relevant
- current hypothesis
- recommended next step
- whether any changes should be reverted

The agent must wait for owner direction before continuing.

## Temporary Artifact Policy
Agents must not place screenshots, diagnostics, generated images, scratch files, or temporary outputs inside production asset, image, data, or documentation folders unless the file is intended to become a governed project artifact.

Each app must define a temporary work folder in `APP_PROFILE.md`. The temporary folder should be ignored by source control unless the project owner approves a different rule.

Agents must clean up or summarize temporary files at handoff.

## Detailed Guidance
Use this compact instruction block when starting a new agent task:

```text
Apply the New App Agent Baseline.
First read APP_PROFILE.md, MASTER_GUIDELINE.md, Governance/README.md, Operations/VALIDATION_MATRIX.md, Operations/RUNTIME_STARTUP_SMOKE_TEST.md, Operations/VISUAL_QA.md, and any module README affected by this task.
Follow versioning, changelog, privacy, logging, validation, runtime startup, visual QA, temporary artifact, and text-quality policies.
Make the smallest safe change, update matching docs, run required validation, review logs, and summarize changed files, validation results, runtime startup result, risks, and next action.
Do not rename public identifiers or change data contracts without migration notes and a decision log entry.
Do not mark the work green unless required runtime startup validation has passed or is clearly recorded as NOT_RUN with owner follow-up.
```

Agent behavior priorities:
1. preserve data and user trust
2. maintain build and runtime stability
3. keep documentation accurate
4. keep changes traceable and reversible
5. avoid broad rewrites unless requested

## Verification Gate
- [ ] Agent read path is clear.
- [ ] Required closeout evidence is listed.
- [ ] Protected identifier rule is explicit.
- [ ] Runtime startup validation rule is explicit.
- [ ] No false green light language is explicit.
- [ ] Visual QA gate is explicit.
- [ ] Five-minute stop rule is explicit.
- [ ] Temporary artifact policy is explicit.
- [ ] Baseline can be pasted into a new agent task without project-specific cleanup.

## v1.5 Workstream Separation and Data Discipline
- When multiple agents/coders are active, follow the active coder coordination record and do not edit another workstream's files.
- Start from a clean `git status --short` unless the owner explicitly approves a dirty-tree task.
- Separate UI/design-system changes from business-logic, data, documentation, and version-bump commits.
- Treat runtime/UI state, live data, generated artifacts, and code as separate classes.
- Do not revert, stash, or commit live data without the project-specific rule and backup requirements from `APP_PROFILE.md`.
- UI work must follow the active UI standards document and shared token/component layer before changing individual screens.
- New or significantly changed forms/screens must update the active form definitions document.


