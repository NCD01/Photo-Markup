# Validation Matrix

Document Path: `C:\apps\NCD_Photo_Markup\Operations\VALIDATION_MATRIX.md`
Version: `v0.1`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Track required validation activities and outcomes.
Changes: Initialized Phase 0 validation matrix for Flutter workflow.

## Validation Matrix
| ID | Validation | Command/Method | Trigger | Pass Criteria | Owner | Status | Evidence Path |
|---|---|---|---|---|---|---|---|
| `VAL-001` | Dependency Restore | `flutter pub get` | Dependencies change | Dependencies restore successfully | `NCD / M` | `NOT_RUN` | `Not applicable in Phase 0 (no Flutter project yet)` |
| `VAL-002` | Static Analysis | `flutter analyze` | Code/config changes | No blocking analysis/lint issues | `NCD / M` | `NOT_RUN` | `Not applicable in Phase 0` |
| `VAL-003` | Automated Tests | `flutter test` | Behavior changes | Tests pass | `NCD / M` | `NOT_RUN` | `Not applicable in Phase 0` |
| `VAL-004` | Build/Package | `flutter build windows --debug` | Build/runtime/dependency changes | Build succeeds | `NCD / M` | `NOT_RUN` | `Not applicable in Phase 0` |
| `VAL-005` | Runtime Startup Smoke Test | `flutter run -d windows` | Startup/routing/assets changes | App launches to expected screen | `NCD / M` | `NOT_RUN` | `No app runtime exists yet` |
| `VAL-006` | Runtime Log Review | `Review flutter run console` | Startup test is run | No blocking runtime errors found | `NCD / M` | `NOT_RUN` | `No runtime executed` |
| `VAL-007` | Privacy/Redaction | `Manual document review` | Data/log/screenshot/export changes | No sensitive data exposure | `NCD / M` | `PASS` | `Current docs reviewed` |
| `VAL-008` | Docs/Changelog | `Manual review` | Any versioned change | Docs/changelog aligned | `NCD / M` | `PASS` | `v0.1 bootstrap docs` |
| `VAL-009` | Visual QA | `Manual screenshot review` | UI visible changes | Visual evidence captured | `NCD / M` | `N/A` | `No UI implementation in Phase 0` |
| `VAL-010` | Responsive Layout | `Manual resize checks` | Layout/resize changes | Content visible and usable | `NCD / M` | `N/A` | `No UI implementation in Phase 0` |
| `VAL-011` | Temporary Artifact Review | `Folder review (.agent_temp)` | Temp files created | Temp files in approved folder | `NCD / M` | `PASS` | `Folders created and ignored` |
