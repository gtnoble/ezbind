# ezbind B1 Test Description

**Project:** EZBIND  
**Document:** B1 Test Description  
**Identifier:** EZBIND-B1-TD-001  
**Status:** B1 execution record  
**Date:** 2026-09-21  
**Revision:** 1.1

## Scope

This description covers the B1 physical-unit, geometry, imposition, guide-generation, and qpdf bridge proof-of-concept tests. It does not constitute component acceptance testing.

## Environment

- Linux host.
- Alire-selected GNAT native 15.2.1 and GCC/G++ 13.3.0-compatible native bridge.
- qpdf 11.9.0 and `libqpdf-dev`.
- `qpdf --check`, `pdfinfo`, `pdftotext`, and `pdftoppm` for independent checks.
- Project build through `gprbuild` selected by Alire when available, or the documented fallback build command.

## TEST-GEO

- Convert `25.4mm`, `1in`, and `72pt`; expect equal canonical points.
- Reject zero, negative, malformed, and unsupported unit values.
- Validate Letter and A4 sheet dimensions.
- Validate content rectangles with default and custom margins.
- Reject margins and reserves that produce a nonpositive content rectangle.
- Verify 5 mm grid segments remain inside allowed margin regions and outside content/spine exclusions.

## TEST-IMP

- Input four logical pages; expect front `[4, 1]` and back `[2, 3]`.
- Input five logical pages; expect padding to eight and a blank logical page marker.
- Verify output side and slot identities are deterministic.
- Verify asymmetric placement data distinguishes left/right and front/back.

## POC-001 — qpdf page import and placement

### Preparation

Create or use a source PDF containing visible text and vector content. Confirm that `qpdf --check` accepts it and that `pdftotext` returns its labels.

### Procedure

1. Open the source through the qpdf bridge.
2. Read page count and page geometry.
3. Create a Letter-sized destination sheet.
4. Place the source page into a destination rectangle.
5. Append a vector guide line.
6. Write a temporary output.
7. Run `qpdf --check`, `pdfinfo`, and `pdftotext` on the output.

### Expected result

- Bridge returns success.
- Output is structurally valid.
- Output page dimensions match Letter.
- Source text remains extractable.
- The placement and vector line render correctly.
- No native exception crosses the C ABI.

## POC-002 — four-page imposition

Input: synthetic pages labelled 1 through 4.

Expected: two physical output pages, front left/right `[4, 1]`, back left/right `[2, 3]`, with the placement transformations recorded by the imposition unit.

## POC-003 — padding

Input: five pages. Expect eight logical positions, three inserted blanks, and four output sides. No partial output is accepted on failure.

## POC-004 — geometry and guides

Enable the default grid and spine guide. Verify vector content, clipping, and exclusion from source-content and reserved-spine rectangles.

## Execution results

**Date:** 2026-09-21  
**Environment:** Alire 2.1.0, GNAT native 15.2.1 selected by Alire, GCC/G++ 13.3.0-compatible native bridge, qpdf 11.9.0, Linux.

- Root crate built successfully with `alr -n build`.
- Nested test crate built successfully with `alr -n build`.
- Pure-Ada physical conversion, geometry, and imposition checks passed.
- qpdf bridge opened a text-bearing PDF, placed its page on a Letter destination, appended a vector line, and wrote a valid output.
- `qpdf --check` passed for source and output.
- `pdfinfo` reported one Letter output page (`612 x 792 pts`).
- `pdftotext` recovered `EZBIND-SOURCE-PAGE-1` from the imposed output.
- CLI `--help` returned status 0; invalid flags returned status 2 and printed the canonical usage line to standard error.

### Defect found and resolved during POC

The first native smoke execution aborted because the Ada opaque handle type was incorrectly represented as a 32-bit C integer while the bridge returned 64-bit pointers. The handle representation was changed to an address-sized private type, destination page objects were made indirect before insertion, and the test was repeated successfully. The concurrent root/test build race that produced stale C++ dependency files was also identified; builds are now executed sequentially because both projects share the root crate object directory.

## Exit criteria

B1 passes when unit tests for physical values, geometry, imposition, and guides pass; POC-001 produces a valid output; qpdf errors are mapped to controlled statuses; and the results are recorded in the project development log.
