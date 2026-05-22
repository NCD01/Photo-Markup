# UI Design Tokens Template

Document Path: `<PRIMARY_PATH>/Templates/UI_Module/DESIGN_TOKENS.md`
Version: `<VERSION>`
Owner: `<OWNER>`
Last Updated By: `Sarah`
Last Updated: `<DATE_YYYY-MM-DD>`
Purpose: Centralize reusable UI dimensions, spacing, colors, typography, and component behavior tokens.
Changes: Added v1.5 global token layer, selection form, and no one-off UI style rules.

## Quick Rules
- Keep reusable UI values centralized.
- Do not scatter magic numbers across screens.
- Document token purpose, not just value.
- Update screenshots or design docs when tokens materially change UI layout.

## Required Contract
| Token | Value | Purpose | Scope | Notes |
|---|---|---|---|---|
| `<TOKEN_NAME>` | `<VALUE>` | `<PURPOSE>` | `<Global|Module|Screen>` | `<NOTES>` |

Required token groups:
- spacing
- control heights
- breakpoints
- typography
- colors/theme references
- icon sizes
- card/panel dimensions
- animation timings where applicable

## Detailed Guidance
- Prefer semantic names like `controlHeightDefault` over visual guesses like `height40`.
- Keep brand colors or theme references in one location.
- Use comments to explain why a value exists when it affects layout consistency.

## Verification Gate
- [ ] Common layout values are tokenized.
- [ ] Token names are semantic.
- [ ] UI docs and implementation agree.

## v1.5 Global Token Layer Rule
Before UI modernization, create or confirm a governed global token layer.

The token layer should control:
- brand color
- background colors
- text colors
- border colors
- font family
- font sizes
- spacing scale
- border radius
- button heights
- input heights
- card padding
- dialog padding
- table/list density
- hover/focus states

Shared UI primitives must read from the global token layer. If a needed token does not exist, add it to the shared token file and document it in the UI standards document. Do not hard-code final design selections into individual screens or widgets.

