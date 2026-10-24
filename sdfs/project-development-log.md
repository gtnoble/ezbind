# ezbind Project Development Log

**Project:** EZBIND
**Component:** Project / EZBIND-CLI
**Status:** Active
**Date opened:** 2026-09-21

## Purpose

Record development rationale, constraints, decisions, exploratory results, internal tests, status, and process observations for the project and its initial software component.

## Entry 001 — workspace initialization

- **Date:** 2026-09-21
- **Activity:** Project startup and environment reconnaissance.
- **Result:** Empty repository confirmed; Git initialized; disciplined directories established.
- **Available environment:** Alire 2.1.0, host GCC/G++ 13.3.0, Alire-selected GNAT native 15.2.1/GPRbuild 25.0.1, Git, and local PDF inspection/rendering utilities.
- **Constraints/open decisions:** The user accepted the proposed physical-layout and operational resolutions on 2026-09-21. PDF backend selection and detailed architecture remain open design decisions.
- **Decision:** Use an evolutionary multi-build plan. The B0 plan/open-decisions gate is closed; proceed through requirements review before design or implementation.
- **Verification:** Repository inspection and independent review completed; plan self-evaluation recorded in `plan/project-plan.md`.

## Entry 002 — B0 gate closure and requirements start

- **Date:** 2026-09-21
- **Activity:** Client plan review and resolution acceptance.
- **Result:** User accepted the Project Plan and all proposed resolutions for the open decision groups.
- **Configuration effect:** Project Plan advanced to client-controlled Revision 1.0.
- **Next activity:** Requirements analysis using the accepted operational baseline; no source implementation authorized yet.
- **Verification:** Operational Concept, Requirements Specification, and requirements-linked Test Plan drafted and self-evaluated.

## Status

Requirements and operational-concept products are in draft review. No implementation or unit-test results exist. Detailed design and implementation remain gated on requirements acknowledgement.

## Entry 003 — documentation and usage requirements

- **Date:** 2026-09-21
- **Activity:** Requirements change requested by the user.
- **Result:** Added the initial `ezbind(1)` man-page requirement and explicit canonical usage behavior for `--help`, `-h`, and invalid flags.
- **Decision:** Help writes the canonical usage statement and help text to standard output with exit status 0; command-line usage errors write a diagnostic and the same usage statement to standard error with exit status 2 and no output replacement.
- **Verification planned:** `TEST-CLI` and `TEST-DOC` cover the behavior and documentation.

## Entry 004 — requirements acceptance and design start

- **Date:** 2026-09-21
- **Activity:** Requirements review and baseline acceptance.
- **Result:** User accepted EZBIND-SRS-001 Revision 1.1, including man-page and canonical usage requirements.
- **Configuration effect:** Requirements Specification advanced to client-controlled status.
- **Design activity:** Independent backend review recommends qpdf native page/Form-XObject APIs behind a project-owned C-compatible C++ bridge; Ada remains responsible for application behavior and layout.
- **Next gate:** Design review before implementation.

## Entry 005 — design acceptance and B1 implementation start

- **Date:** 2026-09-21
- **Activity:** Design review and implementation authorization.
- **Result:** User accepted EZBIND-SDD-001 Revision 1.0, including the qpdf native backend and C-compatible C++ bridge.
- **Configuration effect:** Design Description advanced to client-controlled status; source implementation entered author control for B1.
- **Environment verification:** qpdf 11.9.0 headers, libraries, C++17 compiler support, and Alire-selected GNAT native 15.2.1 are available; a temporary native placement probe generated a valid PDF.
- **Next activity:** Implement B1 physical-unit, geometry, imposition, guide, CLI, and qpdf bridge units; execute the POC and unit tests.

## Entry 006 — B1 build and qpdf proof-of-concept

- **Date:** 2026-09-21
- **Activity:** B1 implementation, clean Alire builds, and POC-001 execution.
- **Result:** Root and nested test crates build through Alire. Pure-Ada tests pass. qpdf bridge imports a text-bearing PDF page, places it on a Letter page, appends vector content, writes valid output, and preserves selectable text.
- **Defect/resolution:** Initial POC crashed because native pointer handles were truncated to 32-bit Ada integers. Handles now use address-sized private types; destination pages are indirect qpdf objects. Sequential builds avoid a shared-object-directory race.
- **Independent checks:** `qpdf --check`, `pdfinfo`, and `pdftotext` passed on the generated output.
- **Status:** B1 proof-of-concept exit criteria for the implemented slice are met. Full CLI layout orchestration, complete guide rendering, and broader PDF feature tests remain for subsequent implementation work.

## Entry 007 — canonical Alire project structure

- **Date:** 2026-09-21
- **Activity:** Build-system correction and configuration control.
- **Result:** Replaced provisional build metadata with canonical Alire executable-crate structure, generated configuration files, and `[build-switches]` metadata. The root and nested test crates build with `alr build --development`.
- **Implementation mapping:** The executable main remains `procedure Ezbind`; Ada implementation packages use flattened `Ezbind_*` names to avoid a parent-package collision.
- **Verification:** Clean sequential root/test builds pass; generated artifacts remain ignored and are not committed.

## Entry 008 — B1 documentation update

- **Date:** 2026-09-21
- **Activity:** Documentation synchronization after B1 implementation.
- **Result:** README, Project Plan, Design Description, Test Plan, B1 Test Description, and `ezbind(1)` now distinguish implemented B1 behavior from planned B2 capabilities.
- **Documentation boundary:** The B1 executable supports help and usage errors; complete PDF transformation options remain planned and are explicitly marked unavailable.
- **Verification:** Rendered man page reviewed; stale B0/requirements-phase claims removed; Alire build commands and native dependency versions documented.

## Entry 009 — B2 implementation slice

- **Date:** 2026-09-21
- **Activity:** Implemented the first B2 orchestration slice and executed integration checks.
- **Result:** The CLI now parses one input/output pair, Letter/A4 selection, optional grid, and explicit overwrite. The qpdf bridge now creates destination pages independently from placement, allowing two physical sides per folded sheet. Imposition emits front `[4, 1]` and back `[2, 3]`, with blank padding to a multiple of four.
- **Output policy:** Generated PDFs use a sibling temporary path and commit only after successful generation; force replacement is explicit.
- **Verification:** Help and usage-error paths pass; malformed input returns status 3 without output; one-page Letter output has two pages and passes `qpdf --check`; five-page A4/grid output has four pages and passes `qpdf --check`; forced replacement passes; sequential root/test builds and the bridge smoke test pass.
- **Known limits:** Custom margins/units, covers, guides, marks, creep, safe-area controls, capability reporting, and broad PDF feature preservation remain staged.
- **Process note:** B2 execution is self-evaluated by the developer; independent user review remains required before physical use.

## Entry 010 — B2 documentation synchronization

- **Date:** 2026-09-21
- **Activity:** Audited project documentation against the implemented B2 slice.
- **Result:** Updated Project Plan gates and activity status, Design Description implementation notes, Test Plan status/schedule, test-crate metadata, and controlled status/change records. Historical B1 execution records remain unchanged.
- **Verification:** Documentation search found no remaining current-gate claims that full CLI orchestration is future work; README, `ezbind(1)`, B2 Test Description, and controlled project records now agree on the implemented slice and deferred scope.


## Entry 011 — B2 physical margin increment

- **Date:** 2026-09-21
- **Activity:** Added independent CLI margins and configurable grid spacing with explicit physical-unit parsing.
- **Result:** `--margin-top`, `--margin-bottom`, `--margin-fore-edge`, and `--margin-spine` accept non-negative `mm`, `in`, or `pt` values; `--grid-spacing` accepts positive values in the same units. Defaults remain 36/36/36/48 pt and 5 mm.
- **Validation:** Invalid, negative, unitless, and zero-spacing values return status 2 before output creation. Root and nested Alire builds, expanded Ada core tests, custom-margin/grid output, `qpdf --check`, selectable-text preservation, temporary-file cleanup, and rendered man-page checks pass.
- **Known limits:** Cover pages, guides, marks, creep, safe-area configuration, capability reporting, and broader PDF-feature preservation remain staged.
- **Process note:** This increment is self-evaluated by the developer; independent user review remains required before physical use.

## Entry 012 — librsvg/Cairo SVG cover-card increment

- **Date:** 2026-09-22
- **Activity:** Implemented separate cover-card PDF generation from front/back SVG artwork using a native librsvg/Cairo bridge.
- **Implementation:** Added `Ezbind_SVG_Bridge` and `ez_svg_bridge`; added `--cover-front`, `--cover-back`, and `--cover-output`; rendered back-left/front-right onto one selected-size landscape sheet; preserved the existing qpdf folio path; added temporary-file cleanup and output-path collision validation.
- **Dependencies:** Root and nested GPR files now link qpdf plus librsvg 2.58.0/Cairo 1.18.0 and their platform dependencies. Inkscape is not required.
- **Verification:** Root and nested development builds pass with warnings enabled; direct bridge smoke test passes; Letter and A4 cover PDFs have correct one-page dimensions and pass `qpdf --check`; `pdftotext` recovers `BACK` and `FRONT`; rendered fixture verifies asymmetric left/right placement; incomplete options/path collision return status 2; missing SVG returns status 5 without output.
- **Known limits:** librsvg supports a static SVG subset; external resources and font availability can affect output. Scale-to-fit is proportional and does not implement deliberate bleed/cropping. Physical printer safe areas and acceptance printing remain user responsibilities.
- **Process note:** This increment is self-evaluated by the developer; independent user review of representative artwork and physical center-cut orientation remains required.

## Entry 013 — Cover-only generation

- **Date:** 2026-09-22
- **Activity:** Removed the requirement to process a text-block PDF when only a cover sheet is requested.
- **Interface:** A cover-only invocation is `ezbind --sheet letter|a4 --cover-back back.svg --cover-front front.svg --cover-output covers.pdf`; positional input and folio `--output` are omitted. Complete cover options remain required, and combined folio-plus-cover mode remains supported.
- **Implementation:** The application validates cover-only mode, checks the cover destination, renders directly through `Ezbind_SVG_Bridge`, commits the cover temporary output, and returns before `Ezbind_QPDF_Bridge.Open_Input`.
- **Verification:** Cover-only Letter output passes `pdfinfo`, `qpdf --check`, and text extraction; invalid mixed/incomplete invocations return status 2 without output; combined mode still produces valid folio and cover PDFs; no cover temporary file remains after success.
- **Process note:** This increment is self-evaluated by the developer; independent review of cover output remains required.

## Entry 014 — Explicit source cropping

- **Date:** 2026-09-23
- **Activity:** Implemented deterministic source-page cropping; automatic whitespace detection remains deferred.
- **Interface:** Added `--crop-top`, `--crop-bottom`, `--crop-left`, and `--crop-right`; values accept non-negative `mm`, `in`, or `pt` and default to zero.
- **Implementation:** Added qpdf page descriptors for transformed CropBox dimensions; validated every source page before output creation; converted visual retained rectangles to source coordinates; replaced fresh Form XObject BBoxes before copying; retained proportional placement and output-margin behavior.
- **Limitations:** Source page content is clipped during import. Annotation and form-field transformation remains subject to backend limitations. Auto-crop and raster/render dependencies were not added.
- **Verification:** Root and nested development builds pass. CLI, qpdf validity, crop behavior, and invalid-retained-rectangle checks are recorded in the B2 test description.
- **Process note:** This increment is self-evaluated by the developer; independent user review of cropped output remains required.

## Entry 015 — Cover-card center cut guide

- **Date:** 2026-09-24
- **Activity:** Added an explicit vector cut guide to generated cover-card sheets.
- **Design:** The shared SVG renderer draws a 0.5 pt dashed gray line at the sheet midpoint, inset 12 pt from the top and bottom, after both cover SVGs so the guide is visible over artwork. It is always enabled in cover output.
- **Verification:** Root and nested Alire development builds pass. The Ada/native bridge test passes; Letter and A4 cover-only output has the expected dimensions and passes `qpdf --check`; 72 dpi Letter and A4 rasters confirm the center dash pattern, gray color, and 12 pt end insets. Combined A4 folio-plus-cover output succeeds and both PDFs pass validation.
- **Process note:** This change is self-evaluated by the developer; independent review of the rendered cover and physical cutting workflow remains invited.

## Entry 016 — Approved breaking CLI and overwrite-policy change

- **Date:** 2026-10-24
- **Activity:** Documentation and requirements update under CHG-013.
- **Decision:** Folio usage is exactly `ezbind [OPTIONS] INPUT.pdf OUTPUT.pdf`. Remove `-o`/`--output` and `-f`/`--force`; after successful generation existing destinations are replaced without prompting. Cover-only mode has zero positional paths and the three named cover options; combined mode uses two positional paths and those cover options. The parser supports `--` and interspersed options; examples prefer options first. Reject source PDF/SVG destinations including normalized aliases, and require distinct outputs.
- **Implementation:** Parser accepts the two positional PDF paths and `--`, removes retired switches, and rejects normalized source/destination collisions. GNAT.OS_Lib supplies Unix replacement rename without deleting the previous destination first.
- **Documentation:** README, man page, OCD, SRS, and SDD updated; historical test results preserved with a supersession note and a new execution record.
- **Verification:** Root and nested development builds pass; 15 executable CLI tests and Ada core/qpdf/SVG bridge tests pass. Repeated Letter/A4 combined generation replaces both outputs, and all generated verification PDFs pass qpdf checks. Man-page rendering and diff whitespace checks pass.
- **Limitations:** Fixed-suffix temporary ownership and transactional combined-output commits remain separate hardening work. Path normalization resolves symbolic links but does not equate distinct hard links.
- **Configuration:** CHG-013 resolved. This implementation is self-evaluated; user review of the revised interface and representative physical output remains invited.


## Entry 017 — CLI documentation follow-up

- **Date:** 2026-10-24
- **Activity:** Documentation-only audit and corrections under CHG-014 after implementation commit `f9f88e8`.
- **Changes:** Added folio/combined/cover-only/dash-leading examples, migration notes, cover-only synopsis, parser limitations, overwrite caveats, and regression-suite instructions. Clarified reserved status 6, output streams, combined commit order, and rendering dependencies. Aligned SRS/SDD/TD headers with the configuration index and labeled superseded test cases before their historical table.
- **Verification:** All four README conversion examples ran in temporary directories with checked-in SVG fixtures, and all generated PDFs passed `qpdf --check`. Man-page rendering and whitespace checks pass. No source or runtime behavior changed.
- **Evaluation:** Current examples and statements were checked against implementation and independently audited for discrepancies. Historical execution results were not rewritten. This documentation is self-evaluated; independent user review remains invited.
