# New App Bootstrap Checklist Template

Document Path: `C:\apps\NCD_Photo_Markup\Operations\CHECKLIST_NEW_APP_BOOTSTRAP.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `<LAST_UPDATED_BY>`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Checklist for preparing a new app documentation and governance baseline before feature development.
Changes: Added data classification and validation setup.

## Quick Rules
- Finish bootstrap before feature development.
- Replace all placeholders before first release branch.
- Confirm governance adoption with owner sign-off.
- Commit the baseline before large implementation changes.

## Required Contract
- [ ] `<APP_NAME>` scope and owner confirmed.
- [ ] `System/Documentation/APP_PROFILE.md` created from template.
- [ ] Governance files reviewed and accepted.
- [ ] Module boundaries set (`UI`, `API`, `Engine`, `Data`, or project-specific replacements).
- [ ] Placeholder token replacement pass completed.
- [ ] Data classification selected.
- [ ] Privacy handling rules confirmed.
- [ ] Logging schema and error code domain selected.
- [ ] Versioning and release process configured.
- [ ] Initial changelog created.
- [ ] Initial decision log created.
- [ ] Validation matrix created with real commands.
- [ ] First clean validation pass recorded.

## Detailed Guidance
- Add architecture and contract stubs before implementation.
- Identify external dependencies and diagnostics requirements early.
- Confirm migration policy for protected identifiers.
- Decide which language/framework addendums apply.

## Verification Gate
- [ ] Checklist fully complete.
- [ ] Unchecked items have explicit deferral owner/date.
- [ ] Bootstrap artifact set is committed and linked.

