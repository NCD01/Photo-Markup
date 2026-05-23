# Constant Blocks Example

Document Path: `C:\apps\NCD_Photo_Markup\Governance\Examples\CONSTANT_BLOCKS_EXAMPLE.md`
Version: `v0.3`
Pack File Version: `v1.7`
Owner: `NCD / M`
Last Updated By: `Codex`
Last Updated: `2026-05-22`
Purpose: Show a practical pattern for centralized tunable constants so behavior can be changed quickly without hunting through logic.
Changes: Adopted constants grouping example for local governance reference.

## Quick Rules
- Put tunable values in one clear place per file/feature.
- Group constants by intent, not by random declaration order.
- Use intent-based names (`kAutosaveDebounceMs`) instead of raw value names (`kValue1`).
- Promote repeated literals into constants.

## Example Pattern (Dart/Flutter)
```dart
// ============================================================================
// Tunable constants for Account Contact Details screen.
// Keep edit points centralized for easy future updates.
// ============================================================================

// Layout/spacing/sizing
const double kPanelGap = 12.0;
const double kSectionGap = 8.0;
const double kToolbarIconSize = 18.0;

// Timing/debounce/retry
const int kAutosaveDebounceMs = 550;
const int kLookupRetryCount = 2;
const Duration kStreetViewFetchTimeout = Duration(seconds: 10);

// Defaults/sort/filter
const String kDefaultSortColumn = 'Name';
const bool kDefaultSortAscending = true;
const int kDefaultPageSize = 50;

// Copy/labels/tooltips
const String kSaveSuccessMessage = 'Saved successfully.';
const String kMissingSelectionMessage = 'No item selected.';
const String kStreetViewTooltip = 'Street View';
```

## Where To Put Constants
- File-level constants block at top of file for feature-local tuning.
- Shared config/token file when values are reused across screens/modules.
- Keep constants close to owning feature unless intentionally global.

## What Should Be Tunable
- UI spacing/sizing values used repeatedly.
- Debounce/throttle/retry/timeout values.
- Default filters/sorts/page sizes.
- Reused UI copy strings and labels.
- Feature behavior toggles that are expected to change.

## What Can Stay Inline
- Truly one-off literals that are obvious and not reused.
- Language/library-required literals with no maintainability value in extraction.

## Verification Gate
- [ ] Repeated literals are extracted into constants.
- [ ] Constants are grouped by intent.
- [ ] Names express purpose, not just data type/value.
- [ ] Changing one behavior family requires one edit point.
