# ezbind Requirements Specification

**Project:** ezbind  
**Document:** Software Requirements Specification (SRS)  
**Identifier:** EZBIND-SRS-001  
**Status:** Draft for client requirements review  
**Date:** 2026-09-21  
**Revision:** 1.0

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

- `plan/project-plan.md`, EZBIND-SDP-001, Revision 1.0.
- `requirements/operational-concept.md`, EZBIND-OCD-001, Revision 1.0.
- `tests/test-plan.md`, EZBIND-STP-001, Revision 1.0 draft.
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
| REQ-CAP-001 | The program shall accept exactly one input PDF path and one output PDF path for a normal invocation. | Test | B2 |
| REQ-CAP-002 | The program shall inspect the input PDF before output generation and shall reject an unreadable, empty, malformed, or unsupported input with a diagnostic and nonzero exit status. | Test | B1/B2 |
| REQ-CAP-003 | The program shall support Letter, A4, and explicitly specified custom sheet dimensions. | Test | B1/B2 |
| REQ-CAP-004 | The program shall treat the configured finished-page dimensions as the target page size for each source page and shall validate that the source content can be placed without unintended cropping. | Test/Analysis | B1 |
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
| REQ-CAP-019 | Grid lines shall be vector lines with a default light-gray appearance and a default line width of 0.25 pt; color and line width may be configurable. | Test/Inspection | B2 |
| REQ-CAP-020 | The program shall provide optional crop marks, fold marks, and registration marks, all disabled by default. | Test/Demonstration | B2 |
| REQ-CAP-021 | The program shall provide creep compensation as an optional explicit value or supported mode, disabled by default, and shall not infer paper thickness without user input. | Test/Analysis | B3 |
| REQ-CAP-022 | The program shall provide an optional printer safe-area reserve and shall reject a layout when the requested content, margins, and reserves do not fit. | Test | B2 |
| REQ-CAP-023 | The program shall provide an explicit overwrite option and shall refuse to replace an existing output by default. | Test | B2 |
| REQ-CAP-024 | The program shall report the selected non-default layout parameters sufficiently for a user to identify how the output was generated. | Test/Inspection | B2 |

### 4.2 External interface requirements

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-CLI-001 | The command-line interface shall accept the input path, output path, sheet selection, page/geometry parameters, margin parameters, grid parameters, cover mode, guide mode, marks, creep, safe area, and overwrite option defined by the user manual. | Test/Demonstration | B2 |
| REQ-CLI-002 | The program shall provide a help operation that identifies usage, defaults, supported units, and error/exit behavior without requiring an input PDF. | Test | B2 |
| REQ-CLI-003 | Normal diagnostics shall be written to standard error and shall not include extracted document text, passwords, or complete PDF content. | Inspection/Test | B2 |
| REQ-CLI-004 | The program shall return exit status 0 on success, 2 for command-line usage errors, 3 for input-PDF errors, 4 for impossible layouts, 5 for output/filesystem errors, 6 for missing/unusable runtime dependencies, and 10 for unexpected internal errors. | Test | B2 |
| REQ-CLI-005 | The program shall operate on one input PDF per invocation; batch processing is not required for this baseline. | Inspection/Test | B2 |

### 4.3 Internal data requirements

| ID | Requirement | Verification | Planned build |
|---|---|---|---|
| REQ-DATA-001 | The layout model shall represent physical dimensions with explicit units and shall distinguish sheet dimensions, finished-page dimensions, margins, reserves, and grid spacing. | Inspection/Analysis | B1 |
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
| REQ-PDF-001 | The program shall preserve selectable text, hyperlinks, annotations, bookmarks, metadata, forms, and embedded fonts when supported by the selected backend, and shall document any unsupported or degraded feature. | Test/Inspection | B2 |
| REQ-PDF-002 | The program shall reject encrypted input unless an explicitly supported authentication mechanism is supplied. | Test | B2 |
| REQ-PDF-003 | The program shall preserve basic input metadata where supported and shall identify ezbind processing in output metadata. | Test/Inspection | B2 |

### 4.7 Safety and physical-use constraints

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
| TEST-CLI | Options, defaults, help, diagnostics, exit statuses, overwrite policy. |
| TEST-PHY | Printed duplex/fold/stack fixture and optional physical guides. |
| TEST-SEC | Local-only behavior, temporary files, and content-free diagnostics. |

### 5.2 Initial traceability matrix

| Requirement range | Planned verification |
|---|---|
| REQ-CAP-001..009 | TEST-IMP, TEST-PDF, TEST-GEO |
| REQ-CAP-010..012 | TEST-CLI, TEST-PHY |
| REQ-CAP-013..022 | TEST-GEO, TEST-CLI, TEST-PHY |
| REQ-CAP-023..024 | TEST-CLI, TEST-PDF |
| REQ-CLI-001..005 | TEST-CLI, TEST-SEC |
| REQ-DATA-001..003 | TEST-GEO, unit inspection |
| REQ-ENV-001..004 | TEST-SEC, TEST-PDF |
| REQ-QUAL-001..005 | Inspection, all test groups |
| REQ-PDF-001..003 | TEST-PDF |
| REQ-PHY-001..003 | TEST-PHY, inspection |

The detailed Test Description will identify exact input data, steps, expected results, and pass/fail criteria before acceptance testing.

### 5.3 Requirements-to-source traceability

All requirements in this draft trace to the user initiating brief and the user-approved B0 resolutions recorded in `requirements/operational-concept.md`, Section 8. Requirements introduced solely as implementation constraints will be identified as design decisions rather than silently treated as user requirements.

## 6. Notes

- This specification is a draft for the requirements review gate. It is not yet client-controlled.
- The PDF backend is intentionally not selected by this document; backend selection is a design activity constrained by these requirements.
- The physical duplex flip direction must be confirmed with a printed fixture because printer driver settings vary.
- Requirements may be changed only through the project change-control process after baseline acknowledgement.

## Self-evaluation

- Applicable SRS checklist sections are present: scope, references, requirements by category, verification methods, qualification provisions, traceability, and notes.
- Every listed requirement has a verification method and planned build.
- The scope and accepted physical baseline are represented.
- Remaining implementation choices are identified as design decisions.
- Result: **acceptable draft for client requirements review; not client-controlled until acknowledged.**
