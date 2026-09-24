# ezbind Software Design Description

**Project:** ezbind
**Document:** Software Design Description (SDD)
**Identifier:** EZBIND-SDD-001
**Status:** Client-acknowledged baseline
**Date:** 2026-09-21
**Revision:** 1.0

## Contents

1. Scope
2. Referenced documents
3. Component-wide design decisions
4. Architectural design
5. Detailed design
6. Requirements traceability
7. Backend evaluation and proof-of-concept plan
8. Notes and self-evaluation

## 1. Scope

This document defines the proposed design of `EZBIND-CLI`, the Ada command-line application that transforms one input PDF into a folded-folio bookbinding layout. It covers the logical architecture, interfaces, geometry model, PDF backend boundary, diagnostics, error handling, and implementation units used by the B1 proof of concept and B2 implementation slice.

The design satisfies the client-controlled requirements in `requirements/requirements-spec.md`, EZBIND-SRS-001 Revision 1.1. It does not change those requirements.

## 2. Referenced documents

- `plan/project-plan.md`, EZBIND-SDP-001, Revision 1.1.
- `requirements/operational-concept.md`, EZBIND-OCD-001, Revision 1.0.
- `requirements/requirements-spec.md`, EZBIND-SRS-001, Revision 1.1.
- `tests/test-plan.md`, EZBIND-STP-001, Revision 1.1 draft.
- `sdfs/project-development-log.md`, EZBIND-SDF-001.
- Independent PDF backend review, 2026-09-21, recorded in Section 7 and the development log.

## 3. Component-wide design decisions

### 3.1 Architectural style

Use a layered, backend-neutral Ada application with one isolated native PDF adapter:

```text
CLI / application orchestration
          |
  layout validation and geometry
          |
    folio imposition model
          |
    PDF backend abstraction
          |
  qpdf C-compatible bridge (C++)
          |
       qpdf library
```

Ada remains the authoritative implementation language for application behavior. C++ is limited to the project-owned bridge required to access qpdf’s high-level C++ page/Form-XObject API. No qpdf C++ types appear in Ada specifications.

### 3.2 Selected PDF backend

Select qpdf native APIs behind a project-owned C-compatible bridge for the baseline design. POC-001 passed in B1; the B2 implementation slice now covers two-sided destination-page creation, folio padding, Letter/A4 output, vector grid emission, malformed-input handling, and temporary-output commit. Remaining POC cases are planned for B2 expansion and release hardening.

Rationale:

- qpdf directly imports existing pages as Form XObjects;
- imported content can be placed in arbitrary destination rectangles;
- text operators, fonts, images, and vector graphics remain PDF content rather than being rasterized;
- qpdf has a permissive Apache-2.0 license for the core library;
- the bridge keeps version coupling and unsafe/native code out of Ada application units;
- MuPDF and Ghostscript introduce AGPL/commercial licensing decisions and are therefore not baseline dependencies;
- apdf generates PDFs but does not import arbitrary existing page content.

This is a design decision, not a new user requirement. If the proof of concept fails, the issue must be entered in the Problem/Change Log before changing backend strategy.

### 3.3 Physical units and coordinates

Use PDF points internally: 72 points per inch and 25.4 millimetres per inch. A dedicated `Physical` package owns parsing and conversion from millimetres, inches, and points. Geometry uses a bottom-left origin, matching PDF coordinates. User-facing margin names remain top, bottom, fore-edge, and spine; conversion to PDF coordinates occurs in one geometry unit.

Use a fixed-point or sufficiently precise floating representation that preserves requested dimensions within 0.1 mm. No unitless page dimensions are permitted in public layout interfaces.

### 3.4 Page and sheet model

The default sheet is a physical PDF page with the selected Letter or A4 dimensions. Two finished-page rectangles are placed side-by-side on each output sheet side. A folded sheet therefore yields four logical pages.

The default logical order is:

| Output side | Left placement | Right placement |
|---|---:|---:|
| Front | logical page 4 | logical page 1 |
| Back | logical page 2 | logical page 3 |

The imposition layer produces the page sequence and transformations independently of qpdf. The PDF adapter receives explicit placements and does not derive page order.

The exact back-side transformation is represented in the placement model and verified with asymmetric physical fixtures. This avoids embedding a printer-driver assumption in the geometry code.

### 3.5 Source-page placement policy

Use the effective source page box, preferring CropBox and falling back to MediaBox. Respect source page rotation and UserUnit through qpdf’s transformation-aware page import. Apply global visual source crop distances (top, bottom, left, right) to that effective CropBox, validate every page independently, and clip the retained source rectangle before fitting it uniformly inside the margin-bounded content rectangle without distortion. The configured top, bottom, fore-edge, and spine margins remain output clearances; aspect-ratio differences may add letterboxing to one pair of edges. Source crop distances default to zero. Auto-crop is not part of this build. A retained rectangle with zero or negative width or height fails before output creation; ordinary source content removal is valid.

Mixed source-page dimensions are accepted only when each page independently fits the configured finished-page rectangle. An impossible placement causes validation failure before output creation.

### 3.6 Margin, reserve, and grid policy

The geometry model separates:

- finished-page rectangle;
- top, bottom, fore-edge, and spine margins;
- printer safe-area reserve;
- spine/fabric reserve;
- source-content rectangle;
- grid clipping regions.

The grid is generated as vector line content in the four reserved strips outside the margin-bounded source-content rectangles. It is appended after imported page content only in permitted margin areas and never crosses a source-content rectangle. The spine margin is on each fold-facing inner edge and the fore-edge margin is outer. Default grid spacing is 5 mm, line width 0.25 pt, and light gray.

### 3.7 Cover and physical-material policy

The default folio output excludes cover artwork. When all three cover options are supplied, the application emits a separate one-page landscape cardstock PDF. The back SVG is rendered on the left half and the front SVG on the right half, so a center cut places both cut edges toward the spine. After rendering both SVGs, the bridge draws a 0.5 pt dashed gray vector cut line at the sheet midpoint, inset 12 pt from the top and bottom edges; drawing last ensures the guide remains visible over artwork. The guide is always present in cover output and has no CLI switch. Rendering uses the project-owned librsvg/Cairo bridge, with proportional fitting to each half-sheet viewport. The SVG bridge writes a temporary PDF and the application commits it only after successful rendering. Physical cover cards, adhesive, and fabric remain user-supplied.

The SVG renderer is intentionally separate from the qpdf folio compositor. qpdf remains responsible for importing and imposing the input PDF; librsvg and Cairo render static SVG artwork directly to PDF. SVG feature support, external resources, and font availability are documented limitations.

### 3.8 Error and exception handling

Use typed result/status values for expected failures and exceptions for unexpected programming or backend failures. Expected failures include:

- command-line usage error: status 2;
- input-PDF error: status 3;
- impossible layout: status 4;
- output/filesystem error: status 5;
- missing or unusable runtime dependency: status 6;
- unexpected internal error: status 10.

Validate all command-line and geometry inputs before opening the output path. Write output to a temporary sibling file and atomically rename it only after successful completion, unless platform limitations prevent that operation. Remove partial temporary output on handled failure.

Diagnostics identify the category and corrective action without printing extracted document text, passwords, or complete PDF content.

### 3.9 CLI and documentation contract

The canonical first line for help and usage errors is exactly:

```text
Usage: ezbind [OPTIONS] INPUT.pdf --output OUTPUT.pdf
```

`--help` and `-h` print the usage line, concise option summary, and exit-status summary to standard output and return 0. Each other long option has a corresponding short alias: `-o`, `-f`, `-g`, `-G`, `-t`, `-b`, `-e`, `-i`, and `-s`. Invalid flags and malformed invocations print a diagnostic followed by the same usage line to standard error and return 2. The command manual source is `doc/ezbind.1`; the Alire crate owns the generated GPR/configuration files; the generated/installable form is `ezbind(1)`.

### 3.10 Reproducibility and capability reporting

The application reports selected non-default layout options in a concise summary. Backend capability limitations are represented by explicit feature statuses and warnings. The baseline guarantees visible page content and selectable text where qpdf supports it; annotations, forms, bookmarks, tagged structure, signatures, and other page/document features are preserved only if separately implemented or reported as degraded.

## 4. Architectural design

### 4.1 Software units

| ID | Unit | Language/type | Purpose |
|---|---|---|---|
| UNIT-CLI | `Ezbind_CLI` | Ada package | Parse arguments, implement help/usage, map errors to exit statuses. |
| UNIT-APP | `Ezbind_Application` | Ada package | Orchestrate validation, layout, backend lifecycle, diagnostics, and atomic output. |
| UNIT-PHY | `Ezbind_Physical` | Ada package | Parse and convert physical dimensions and units. |
| UNIT-GEO | `Ezbind_Geometry` | Ada package | Compute sheet, finished-page, margin, reserve, and grid rectangles. |
| UNIT-IMP | `Ezbind_Imposition` | Ada package | Produce padded logical pages, sides, positions, rotations, and placement records. |
| UNIT-GRD | `Ezbind_Guides` | Ada package | Generate vector grid, spine guide, fold/crop/registration marks, and cover placeholders. |
| UNIT-PDF | `Ezbind_PDF_Backend` | Ada package | Backend-neutral PDF lifecycle and placement interface. |
| UNIT-QPDF | `ez_qpdf_bridge` | C++ with C ABI | Open/read/write PDFs, create/import Form XObjects, place pages, append content. |
| UNIT-SVG | `ez_svg_bridge` | C++ with C ABI | Load static SVG files through librsvg and render front/back cover art to a Cairo PDF surface. |
| UNIT-CONT | `Ezbind_Capabilities` | Ada package | Track preserved, degraded, and unsupported source features. |
| UNIT-DOC | `doc/ezbind.1` | roff man page | User-facing command reference synchronized with CLI behavior. |
| UNIT-TEST | `tests/` | Ada and shell support | Unit/integration/acceptance fixtures and independent PDF checks. |

### 4.2 Static relationships

- `UNIT-CLI` depends on `UNIT-APP` and shared error/option types.
- `UNIT-APP` depends on `UNIT-PHY`, `UNIT-GEO`, `UNIT-IMP`, `UNIT-GRD`, `UNIT-PDF`, and `UNIT-CONT`.
- `UNIT-GEO` depends on `UNIT-PHY` but not on PDF or CLI units.
- `UNIT-IMP` depends on geometry placement types but not on qpdf.
- `UNIT-GRD` produces backend-neutral vector guide commands or content streams.
- `UNIT-PDF` defines the Ada-side abstract operations implemented by `UNIT-QPDF`.
- `UNIT-QPDF` and `UNIT-SVG` are the only units that include native PDF/rendering headers or use C/C++ interop. `UNIT-SVG` depends on librsvg 2.58, Cairo, GLib/GIO, GDK-Pixbuf, and Pango/Cairo as provided by the platform.
- `UNIT-DOC` is maintained against the public option model and canonical usage constant.

### 4.3 Dynamic execution sequence

1. `UNIT-CLI` parses arguments.
2. `UNIT-CLI` handles help immediately, without requiring an input file.
3. `UNIT-APP` validates paths, options, units, and geometry.
4. `UNIT-PDF` opens and validates the input through `UNIT-QPDF`.
5. `UNIT-IMP` computes page padding and all output placements.
6. `UNIT-APP` creates a temporary output PDF through `UNIT-QPDF`.
7. For each output sheet side, `UNIT-QPDF` creates a destination page and places the two source Form XObjects.
8. `UNIT-GRD` emits enabled vector guides into permitted regions.
9. `UNIT-QPDF` writes and closes the temporary output.
10. `UNIT-APP` atomically renames the temporary folio output to the requested path.
11. If cover options are enabled, `UNIT-SVG` renders back-left/front-right artwork to a separate temporary cardstock PDF and `UNIT-APP` commits that output.
12. `UNIT-CLI` prints a concise success summary and returns 0.

Any expected failure closes backend handles, removes temporary output, prints a content-free diagnostic, and returns the mapped status.

### 4.4 Interface design

The Ada backend abstraction should expose operations equivalent to:

```text
Open_Input (Path) -> Input_Handle, Capabilities, Page_Count
Get_Page_Descriptor (Input, Page_Number) -> Page_Descriptor
Create_Output (Sheet_Size) -> Output_Handle
Place_Page (Output, Input, Source_Page, Destination_Rectangle, Transform)
Append_Vector_Content (Output_Page, Content_Commands)
Add_Blank_Page (Output, Page_Size)
Write_Output (Output, Path)
Close (Input, Output)
```

The C bridge should expose opaque handles and plain C scalar/record parameters only:

```text
ez_qpdf_open_input
ez_qpdf_get_page_count
ez_qpdf_get_page_descriptor (effective visual CropBox dimensions)
ez_qpdf_begin_output
ez_qpdf_begin_page
ez_qpdf_place_page
ez_qpdf_append_content
ez_qpdf_add_blank_page
ez_qpdf_write_output
ez_qpdf_close
ez_qpdf_last_error
```

The implemented bridge ABI is defined by `src/ez_qpdf_bridge.h` and the Ada binding `src/ezbind_qpdf_bridge.ads`; future extensions must preserve the opaque-handle boundary. Ownership rules must be explicit: the bridge owns native allocations; Ada receives copied scalar data and invokes the close operation exactly once.

### 4.5 External interfaces

#### CLI interface

The public command is `ezbind`. Input is one local PDF path; output is a local PDF path. Standard output is for help and success summaries. Standard error is for diagnostics and invalid invocation output. Exit statuses are those defined in the SRS.

#### PDF backend interface

The only native dependency is qpdf through the project bridge. Build-time requirements include qpdf headers, C++ compiler/linker, and Ada/C interoperability support. Runtime requirements include the qpdf shared library or a statically linked bridge arrangement selected during build packaging.

#### Filesystem interface

The application reads the input path, creates a temporary sibling output, and commits it by rename. Existing output is refused unless `--force` is specified.

### 4.6 Data flow

```text
CLI arguments
    -> typed Options
    -> validated Layout_Configuration
    -> Placement_List
    -> backend operations
    -> temporary PDF
    -> atomic output PDF
```

No database is required. No persistent user data is stored. No input PDF content is logged.

## 5. Detailed design

### 5.1 `Ezbind_Physical` / UNIT-PHY

Purpose: parse physical values and provide exact named conversions.

Data:

- `Unit_Kind`: Millimetre, Inch, Point;
- `Physical_Value`: canonical point value with range checks;
- parsing result and invalid-value diagnostic.

Logic:

- parse suffixes `mm`, `in`, `pt`;
- reject negative or non-finite values;
- convert through points;
- use named constants for conversion factors;
- preserve precision through geometry calculations.

### 5.2 `Ezbind_Geometry` / UNIT-GEO

Purpose: validate layout fit and calculate rectangles.

Inputs:

- sheet dimensions;
- finished-page dimensions or derived half-sheet dimensions;
- four margins;
- safe-area and fabric reserves;
- grid spacing;
- guide/mark options.

Outputs:

- two finished-page rectangles per side;
- per-page source-content rectangles;
- grid clipping rectangles/segments;
- mark locations;
- validation result.

Rules:

- reject nonpositive dimensions;
- reject negative available content dimensions;
- reject any rectangle outside the sheet;
- preserve the source page aspect ratio;
- use bottom-left coordinates for backend calls;
- ensure numerical error remains within the SRS tolerance.

### 5.3 `Ezbind_Imposition` / UNIT-IMP

Purpose: transform a source page count into a placement list.

Inputs:

- source page count;
- page-padding policy;
- geometry and side transformations.

Outputs:

- padded logical page list;
- output sheet/side records;
- two placements per physical output side;
- source page number or blank marker;
- rotation and destination rectangle.

For each four-page group with logical pages `a`, `b`, `c`, `d`, use the assignment front-left `d`, front-right `a`, back-left `b`, back-right `c`. The unit does not open PDFs or draw content.

### 5.4 `Ezbind_Guides` / UNIT-GRD

Purpose: produce vector guides independent of source page content.

Inputs:

- geometry exclusions;
- grid configuration;
- mark and guide configuration.

Outputs:

- validated vector line/path commands in PDF coordinates.

Rules:

- grid spacing is positive;
- lines are clipped to permitted margin regions;
- grid does not enter source-content, spine/fabric, or safe-area exclusions;
- default line width is 0.25 pt and default color is light gray;
- disabled guide options produce no corresponding commands.

### 5.5 `Ezbind_PDF_Backend` / UNIT-PDF

Purpose: hide native PDF operations from application code.

Responsibilities:

- expose lifecycle and placement operations;
- translate native errors to typed backend results;
- track feature capability statuses;
- ensure native handles are closed on all paths;
- avoid exposing C++ or qpdf types in Ada specs.

### 5.6 `ez_qpdf_bridge` / UNIT-QPDF

Purpose: implement native PDF import and output.

Responsibilities:

- open and validate input;
- inspect page count and effective visual page geometry;
- import source pages as transformation-aware Form XObjects;
- replace each fresh form BBox with the retained source rectangle before copying;
- copy foreign objects into output;
- place clipped page Form XObjects into destination rectangles;
- append vector content streams;
- write output and expose errors through the C ABI.

The bridge was tested independently with POC-001 and is now integrated with the Ada application orchestration for the B2 implementation slice.

### 5.7 `Ezbind_CLI` / UNIT-CLI

Purpose: define stable command behavior.

Rules:

- parse `--help` and `-h` before requiring positional input;
- accept the documented short aliases for every existing long option;
- emit the exact canonical usage first line;
- reject unknown flags and missing values;
- route diagnostics to standard error;
- map all expected errors to the SRS status codes;
- never open or replace the output for usage errors.

### 5.8 `ezbind(1)` / UNIT-DOC

Purpose: document the public command interface.

The man page is generated/maintained from the same option inventory and canonical usage contract used by `UNIT-CLI`. It must include synopsis, description, options, defaults, units, output behavior, exit statuses, limitations, physical workflow, and examples.

## 6. Requirements traceability

| Requirement group | Design units |
|---|---|
| REQ-CAP-001..024 | UNIT-APP, UNIT-PHY, UNIT-GEO, UNIT-IMP, UNIT-GRD, UNIT-PDF, UNIT-QPDF |
| REQ-CLI-001..009 | UNIT-CLI, UNIT-APP, UNIT-DOC |
| REQ-DATA-001..003 | UNIT-PHY, UNIT-GEO, UNIT-IMP, UNIT-PDF |
| REQ-ENV-001..004 | UNIT-APP, UNIT-PDF, UNIT-QPDF |
| REQ-QUAL-001..005 | All units; project build and library controls |
| REQ-PDF-001..003 | UNIT-PDF, UNIT-QPDF, UNIT-CONT |
| REQ-DOC-001..003 | UNIT-DOC, UNIT-CLI, release packaging |
| REQ-PHY-001..003 | UNIT-IMP, UNIT-GRD, UNIT-DOC, physical fixture |

## 7. Backend evaluation and proof-of-concept plan

### 7.1 Alternatives

| Candidate | Decision | Rationale |
|---|---|---|
| qpdf native API via C++ bridge | Selected and implemented for B1/B2 | Direct Form-XObject import, explicit destination-page creation, and arbitrary placement; permissive license; preserves visible content/text. |
| qpdf CLI | Validation support only | Does not expose required arbitrary page placement. |
| apdf | Rejected as primary backend | Generates PDFs but does not import arbitrary source pages. |
| MuPDF | Rejected for baseline | Native API viable, but installed package is AGPL/commercial-license-sensitive. |
| Ghostscript | Rejected for baseline | Interpreter-oriented composition and AGPL/security/version risks. |
| Poppler/raster | Rejected for folio placement | Visual fallback only; loses PDF semantics and selectable text. |
| librsvg/Cairo | Selected for cover artwork | Direct static-SVG rendering to a PDF surface; avoids an external converter and preserves vector/text output where supported. |

### 7.2 Proof-of-concept exit criteria

For B2 expansion and release hardening, execute and record the remaining POC tests covering:

- native qpdf page import and two-up placement;
- four-page order and orientation;
- padding to a multiple of four;
- mixed rotations and dimensions;
- selectable text preservation;
- vector grid and guide clipping;
- exact physical page geometry;
- visible-content regression;
- unsupported annotations/forms/metadata reporting;
- malformed/encrypted input;
- dependency failure;
- semantic determinism;
- physical duplex fixture.

The completed POC-001 slice passed without rasterization, produced valid Letter output, preserved expected text extraction, and inserted vector content. Remaining POC cases must establish mixed-page geometry, guide clipping, and unsupported-feature reporting.

### 7.3 Dependency and licensing conditions

The qpdf and librsvg/Cairo development headers and C++ toolchain are available in the tested Linux environment. The implemented path uses qpdf 11.9.0, librsvg 2.58.0, Cairo 1.18.0, dynamic linking, GCC/G++ C++17 support, and Alire-selected GNAT native 15.2.1/GPRbuild 25.0.1. These versions, the Apache-2.0 qpdf dependency, and the LGPL librsvg/Cairo dependency must be recorded in release documentation.

## 8. Notes and self-evaluation

### 8.1 Assumptions and deferred decisions

- qpdf’s high-level C++ API remains stable enough for the pinned version; the bridge isolates changes.
- The first implementation prioritizes visible content and selectable text; feature preservation outside page content is capability-reported.
- The exact duplex back-side transform is validated physically and is not inferred solely from a screen preview.
- A separate Database Design Description is not applicable; the application has no database.
- A separate Interface Design Description is consolidated into this SDD because the interfaces are local CLI, filesystem, and one isolated bridge.

### 8.2 Self-evaluation

- **Scope and references:** Present and aligned with the client-controlled SRS.
- **Component-wide decisions:** Backend, units, page model, errors, output policy, CLI, and capability boundary are stated with rationale.
- **Architecture:** Units, static/dynamic relationships, interfaces, and execution concept are identified.
- **Detailed design:** Each proposed unit has purpose, interfaces, data, logic, constraints, and dependencies.
- **Traceability:** Requirement groups map to design units.
- **Feasibility:** The design uses a narrow bridge to isolate the principal native dependency and defines a proof-of-concept gate.
- **Independence limitation:** This design is self-evaluated by the implementing developer; user design review is required before baseline.

Result: **accepted as the client-controlled design baseline after user acknowledgement on 2026-09-21.**

## 9. Current gate

The requirements and design baselines are accepted. B1 implementation and dependency pinning are complete, and the first B2 application-orchestration slice is implemented and tested. The project is at the B2 implementation-slice/test-readiness gate; broader option coverage and acceptance qualification remain future work.

## 10. Design baseline acknowledgement

The user reviewed and accepted this Design Description on 2026-09-21, including the qpdf native backend recommendation, C-compatible C++ bridge, Ada architecture, and proof-of-concept exit criteria. This document is now client-controlled Revision 1.0. Changes require a Problem/Change Log entry and user agreement before modification.
