# Decision Log

Document Path: `C:\apps\NCD_Photo_Markup\Operations\DECISION_LOG.md`
Version: `v0.5`
Owner: `NCD / M`
Last Updated By: `Claude`
Last Updated: `2026-08-19`
Purpose: Record material architecture/process decisions.
Changes: Added DECISION-030, dimensions self-label when a scale is set.

## DECISION-001
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Governance
- Decision: Adopt Governance v1.5/NewApp Documentation Pack v1.5 as project baseline.
- Alternatives Considered:
- Recreate docs manually.
- Delay governance until after code starts.
- Rationale: Enforces validation, versioning, and documentation discipline from day one.
- Impact: Stronger change control and cleaner future handoffs.
- Rollback or Reversal: Replace baseline with a newer approved pack via explicit migration decision.
- Related Changes: v0.1 bootstrap docs
- Review Date: N/A

## DECISION-002
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Product Sequencing
- Decision: Build standalone Flutter app first for Windows touchscreen tablet, then add Android support later.
- Alternatives Considered:
- Build Android first.
- Start inside Control Center immediately.
- Rationale: Windows-first field workflow is primary near-term requirement.
- Impact: Platform adapters and integration deferred to later phases.
- Rollback or Reversal: Reprioritize platform order with explicit owner approval.
- Related Changes: v0.1 bootstrap docs
- Review Date: N/A

## DECISION-003
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Repository Structure and Governance
- Decision: Keep lean root layout with hooks under `Governance/.githooks` and scripts under root `scripts/`.
- Alternatives Considered:
- Keep hooks at root `.githooks`.
- Keep docs mixed at root.
- Rationale: Maintains clean repo navigation while preserving explicit governance boundaries.
- Impact: Root contains only essential files/folders; hook setup script points to `Governance/.githooks`.
- Rollback or Reversal: Restore root `.githooks` and adjust setup script if owner later prefers default root hook layout.
- Related Changes: Phase 1A.1 lean-root + governance sync (uncommitted workspace)
- Review Date: N/A

## DECISION-004
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Flutter Code Structure
- Decision: Centralize current shell tunable values into `app/lib/core/constants/app_constants.dart`.
- Alternatives Considered:
- Keep all literals inline in `main.dart`.
- Split many micro-constant files during cleanup.
- Rationale: Meets governance tunable-constants requirement without broad refactor.
- Impact: App title/version/theme/labels/extensions/copy/layout values now have clear edit points.
- Rollback or Reversal: Move values back inline if owner rejects constants approach.
- Related Changes: Governance v1.7 tunable constants adoption (uncommitted workspace)
- Review Date: N/A

## DECISION-005
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: Markup MVP Architecture
- Decision: Implement Phase 1C dimension line using a separate overlay/model layer with no changes to original image files.
- Alternatives Considered:
- Draw directly into image pixels.
- Keep all markup logic inline in one widget without model separation.
- Rationale: Preserves original photo and keeps a clean expansion path for future tools.
- Impact: Added `DimensionLine` model, `MarkupTool` enum, and `DimensionLinesOverlay` widget; Undo removes latest line state.
- Rollback or Reversal: Revert feature files and toolbar tool-state wiring if owner rejects current MVP interaction.
- Related Changes: Phase 1C dimension MVP (uncommitted workspace)
- Review Date: N/A

## DECISION-006
- Date: 2026-05-22
- Status: Accepted
- Owner: NCD / M
- Area: UI/Runtime Boundaries
- Decision: Constrain dimension drawing to the actual displayed image rectangle and load splash/icon branding from app-local assets.
- Alternatives Considered:
- Allow lines to extend into non-image canvas space.
- Load runtime branding directly from `System/Documentation/Images`.
- Rationale: Prevents false markups outside photo bounds and keeps runtime assets decoupled from documentation storage.
- Impact: Drag points are clamped, overlay is clipped to image rect, branding assets are copied into `app/assets/branding/`, Windows runner icon is replaced from approved v1.5 source, and splash duration remains tunable via constants.
- Rollback or Reversal: Remove clamp/clip logic and revert branding references if owner requests a different workflow.
- Related Changes: Phase 1C approved image assets + dimension bounds fix (uncommitted workspace)
- Review Date: N/A

## DECISION-007
- Date: 2026-05-23
- Status: Accepted
- Owner: NCD / M
- Area: Dimension Label UX
- Decision: Add post-draw manual label dialog with optional Save/Skip and lightweight feet/inches normalization for common inputs.
- Alternatives Considered:
- Delay labels entirely until full Text Note tool phase.
- Force raw text only with no normalization.
- Rationale: Meets immediate field need for measurement annotations while keeping implementation low risk and touch-friendly.
- Impact: Dimension lines now support label add/edit; labels render in bounded readable chips; undo removes line + label together.
- Rollback or Reversal: Disable dialog entry flow and remove label rendering/formatter if owner rejects current behavior.
- Related Changes: Phase 1D manual label workflow (uncommitted workspace)
- Review Date: N/A

## DECISION-008
- Date: 2026-05-23
- Status: Accepted
- Owner: NCD / M
- Area: Dialog Lifecycle Safety
- Decision: Move dimension label `TextEditingController` ownership into a dedicated dialog `StatefulWidget` and submit through one shared callback for Enter/Save.
- Alternatives Considered:
- Keep controller in parent method and dispose after dialog await.
- Use inline stateless dialog with parent-owned controller.
- Rationale: Prevents runtime crash (`TextEditingController used after dispose`) seen during Save/Enter path.
- Impact: Save/Enter/Skip/Cancel now use dialog-local controller lifecycle and no disposed-controller assertions.
- Rollback or Reversal: Revert to prior inline dialog only if a safer equivalent lifecycle approach replaces it.
- Related Changes: Phase 1D blocking crash fix (uncommitted workspace)
- Review Date: N/A

## DECISION-009
- Date: 2026-05-23
- Status: Accepted
- Owner: NCD / M
- Area: Branding Scope Control
- Decision: Stop further Phase 1D icon iteration, keep current transparent approved-design icon for MVP, and defer taskbar readability redesign to a future icon standard phase.
- Alternatives Considered:
- Continue icon iteration within Phase 1D until taskbar readability is perfect.
- Revert to an opaque or Flutter default icon.
- Rationale: Current transparency/packaging is technically acceptable for MVP; additional redesign effort is out of scope for Phase 1D and needs a separate approved icon standard.
- Impact: Runtime icon remains `app/assets/branding/icon_v1_5.png` + `app/windows/runner/resources/app_icon.ico`; redesign backlog tracked as `TODO-014`.
- Rollback or Reversal: Reopen icon redesign effort only under a future approved phase.
- Related Changes: Phase 1D closeout commit preparation (uncommitted workspace)
- Review Date: N/A

## DECISION-010
- Date: 2026-05-25
- Status: Accepted
- Owner: NCD / M
- Area: Integration Architecture
- Decision: Implement Control Center integration as a launch-context adapter contract in Photo Markup, with no direct Control Center code dependency and no autosave/auto-export behavior.
- Alternatives Considered:
- Directly coupling to Control Center internals.
- Writing straight into project folders during launch.
- Rationale: Keeps Photo Markup standalone and testable while enabling future context-driven launch.
- Impact: Added isolated launch context model/service, optional startup context display, optional source image open path, and safe fallback behavior when context is absent/invalid.
- Rollback or Reversal: Remove adapter files and startup wiring; keep standalone startup path only.
- Related Changes: Phase 1P Control Center Integration Adapter / Launch Contract (uncommitted workspace)
- Review Date: N/A

## DECISION-011
- Date: 2026-05-25
- Status: Accepted
- Owner: NCD / M
- Area: Export Workflow Safety
- Decision: Use source/launch-context aware default PNG save path + duplicate-safe filename incrementing, and require unsaved-change guard choices (`Export`, `Discard`, `Cancel`) before replacing context/image or closing route.
- Alternatives Considered:
- Keep generic save dialog defaults with no source-folder targeting.
- Allow silent overwrite of existing ` - Markup` outputs.
- Warn only on close and not on image replacement.
- Rationale: Aligns with field workflow while protecting source image and in-session markup work.
- Impact: Export defaults now prefer launch `suggestedExportFolder`, then source image folder; default name is `OriginalName - Markup.png`; duplicate names auto-increment; unsaved guard paths are centralized in shell flow.
- Rollback or Reversal: Remove path helper/guard logic and restore raw save-dialog-only flow.
- Related Changes: Phase 1Q Save-Back Export Defaults + Unsaved Change Guard (uncommitted workspace)
- Review Date: N/A

## DECISION-012
- Date: 2026-05-27
- Status: Accepted
- Owner: NCD / M
- Area: Editable Markup Persistence
- Decision: Use a standalone JSON sidecar format (`.ncdmarkup.json`) with centralized schema versioning and duplicate-safe naming, triggered by explicit user `Save Markup`/`Open Markup` actions only.
- Alternatives Considered:
- Persist editable state only in memory and require redraw after reopen.
- Auto-save sidecar on every export or launch-context event.
- Rationale: Delivers editable reopen capability without coupling to Control Center or introducing autosave risk to project/source folders.
- Impact: Added document model/service, toolbar save/open actions, source-image locate fallback for missing paths, and unsaved-state integration on successful save/reopen.
- Rollback or Reversal: Remove sidecar model/service and toolbar actions; keep PNG export-only workflow.
- Related Changes: Phase 1R Editable Markup Save / Reopen MVP (uncommitted workspace)
- Review Date: N/A

## DECISION-013
- Date: 2026-05-28
- Status: Accepted
- Owner: NCD / M
- Area: Native Window Close Guard
- Decision: Intercept native app close requests using Flutter `WidgetsBindingObserver.didRequestAppExit` and route them through the existing unsaved-change dialog flow (`Export`, `Discard`, `Cancel`).
- Alternatives Considered:
- Keep `PopScope` only and accept platform close edge cases.
- Add third-party window-management dependency for close interception.
- Modify Windows runner C++ close path.
- Rationale: `didRequestAppExit` is built-in, minimal-risk, avoids dependency/native code expansion, and keeps one shared guard path.
- Impact: Native Windows title-bar `X` close requests now call the same unsaved guard logic used by route pop/open-photo replacement.
- Rollback or Reversal: Remove observer + `didRequestAppExit` override and restore route-pop-only guard.
- Related Changes: Phase 1S-A Native Windows Close Guard Hardening (uncommitted workspace)
- Review Date: N/A

## DECISION-014
- Date: 2026-05-28
- Status: Accepted
- Owner: NCD / M
- Area: Import Performance / Memory
- Decision: For HEIC/HEIF display working copies, use file-based conversion with capped preview dimensions (`2560`) and keep output as PNG, while adding temp artifact cleanup and best-effort image-cache eviction on image replacement.
- Alternatives Considered:
- Keep full-resolution HEIC fallback output for display working copy.
- Change converted display output to JPEG in this phase.
- Add a new dependency for background conversion.
- Rationale: Provides measurable load-time and temp-size reduction with low risk and no export/schema behavior changes.
- Impact: HEIC import conversion on current sample reduced from ~5.3s to ~3.4s with smaller temp output (~9.1MB to ~5.35MB); original source files remain unchanged.
- Rollback or Reversal: Remove preview resize cap and revert to prior conversion flow in `ImageImportService` and related constants.
- Related Changes: Phase 1T-A Image Import Performance + Memory Cleanup (uncommitted workspace)
- Review Date: N/A

## DECISION-015
- Date: 2026-05-28
- Status: Accepted
- Owner: NCD / M
- Area: Import Performance / HEIC Reopen Latency
- Decision: Add deterministic HEIC preview cache reuse and switch temporary HEIC display output to preview JPEG (`quality=85`) under a dedicated temp cache folder, while keeping package-first then fallback conversion policy for now.
- Alternatives Considered:
- Keep timestamped one-off temp conversion files and reconvert every open.
- Keep PNG preview output for temporary HEIC working copies.
- Switch to fallback-first immediately without broader sample reliability checks.
- Rationale: Measurably improves first-open conversion time and drastically improves repeated-open latency with lower temp output size, without changing export format, source-image safety, or sidecar schema behavior.
- Impact: Reopen of the same HEIC now reuses cached converted preview when source path/size/mtime/settings match; stale cache cleanup remains bounded by age/count limits.
- Rollback or Reversal: Revert cache-key path logic and output extension/quality constants; restore non-reused timestamped conversion flow.
- Related Changes: Phase 1T-A2 deeper HEIC optimization pass (uncommitted workspace)
- Review Date: N/A

## DECISION-016
- Date: 2026-05-29
- Status: Accepted
- Owner: NCD / M
- Area: Field Toolbar Usability
- Decision: Replace the crowded bottom horizontal toolbar with a compact always-visible left navigation rail plus expandable overlay drawer-style sidebar (icon rail at rest, labeled list rows when expanded), while retaining all existing actions and behavior.
- Alternatives Considered:
- Keep one long flat horizontal button row.
- Move less-used actions into overflow menu.
- Rationale: Improves tablet field scanning speed and modern app-like usability without horizontal toolbar scrolling, oversized controls, or hidden critical actions.
- Impact: File actions, markup tools, and edit actions are visually separated in a compact rail/drawer; active tool remains clear; style preset remains directly visible; icon colors follow neutral + NCD blue hierarchy with restrained destructive accenting; drawer attachment is flush to rail with no gutter seam.
- Rollback or Reversal: Restore prior flat toolbar action list rendering path.
- Related Changes: Phase 1U Field Polish / Toolbar Organization (uncommitted workspace)
- Review Date: N/A

## DECISION-017
- Date: 2026-05-29
- Status: Accepted
- Owner: NCD / M
- Area: Sidebar Icon Rendering Reliability
- Decision: Use Flutter built-in Material `IconData` mappings only for sidebar rail/drawer actions and toggles, with conservative icon variants to avoid platform glyph fallback boxes.
- Alternatives Considered:
- Keep current icon variants that intermittently render as square placeholders.
- Add third-party icon dependency/package.
- Use unicode/emoji/text glyph symbols in place of icons.
- Rationale: Fixes runtime icon rendering reliability without adding dependencies, internet assets, or behavior changes.
- Impact: Sidebar icon mapping remains centralized in constants; toggle icons now use `Icons.menu`; no external icon packages added.
- Rollback or Reversal: Revert sidebar icon constants/toggle icon selections to prior mappings.
- Related Changes: Phase 1U Sidebar Icon Rendering / Modern App Polish Fix (uncommitted workspace)
- Review Date: N/A

## DECISION-018
- Date: 2026-05-29
- Status: Accepted
- Owner: NCD / M
- Area: Canvas View Transform
- Decision: Apply view transforms to the display layer (`InteractiveViewer` with `TransformationController`) so the photo and markup overlay transform together, while keeping export crop logic anchored to the existing untransformed displayed-image rect computation.
- Alternatives Considered:
- Transform markup independently from image.
- Recompute and persist markup coordinates in zoomed viewport space.
- Rationale: Preserves normalized markup geometry and avoids export/sidecar schema breakage while adding zoom/pan usability.
- Impact: Zoom/pan/fit controls were added without changing normalized markup storage, export crop math, HEIC workflow, or sidecar schema.
- Rollback or Reversal: Remove view controls and transform controller wiring; restore static contain-fit canvas rendering.
- Related Changes: Phase 1V Canvas View Controls / Zoom + Pan MVP (uncommitted workspace)
- Review Date: N/A

## DECISION-019
- Date: 2026-05-30
- Status: Accepted
- Owner: NCD / M
- Area: Sidebar Icon Strategy Evaluation
- Decision: Add a temporary dual-pack sidebar icon abstraction supporting `lucide` and `ncdCustom` with a runtime visual toggle (`Ctrl+Shift+I`) and expanded-sidebar status label for side-by-side field QA before locking the production default.
- Alternatives Considered:
- Keep one fixed icon source and defer all visual/icon QA until a future redesign.
- Replace Material mapping directly without keeping a governed comparison harness.
- Rationale: Enables owner visual validation against real workflows without introducing additional behavior risk, and keeps icon-source selection centralized and reversible.
- Impact: Sidebar action rendering now accepts either `IconData` or asset-backed icons via a single descriptor model; Lucide dependency and custom asset registrations are documented and test-covered.
- Rollback or Reversal: Remove dual-pack registry + hotkey and keep only the owner-approved pack mapping.
- Related Changes: Phase 1U-B Sidebar Icon Testing: Lucide vs NCD Custom Pack (uncommitted workspace)
- Review Date: N/A

## DECISION-020
- Date: 2026-05-31
- Status: Accepted
- Owner: NCD / M
- Area: Sidebar Icon Production Standard
- Decision: Select NCD custom sidebar icon assets as the production/default icon system and remove comparison-only runtime behavior (`Ctrl+Shift+I` pack toggle, sidebar icon-pack status label, and Lucide runtime dependency).
- Alternatives Considered:
- Keep dual-pack comparison mode in production.
- Retain Lucide as a runtime fallback.
- Rationale: Owner visual validation selected NCD custom assets as winner and requested production cleanup without comparison-mode UI.
- Impact: Sidebar now renders from governed local NCD asset mappings only; no runtime icon-pack switching remains.
- Rollback or Reversal: Re-introduce a documented dev-only comparison harness in a separate approved follow-up.
- Related Changes: Phase 1U-B final production cleanup (uncommitted workspace)
- Review Date: N/A

## DECISION-021
- Date: 2026-06-17
- Status: Accepted
- Owner: NCD / M
- Area: DWG Import Safety
- Decision: Open DWG files by extracting an embedded raster preview (`PNG` preferred, `BMP` fallback) into an internal cache only when that embedded preview passes governed usability checks, and otherwise show the approved offline-converter fallback message.
- Alternatives Considered:
- Depend on a governed external converter before shipping any DWG support.
- Pretend `magick` supports DWG and ship unverified conversion logic.
- Add a cloud/online DWG conversion dependency.
- Rationale: Real local DWG samples on this machine already contain embedded raster preview bytes that can be extracted safely without mutating the DWG, without cloud upload, and without introducing a new converter dependency. However, the owner sample proved some embedded previews are only tiny/partial dark thumbnails, so extraction alone is not an acceptable success criterion. Local Office/Visio preview-host attempts were not reliable enough for production capture, and ImageMagick still does not advertise `DWG`/`DXF` decoding support.
- Impact: `.dwg` is now accepted by picker/launch validation and export/sidecar naming helpers, many DWGs can open immediately through cached embedded preview extraction, and obviously unusable embedded thumbnails are rejected honestly instead of being shown as if full DWG rendering succeeded.
- Rollback or Reversal: Remove `dwg` from supported extensions and delete the dedicated DWG preview service if owner later prefers to hide DWG until real conversion is approved.
- Related Changes: Phase 1W DWG Preview Import MVP (uncommitted workspace)
- Review Date: N/A

## DECISION-022
- Date: 2026-06-18
- Status: Accepted
- Owner: NCD / M
- Area: Measurement Label Editing / Text Typography
- Decision: Keep selection/edit/move behavior in Select mode (`MarkupTool.none`) and make drawing tools creation-first, while persisting dimension-label offsets and shared governed typography settings per markup item.
- Alternatives Considered:
- Keep generic tap-hit selection active even while draw tools are armed.
- Add a second standalone label-drag subsystem outside the existing handle-drag flow.
- Store screen-space label offsets or runtime-only font settings.
- Rationale: Prevents nearby dimensions from stealing new-draw intent, keeps label drag priority predictable, and preserves save/reopen/export alignment by storing normalized label offsets and per-item font settings.
- Impact: Users can tap an active tool again to return to Select mode, edit/move dimension labels safely, and persist label/text-note font family and size through `.ncdmarkup.json` without breaking older files.
- Rollback or Reversal: Restore always-on tap hit-testing for draw tools, remove typography/label-offset fields from sidecar handling, and return label rendering to fixed midpoint placement.
- Related Changes: Phase 1X Measurement Label Usability + Text Typography (uncommitted workspace)
- Review Date: N/A

## DECISION-023
- Date: 2026-06-18
- Status: Accepted
- Owner: NCD / M
- Area: Select-Mode Pointer Interaction
- Decision: In Select mode, pointer-down on an unselected existing markup may immediately promote that markup to selected state and then retry handle-drag or whole-markup move logic within the same gesture, while drawing tools remain creation-first and do not re-enable generic tap selection.
- Alternatives Considered:
- Require a first tap only for selection and a second gesture for every move/handle edit.
- Re-enable generic hit-test selection while draw tools are armed.
- Rationale: Restores reliable move/edit behavior for existing dimensions and other markups without bringing back accidental selection stealing when users are trying to draw nearby new dimensions.
- Impact: Select mode now supports same-gesture promotion into move/handle workflows for existing markups, and dedicated regression tests cover the restored dimension/arrow interactions without hanging on dialog-producing tap paths.
- Rollback or Reversal: Remove the pointer-down selection promotion helper and return to select-then-second-gesture editing behavior.
- Related Changes: Phase 1X Select/Edit/Move restoration on top of measurement-label usability work (uncommitted workspace)
- Review Date: N/A

## DECISION-024
- Date: 2026-06-18
- Status: Accepted
- Owner: NCD / M
- Area: DWG Offline Converter Contract
- Decision: Add a governed offline DWG preview-converter command contract driven by environment/config values, run it with a bounded timeout before embedded-preview fallback, and apply the same governed preview quality gate to converter output and embedded output.
- Alternatives Considered:
- Hardcode a guessed ODA/LibreCAD/Autodesk command-line path.
- Auto-detect and launch arbitrary machine-specific converter installs by default.
- Pretend ImageMagick currently provides DWG decoding on this workstation.
- Rationale: Local audit on this workstation found no approved offline DWG converter installed, and vendor/version/license-specific CLI contracts are not safe to guess. A governed command contract keeps Photo Markup honest, allows approved local converter pipelines later without repo binaries or cloud upload, and preserves current embedded-preview fallback only when that fallback is actually usable.
- Impact: `DwgPreviewConversionService` now supports `NCD_PM_DWG_CONVERTER_COMMAND` plus related governed strategy/output/timeout env values, caches converter-rendered previews separately from embedded-preview cache entries, rejects timed-out/missing/bad converter output safely, and keeps the existing friendly converter-required message when neither path yields a usable preview.
- Rollback or Reversal: Remove the converter-command contract constants and service path, then return to embedded-preview-only DWG handling from Phase 1W.
- Related Changes: Phase 1Y TODO-040 Offline DWG Converter Support (uncommitted workspace)
- Review Date: N/A

## DECISION-025
- Date: 2026-06-19
- Status: Accepted
- Owner: NCD / M
- Area: DWG Renderer Research Outcome
- Decision: Keep TODO-040 open and stop pursuing the currently tested free/offline DWG preview candidates for production use on the real Polito drawings until a governed approved renderer decision is made.
- Alternatives Considered:
- Keep iterating on `cad2x`, `ACadSharp + ACadSharp.Pdf`, `LibreDWG`, or `cad-viewer` as if one were already close enough for governed production rollout.
- Add online/cloud DWG conversion to bridge the gap.
- Rationale: Real-workstation probes against the governing Polito DWGs showed that the currently tested free/offline paths do not provide a dependable usable preview here: `cad2x` could not handle the owner DWGs reliably, `ACadSharp + ACadSharp.Pdf` produced unimplemented/blank output paths, `LibreDWG` only got as far as technically valid DXF conversion without a usable rendered preview, and `cad-viewer` is not practical on this workstation and still depends on LibreDWG behavior. The app should remain honest rather than pretending DWG rendering is solved.
- Impact: Photo Markup keeps the governed converter-command hook plus embedded-preview quality gate from Phase 1Y, TODO-040 stays open, no free/offline renderer is promoted to production, and practical feature work can move back to field-value measurement tooling while future DWG production support waits for an approved renderer choice.
- Rollback or Reversal: Reopen renderer evaluation only after a specific governed tool is approved for workstation deployment and real Polito DWG validation is scheduled.
- Related Changes: Phase 1Y-D DWG GitHub/tool research note; TODO-040 follow-up remains active.
- Review Date: N/A

## DECISION-026
- Date: 2026-06-19
- Status: Accepted
- Owner: NCD / M
- Area: Measurement Tool Coordinate Model
- Decision: Keep new measurement tools image-relative and calibration-driven: store scale calibration, multi-segment paths, and area polygons in normalized image coordinates; derive displayed measurement values from scale calibration plus source image pixel size; and transform image + overlay together through the existing canvas view layer without rewriting stored geometry.
- Alternatives Considered:
- Store measurements in viewport/screen coordinates after zoom/pan.
- Embed calculated measurement text as fixed saved strings rather than recomputing from calibration + image size.
- Introduce a separate export-only geometry model for measurement tools.
- Rationale: Preserves compatibility with the current export crop, save/reopen behavior, and transform-layer architecture from Phase 1V while allowing future measurement values to stay consistent across fit/zoom/pan and window-size changes.
- Impact: Phase 1Z measurement tools can share the same normalized-geometry persistence model as existing markups, and future manual validation can focus on tool behavior instead of schema migration risk.
- Rollback or Reversal: Remove the Phase 1Z measurement models/helpers and return to dimension/text-only measurement behavior.
- Related Changes: Phase 1Z New Measurement Tools MVP (working tree)
- Review Date: N/A

## DECISION-027
- Date: 2026-08-19
- Status: Accepted
- Owner: NCD / M
- Area: Markup Tools
- Decision: Give Scale Calibration its own on-canvas identity, and let Dimension pre-fill its label from the calibration.
- Alternatives Considered:
- Leave both looking the same and explain the difference in documentation only.
- Merge the two tools into one.
- Rationale: Scale Calibration was drawn through the same DimensionLine renderer as a Dimension, so the two were indistinguishable on the photo and read as duplicates. They are not duplicates: a Dimension is an annotation you type, and the calibration is the single reference that gives Multi-Segment and Area / Perimeter their real numbers. Making the reference look like a reference removes the confusion, and pre-filling the dimension label makes the calibration pay off for the dimension tool too instead of leaving the user to measure twice.
- Impact: Calibration draws dashed in its own colour with a SCALE prefix on the label. A new dimension on a calibrated photo opens with the measured value already filled in and is still fully editable. A measured value kept as-is bypasses the imperial shorthand formatter, which would otherwise convert whole feet to inches and corrupt metric units.
- Rollback or Reversal: Revert the calibration paints in dimension_lines_overlay.dart and the pre-fill block in _promptForDimensionLabelById.
- Related Changes: Phase 1Z measurement tools MVP
- Review Date: After owner validation on real site photos

## DECISION-028
- Date: 2026-08-19
- Status: Accepted
- Owner: NCD / M
- Area: Versioning and Change Control
- Decision: Every change bumps the version, is committed, and is pushed. A version is never withheld pending owner validation.
- Alternatives Considered:
- Keep withholding the bump until the owner validates the change.
- Bump only for changes that touch app code.
- Rationale: Owner directive. Withholding the number left several commits sharing one version, so the version stopped identifying what was actually running. Validation is a separate judgement about whether a version is good; it is not a gate on issuing the number. Leaving main ahead of origin also meant work existed only on one machine.
- Impact: `Governance/VERSIONING_AND_CHANGE_CONTROL.md` and the root `README.md` version rules now state the bump-and-push rule. The previous instruction not to bump before owner validation is removed. Unvalidated versions are recorded as unvalidated in the changelog and still get a number. The existing pre-push hook already enforced the bump half of this.
- Rollback or Reversal: Restore the previous Quick Rules and README version rules, and reinstate the do-not-bump-before-validation line.
- Related Changes: v0.34
- Review Date: N/A

## DECISION-029
- Date: 2026-08-20 (revised 2026-08-20, superseding the whole-inch rule shipped in v0.35)
- Status: Accepted, CONFIRMED BY OWNER
- Owner: NCD / M
- Area: Measurement Display
- Decision: Measured lengths are reformatted for display into units a person reads on site. Imperial rounds to the nearest sixteenth of an inch at every magnitude, because that is what a tape is marked in and a tape does not change its markings when the number gets big. The fraction is reduced, so eight sixteenths reads `1/2`, four reads `1/4`, two reads `1/8` and twelve reads `3/4`. Zero sixteenths shows no fraction at all, so `5 in` and never `5 0/16 in`. Sixteen sixteenths promotes to the next whole inch and twelve inches promotes to the next foot, so nothing ever reads `16/16` or `12 in`. Under a foot is inches alone; a foot and over is feet then inches, with inches dropped when they are zero. A real, positive length below a sixteenth displays `< 1/16 in`, never `0 in`. Metric is unchanged: at or above one metre shows metres to two decimals, below one metre shows centimetres, below one centimetre shows millimetres. Invalid, infinite or negative input is passed through rather than guessed at.
- Alternatives Considered:
- Round to whole inches, which is what v0.35 shipped. Superseded: it displayed anything under half an inch as `0 in`, which reads as "nothing here" rather than "smaller than I can show".
- Sixteenths only under some threshold, whole inches above it. Rejected by the owner: the tape rule applies at every size, and a rule with a threshold in it is a rule people have to remember.
- Show a decimal inch instead of a fraction. Rejected: nobody on a site reads `5.06 in` off a tape.
- Rationale: Owner ruling on 2026-08-20. `0.42 ft` is a spreadsheet number; `5 1/16 in` is a tape reading. The whole-inch version of this rule was assumed during an unattended run and was wrong in the one place it mattered most, at the small end, where it printed `0 in` for a real measurement. The rounding rule lives behind one named function, `MeasurementDisplayFormatter.format`, plus one constants block, `MeasurementDisplayConstants`, where `fractionDenominator` is the single number that controls the resolution.
- Impact: Display only. Stored geometry is untouched, which keeps the measured-value-stored-verbatim invariant intact. Typed labels are unaffected and still run through `DimensionLabelFormatter`. Applied to the dimension prefill, the multi-segment running length, and the area tool's perimeter line. Area itself is left alone because it is in squared units and the feet-and-inches rule does not apply to it. Known and accepted consequence: a scale calibrated by dragging across a photo is not accurate to a sixteenth of an inch, so the display now claims more precision than the underlying measurement has. The owner chose this knowingly, on the grounds that a reader who wants a sixteenth can see one and a reader who does not can ignore it, whereas a rounded number hides the fact that a measurement was ever taken.
- Rollback or Reversal: Revert the three call sites in `measurement_value_utils.dart` back to `_formatValue`, and delete `measurement_display_formatter.dart`. To go back to whole inches without losing the rest, set `MeasurementDisplayConstants.fractionDenominator` to 1, which also removes the `< 1/16 in` case.
- Related Changes: v0.35, revised in v0.40
- Review Date: N/A, confirmed by the owner

## DECISION-030
- Date: 2026-08-20
- Status: Accepted
- Owner: NCD / M
- Area: Markup Interaction
- Decision: On a photo with a scale calibration, a newly drawn dimension takes its measured value directly and no confirmation dialog opens. With no scale set the dialog opens with an empty box, unchanged. Editing an existing dimension always opens the dialog regardless of scale.
- Alternatives Considered:
- Keep pre-filling the dialog and make the user press Save, as shipped in v0.34.
- Auto-label and show a dismissable confirmation toast instead.
- Auto-label only above a minimum line length.
- Rationale: The measurement is the answer. Pre-filling a dialog and then asking a man on a ladder to confirm a number the app just computed is a tap that earns nothing. The dialog still exists for the two cases where there is a real question: no scale set, so there is nothing to place, and editing an existing label, where silently overwriting would destroy what someone typed.
- Impact: Removes one tap per dimension on any calibrated photo. Auto-labelling does not make a dimension read-only; tapping a placed dimension still opens the dialog with the current label, and a typed override still runs through `DimensionLabelFormatter`. The measured value is stored verbatim and never routed through that formatter, which would convert whole feet to inches and corrupt a metric unit. Creation is the only path that auto-labels; the two edit call sites are untouched.
- Rollback or Reversal: Point the creation call site in `_onDimensionEnd` back at `_promptForDimensionLabelById` and delete `_labelNewDimension`.
- Related Changes: v0.36
- Review Date: N/A

