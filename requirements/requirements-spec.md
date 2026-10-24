# ezbind Requirements Specification

**Project:** ezbind
**Document:** Software Requirements Specification (SRS)
**Identifier:** EZBIND-SRS-001
**Status:** Client-acknowledged baseline
**Date:** 2026-09-21
**Revision:** 1.1

## Contents

1. Scope
2. Referenced documents
3. Definitions and conventions
4. Requirements
5. Qualification provisions and traceability
6. Notes

## 1. Scope

### 1.1 Component

This specification covers the `EZBIND-CLI` software component: a local Ada command-line application that reads one ebook PDF and writes an imposed PDF for folded-folio home bookbinding.

### 1.2 Product boundary

The component performs PDF inspection, layout validation, page imposition, optional margin-grid/guide rendering, PDF output, and diagnostics. It does not control a printer, perform physical folding or binding, supply physical cover cards or fabric, or provide a graphical user interface.

### 1.3 Verification notation

Each requirement states one primary verification method:

- **Test:** automated or procedural execution with recorded expected results.
- **Demonstration:** user-visible operation in a representative environment.
- **Inspection:** review of source, output structure, or documentation.
- **Analysis:** calculation or independent examination of geometry/behavior.

## 2. Referenced documents

- `plan/project-plan.md`, EZBIND-SDP-001, Revision 1.1.
- `requirements/operational-concept.md`, EZBIND-OCD-001, Revision 1.0.
- `tests/test-plan.md`, EZBIND-STP-001, Revision 1.1 draft.
- User-approved B0 resolutions, 2026-09-21.

## 3. Definitions and conventions

- **Source page:** one page in the input PDF.
- **Finished page:** the physical page size of the bound book; by baseline assumption it is the source-page target size.
- **Sheet:** one physical sheet printed on both sides and folded once.
- **Folio:** one folded sheet in the text block.
- **Spine side:** the side of the finished page at the fold and glue line.
- **Fore-edge:** the edge opposite the fold.
- **Margin:** reserved distance from a finished-page edge; top, bottom, fore-edge, and spine are independently named.
- **Imposition:** assignment of logical pages to printed sheet sides, positions, and orientations.
- **Grid:** optional vector graph-paper-like lines rendered in margin areas.
- **Guide:** optional non-content line or shading marking a spine/fabric region.
- **Blank page:** an intentionally empty logical page used for padding or a requested physical insert.

All physical dimensions shall be represented internally with sufficient precision to avoid cumulative rounding that changes a printed dimension by more than 0.1 mm. User-facing physical values may be millimetres, inches, or PDF points.

## 4. Requirements

### 4.1 Capability requirements

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-CAP-001 | Folio mode shall accept exactly two positional paths: one input PDF followed by one folio output PDF. Cover-only mode shall accept zero positional paths and require all three named cover options; combined mode shall use the two folio paths plus those options. | Test | B2 |
| REQ-CAP-002 | The program shall inspect the input PDF before output generation and shall reject an unreadable, empty, malformed, or unsupported input with a diagnostic and nonzero exit status. | Test | B1/B2 |
| REQ-CAP-003 | The program shall support Letter, A4, and explicitly specified custom sheet dimensions. | Test | B1/B2 |
| REQ-CAP-004 | The program shall treat the configured finished-page dimensions as the target page size for each source page and shall validate that the source content can be placed without unintended cropping unless explicit source crop parameters request it. | Test/Analysis | B1 |
| REQ-CAP-005 | The program shall impose four logical page positions per folded sheet: two on the front side and two on the back side. | Test | B1 |
| REQ-CAP-006 | For a four-page folded unit, the nominal logical-page assignment shall be front-left 4, front-right 1, back-left 2, and back-right 3, with orientations that produce pages 1 through 4 in reading order after folding. | Test/Demonstration | B1 |
| REQ-CAP-007 | The program shall add blank logical pages as needed so the imposed logical-page count is a multiple of four, unless a future explicitly selected policy says otherwise. | Test | B1 |
| REQ-CAP-008 | The program shall preserve the visible appearance of each source page, including text, raster images, vector graphics, and page rotation, subject to declared backend limitations. | Test/Inspection | B1/B2 |
| REQ-CAP-009 | The program shall emit a valid PDF whose physical sheet dimensions match the selected sheet dimensions. | Test | B1/B2 |
| REQ-CAP-010 | The program shall provide a mode that excludes cover-card pages and shall make that mode the default. | Test | B2 |
| REQ-CAP-011 | The program shall provide an optional mode that adds one blank front cover-card page and one blank back cover-card page, each with the configured finished-page dimensions. | Test | B2 |
| REQ-CAP-012 | The program shall provide an optional spine/fabric guide and shall leave it disabled by default. | Test/Demonstration | B2 |
| REQ-CAP-013 | The program shall support independent top, bottom, fore-edge, and spine margins. | Test | B1/B2 |
| REQ-CAP-014 | The program shall interpret margins from the finished-page edges and shall reserve the spine margin from source content. | Test/Analysis | B1 |
| REQ-CAP-015 | The program shall accept physical dimensions in millimetres, inches, and PDF points, and shall reject invalid or negative dimensions. | Test | B1 |
| REQ-CAP-016 | The program shall provide blank margins by default. | Test | B1 |
| REQ-CAP-017 | The program shall provide an optional graph-paper-like grid confined to margin areas and excluded from the source-content rectangle and spine/fabric reserve. | Test/Demonstration | B1/B2 |
| REQ-CAP-018 | The default margin grid spacing shall be 5 mm when grid mode is selected; spacing shall be configurable to a positive physical value. | Test | B1/B2 |
| REQ-CAP-027 | The program shall support independent top, bottom, left, and right source crop distances in mm, in, or pt, measured from each page's effective CropBox with MediaBox fallback, interpreted as visual edges after rotation, and applied before uniform placement into output margins. | Test/Analysis | B2 |
| REQ-CAP-019 | Grid lines shall be vector lines with a default light-gray appearance and a default line width of 0.25 pt; color and line width may be configurable. | Test/Inspection | B2 |
| REQ-CAP-020 | The program shall provide optional crop marks, fold marks, and registration marks, all disabled by default. | Test/Demonstration | B2 |
| REQ-CAP-021 | The program shall provide creep compensation as an optional explicit value or supported mode, disabled by default, and shall not infer paper thickness without user input. | Test/Analysis | B3 |
| REQ-CAP-022 | The program shall provide an optional printer safe-area reserve and shall reject a layout when the requested content, margins, and reserves do not fit. | Test | B2 |
| REQ-CAP-023 | After successful generation, the program shall replace existing folio and/or cover destinations without prompting; it shall not replace destination files when generation fails. | Test | B2 |
| REQ-CAP-024 | The program shall report the selected non-default layout parameters sufficiently for a user to identify how the output was generated. | Test/Inspection | B2 |
| REQ-CAP-025 | The program shall provide an optional SVG cover-card mode that accepts separate front and back SVG artwork and emits one landscape cardstock sheet with back artwork on the left half and front artwork on the right half, so the center cut edges face the spine; the sheet shall mark the center cut boundary with a 0.5 pt dashed gray line inset 12 pt from the top and bottom edges. | Test/Demonstration | B2 |
| REQ-CAP-026 | The program shall allow SVG cover-card output without an input text-block PDF or folio output path when all three named cover options are supplied; cover-only mode shall use zero positional paths. | Test | B2 |

### 4.2 External interface requirements

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-CLI-001 | The CLI shall accept exactly INPUT.pdf OUTPUT.pdf positionally in folio mode, optionally with the three named cover options; cover-only mode shall accept those options and zero positional paths. The CLI shall also accept the sheet, page/geometry, source crop, margin, grid, guide, marks, creep, and safe-area options defined by the user manual. | Test/Demonstration | B2 |
| REQ-CLI-002 | The program shall provide a help operation that identifies usage, defaults, supported units, and error/exit behavior without requiring an input PDF. | Test | B2 |
| REQ-CLI-003 | Normal diagnostics shall be written to standard error and shall not include extracted document text, passwords, or complete PDF content. | Inspection/Test | B2 |
| REQ-CLI-004 | The program shall return exit status 0 on success, 2 for command-line usage errors, 3 for input-PDF errors, 4 for impossible layouts, 5 for output/filesystem errors, 6 for missing/unusable runtime dependencies, and 10 for unexpected internal errors. | Test | B2 |
| REQ-CLI-005 | The program shall operate on one input PDF per invocation; batch processing is not required for this baseline. | Inspection/Test | B2 |
| REQ-CLI-006 | The program shall recognize `--help` and `-h` without requiring an input PDF, print the canonical usage statement and help text to standard output, and return exit status 0. | Test | B2 |
| REQ-CLI-007 | When the invocation contains an unknown flag, malformed option, missing option value, or other command-line usage error, the program shall print a diagnostic followed by the canonical usage statement to standard error, shall not create or replace an output PDF, and shall return exit status 2. | Test | B2 |
| REQ-CLI-008 | The canonical usage statement shall be identical in help and invalid-invocation paths and exactly `Usage: ezbind [OPTIONS] INPUT.pdf OUTPUT.pdf` as its first line. | Test/Inspection | B2 |
| REQ-CLI-009 | Help output shall print the canonical usage line followed by a concise option summary and exit-status summary; invalid-invocation output shall print the command-line diagnostic followed by the same canonical usage line and shall not be required to print the full option summary. | Test | B2 |
| REQ-CLI-010 | For every supported long CLI option with a documented short alias, the program shall accept that alias with the same behavior. | Test | B2 |
| REQ-CLI-011 | The parser shall accept `--` to end option parsing and permit interspersed options; examples shall prefer options first. | Test | B2 |
| REQ-CLI-012 | The program shall reject source PDF/SVG destinations, including normalized path aliases, and identical folio/cover outputs; valid existing destinations shall be replaced without prompting only after successful generation. | Test | B2 |

### 4.3 Internal data requirements

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-DATA-001 | The layout model shall represent physical dimensions with explicit units and shall distinguish sheet dimensions, finished-page dimensions, source crop distances, margins, reserves, and grid spacing. | Inspection/Analysis | B1/B2 |
| REQ-DATA-002 | The imposition model shall represent each output placement with a source/logical page identity, sheet index, side, position, rotation, and placement rectangle. | Inspection/Unit test | B1 |
| REQ-DATA-003 | The program shall not require the entire input PDF content to remain resident in memory if the selected backend permits incremental processing. | Inspection/Analysis | B2 |

### 4.4 Adaptation, environment, and resource requirements

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-ENV-001 | The initial supported runtime environment shall be Linux on ordinary desktop hardware using the project-selected Ada toolchain and documented PDF dependencies. | Demonstration/Inspection | B2 |
| REQ-ENV-002 | The program shall process files locally and shall not require a network connection for normal operation. | Test/Inspection | B2 |
| REQ-ENV-003 | The program shall create temporary processing artifacts only when required, shall avoid placing them in the output path, and shall remove them on normal completion and handled failure where the operating environment permits. | Test/Inspection | B2 |
| REQ-ENV-004 | The program shall report an error rather than silently clipping content or producing an output when requested geometry is impossible. | Test | B1 |

### 4.5 Quality and implementation constraints

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-QUAL-001 | Deliverable software shall be implemented in Ada. | Inspection | B1 |
| REQ-QUAL-002 | Given the same input bytes, tool version, and parameters, the program shall produce semantically equivalent output layout; byte-for-byte identity is required only if the selected PDF backend can provide it without unstable metadata. | Test/Analysis | B3 |
| REQ-QUAL-003 | The program shall expose unsupported input features or degraded preservation behavior in a diagnostic or documented capability report; it shall not silently claim preservation. | Test/Inspection | B1/B2 |
| REQ-QUAL-004 | The program shall not upload input documents, use telemetry, or disclose document content through ordinary logs. | Inspection/Test | B2 |
| REQ-QUAL-005 | The source, build instructions, tests, requirements, design records, and release records shall be maintained in the project library. | Inspection | B2/B3 |

### 4.6 Input-feature requirements

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-PDF-001 | The program shall preserve selectable text, hyperlinks, annotations, bookmarks, metadata, forms, and embedded fonts when supported by the selected backend, and shall document any unsupported or degraded feature. Source cropping shall preserve imported page content; annotation and form-field transformation limitations shall be documented. | Test/Inspection | B2 |
| REQ-PDF-002 | The program shall reject encrypted input unless an explicitly supported authentication mechanism is supplied. | Test | B2 |
| REQ-PDF-003 | The program shall preserve basic input metadata where supported and shall identify ezbind processing in output metadata. | Test/Inspection | B2 |

### 4.7 Documentation requirements

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-DOC-001 | The deliverable documentation shall include a versioned command manual page named `ezbind(1)` in a standard man-page source format, and the release package shall identify its installation location. | Inspection | B2 |
| REQ-DOC-002 | `ezbind(1)` shall document the canonical synopsis, all supported options, defaults, physical units, output and overwrite behavior, exit statuses, diagnostics, PDF limitations, the duplex/fold workflow, and at least one complete invocation example. | Inspection | B2 |
| REQ-DOC-003 | The released `ezbind(1)` page shall correspond to the executable version and shall be updated whenever the command-line interface, defaults, exit statuses, or physical workflow changes. | Inspection/Test | B2/B3 |

### 4.8 Safety and physical-use constraints

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-PHY-001 | The generated layout shall identify the expected duplex/fold workflow in user documentation, including that the fold is toward the spine. | Inspection/Demonstration | B2 |
| REQ-PHY-002 | The default output shall not print cover-card artwork or represent fabric as printed material; physical cover cards, adhesive, and fabric remain user-supplied. | Test/Inspection | B2 |
| REQ-PHY-003 | The application shall support a physical acceptance fixture that verifies duplex orientation, page sequence, fold direction, stacking order, and optional guide/margin placement. | Demonstration/Inspection | B1/B2 |

## 5. Qualification provisions and traceability

### 5.1 Planned test identifiers

The following test groups are reserved in the Test Plan and will be expanded into executable cases:

| Test group | Coverage |
|---|---|
| TEST-GEO | Unit conversion, dimensions, margins, safe-area fit, grid rectangles. |
| TEST-IMP | Page ordering, padding, sides, positions, rotations, and fold sequence. |
| TEST-PDF | Input validation, output validity, visual preservation, metadata, unsupported features. |
| TEST-CLI | Options, defaults, help, canonical usage, invalid flags, diagnostics, exit statuses, positional-path modes, path-collision rules, and post-success replacement policy. |
| TEST-DOC | Man-page presence, content, version correspondence, and installation metadata. |
| TEST-PHY | Printed duplex/fold/stack fixture and optional physical guides. |
| TEST-SEC | Local-only behavior, temporary files, and content-free diagnostics. |

### 5.2 Initial traceability matrix

| Requirement range | Planned verification |
|---|---|
| REQ-CAP-001..009 | TEST-IMP, TEST-PDF, TEST-GEO |
| REQ-CAP-010..012 | TEST-CLI, TEST-PHY |
| REQ-CAP-013..022 | TEST-GEO, TEST-CLI, TEST-PHY |
| REQ-CAP-023..024 | TEST-CLI, TEST-PDF |
| REQ-CAP-025..026 | TEST-COVER, TEST-CLI |
| REQ-CLI-001..009 | TEST-CLI, TEST-SEC |
| REQ-DATA-001..003 | TEST-GEO, unit inspection |
| REQ-ENV-001..004 | TEST-SEC, TEST-PDF |
| REQ-QUAL-001..005 | Inspection, all test groups |
| REQ-PDF-001..003 | TEST-PDF |
| REQ-PHY-001..003 | TEST-PHY, inspection |
| REQ-DOC-001..003 | TEST-DOC, inspection |

The detailed Test Description will identify exact input data, steps, expected results, and pass/fail criteria before acceptance testing. It will compare help and invalid-invocation output against the canonical usage line byte-for-byte, excluding platform line-ending normalization. The revised interface, normalized path-collision rules, and replacement policy were verified by the 2026-10-24 regression run recorded in the B2 Test Description; independent physical acceptance remains pending.

### 5.3 Requirements-to-source traceability

All requirements in this draft trace to the user initiating brief and the user-approved B0 resolutions recorded in `requirements/operational-concept.md`, Section 8. Requirements introduced solely as implementation constraints will be identified as design decisions rather than silently treated as user requirements.

## 6. Notes

- This specification was accepted by the user on 2026-09-21 and is client-controlled Revision 1.1.
- The initial man-page scope is `ezbind(1)`; additional man pages are not required until another user-facing command or file format is introduced.
- The PDF backend is intentionally not selected by this document; backend selection is a design activity constrained by these requirements.
- The physical duplex flip direction must be confirmed with a printed fixture because printer driver settings vary.
- Requirements may be changed only through the project change-control process after baseline acknowledgement.

## Self-evaluation

- Applicable SRS checklist sections are present: scope, references, requirements by category, verification methods, qualification provisions, traceability, and notes.
- Every listed requirement has a verification method and planned build.
- CLI usage behavior and the `ezbind(1)` deliverable are explicitly specified and traceable to tests.
- The scope and accepted physical baseline are represented.
- Remaining implementation choices are identified as design decisions.
- Result: **accepted as the client-controlled requirements baseline after user acknowledgement on 2026-09-21.**

## 7. Requirements baseline acknowledgement

The user accepted the requirements in this specification on 2026-09-21, including the `ezbind(1)` man-page requirements and canonical usage behavior. This document is now client-controlled Revision 1.1. Changes require a Problem/Change Log entry and user agreement before modification.
