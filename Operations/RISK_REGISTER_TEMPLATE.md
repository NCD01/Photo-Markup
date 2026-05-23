# Risk Register Template

Document Path: `<PRIMARY_PATH>/Operations/RISK_REGISTER_TEMPLATE.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Track active project risks, mitigations, owners, and review dates.
Changes: Initial template baseline.

## Quick Rules
- Track risks before they become defects.
- Assign one owner per risk.
- Review high risks before release.
- Close risks with evidence, not assumptions.

## Required Contract
| Risk ID | Area | Risk | Likelihood | Impact | Mitigation | Owner | Status | Review Date |
|---|---|---|---|---|---|---|---|---|
| `RISK-001` | `<AREA>` | `<RISK>` | `<Low|Medium|High>` | `<Low|Medium|High>` | `<MITIGATION>` | `<OWNER>` | `<Open|Monitoring|Closed>` | `<DATE>` |

## Detailed Guidance
Common risk areas:
- data loss
- privacy exposure
- migration failure
- release instability
- untested workflow
- undocumented behavior
- dependency or platform change

## Verification Gate
- [ ] Open high risks have mitigations.
- [ ] Release-blocking risks are resolved or waived.
- [ ] Review dates are current.

