# ezbind Software Design Description

**Project:** ezbind
**Document:** Software Design Description (SDD)
**Identifier:** EZBIND-SDD-001
**Status:** Draft project update under CHG-015
**Date:** 2026-10-24
**Revision:** 1.3 (project update; CHG-015 targeted implementation verification complete)

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

This document describes the design of `EZBIND-CLI`, the Ada command-line application with separate `text` and `cover` operations. It covers the logical architecture, interfaces, geometry model, PDF backend boundaries, diagnostics, error handling, and implementation units used by the B1 proof of concept and B2 implementation slice.

This project update records the CHG-015 interface and implementation. Targeted implementation verification is complete and recorded in `tests/b2-test-description.md`; broader acceptance and independent physical review remain pending. Earlier combined-mode behavior is superseded.

## 2. Referenced documents

- `plan/project-plan.md`, EZBIND-SDP-001, Revision 1.1.
- `requirements/operational-concept.md`, EZBIND-OCD-001, Revision 1.1 project update.
- `requirements/requirements-spec.md`, EZBIND-SRS-001, Revision 1.3 project update.
- `tests/test-plan.md`, EZBIND-STP-001, Revision 1.2 project update.
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

The default folio output excludes cover artwork. The distinct `cover` command emits a one-page landscape cardstock PDF from front/back SVG artwork; the `text` command produces only the folded-folio PDF. The back SVG is rendered on the left half and the front SVG on the right half, so a center cut places both cut edges toward the spine. After rendering both SVGs, the bridge draws a 0.5 pt dashed gray vector cut line at the sheet midpoint, inset 12 pt from the top and bottom edges; drawing last ensures the guide remains visible over artwork. The guide is always present in cover output and has no CLI switch. Rendering uses the project-owned librsvg/Cairo bridge, with proportional fitting to each half-sheet viewport. The SVG bridge writes a temporary PDF and the application commits it only after successful rendering. Physical cover cards, adhesive, and fabric remain user-supplied.

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

The public commands are `ezbind text [OPTIONS] INPUT.pdf OUTPUT.pdf` and `ezbind cover [OPTIONS] --front FRONT.svg --back BACK.svg OUTPUT.pdf`. Each invocation produces one output. There is no combined mode and no compatibility alias for the former `--cover-*` options. Text-only options are rejected by `cover`; artwork options are rejected by `text`. Shared sheet geometry and output-commit helpers may be reused, while text and cover have distinct producer functions. Cover generation does not validate text layout.

Top-level help lists commands; each command has its own help and canonical usage for errors. Help on its own exits 0. Both commands accept `--sheet`/`-s`, interspersed options, and `--` to end option parsing. Each command writes a temporary sibling and replaces its single destination only after successful generation. Separate invocations cannot check cross-invocation path collisions together; two commands do not form a transaction. The command manual is `doc/ezbind.1`; the installable form is `ezbind(1)`.

Status 6 remains part of the required interface, but the current application has no dependency-error return path. Dynamic-loader errors occur before `Run`.

### 3.10 Reproducibility and capability reporting

The application reports selected non-default layout options in a concise summary. Backend capability limitations are represented by explicit feature statuses and warnings. The baseline guarantees visible page content and selectable text where qpdf supports it; annotations, forms, bookmarks, tagged structure, signatures, and other page/document features are preserved only if separately implemented or reported as degraded.

## 4. Architectural design

### 4.1 Software units

| ID | Unit | Language/type | Purpose |
|---|---|---|---|
| UNIT-CLI | `Ezbind_CLI` | Ada package | Render top-level and command-specific help and usage text; provide usage-formatting support. It does not parse or dispatch commands. |
| UNIT-APP | `Ezbind_Application` | Ada package | Own `Run` and `Parse_Options`; parse/validate arguments, handle help and command dispatch, and own `Produce_Text` / `Produce_Cover`. Uses shared geometry and per-output commit behavior. |
| UNIT-PHY | `Ezbind_Physical` | Ada package | Parse and convert physical dimensions and units. |
| UNIT-GEO | `Ezbind_Geometry` | Ada package | Compute sheet, finished-page, margin, reserve, and grid rectangles. |
| UNIT-IMP | `Ezbind_Imposition` | Ada package | Produce padded logical pages, sides, positions, rotations, and placement records. |
| UNIT-GRD | `Ezbind_Guides` | Ada package | Generate vector grid, spine guide, fold/crop/registration marks, and cover placeholders. |
| UNIT-PDF | `Ezbind_PDF_Backend` | Planned conceptual unit | Backend-neutral PDF lifecycle and placement interface; not claimed as a separate current package. |
| UNIT-QPDF | `ez_qpdf_bridge` | C++ with C ABI | Open/read/write PDFs, create/import Form XObjects, place pages, append content. |
| UNIT-SVG | `ez_svg_bridge` | C++ with C ABI | Load static SVG files through librsvg and render front/back cover art to a Cairo PDF surface. |
| UNIT-CONT | `Ezbind_Capabilities` | Planned conceptual unit | Track preserved, degraded, and unsupported source features; not claimed as a separate current package. |
| UNIT-DOC | `doc/ezbind.1` | roff man page | User-facing command reference synchronized with CLI behavior. |
| UNIT-TEST | `tests/` | Ada and shell support | Unit/integration/acceptance fixtures and independent PDF checks. |

### 4.2 Static relationships

- `UNIT-APP` owns option parsing, validation, help dispatch, command selection, and distinct `Produce_Text` / `Produce_Cover` paths. `UNIT-CLI` supplies help and usage rendering only.
- The text producer uses the implemented physical-unit, geometry, and imposition packages plus the qpdf bridge. Guide generation is currently performed in the application; the guide package is a scaffold. The backend-neutral PDF and capability packages remain planned. Cover production uses its cover path without text-layout or qpdf input processing.
- In the conceptual target decomposition, geometry depends on physical-unit conversion and not on PDF or CLI responsibilities.
- In the conceptual target decomposition, imposition depends on geometry placement types but not on qpdf.
- In the conceptual target decomposition, guide generation produces backend-neutral vector commands or content streams.
- The conceptual PDF-backend interface isolates native qpdf operations behind the C-compatible bridge.
- `UNIT-QPDF` and `UNIT-SVG` are the only units that include native PDF/rendering headers or use C/C++ interop. `UNIT-SVG` depends on librsvg 2.58, Cairo, GLib/GIO, GDK-Pixbuf, and Pango/Cairo as provided by the platform.
- `UNIT-DOC` is maintained against the two command-specific usage models and shared option inventory; this is a documentation contract, not a parser implemented by `UNIT-CLI`.

### 4.3 Dynamic execution sequence

The dispatcher selects distinct producers. Shared geometry and single-output commit helpers do not imply a combined operation. The cover producer does not invoke text-layout validation.

1. `UNIT-APP.Run` handles standalone help without opening inputs; otherwise `UNIT-APP.Parse_Options` selects `text` or `cover`, validates command-specific options, interspersed arguments, `--`, and positional arity, and rejects options exclusive to the other command. `UNIT-CLI` renders applicable help/usage.
2. The text producer validates text paths and layout, opens the input through the qpdf bridge, computes imposition, writes all folio sides and enabled guides to a temporary output, then commits its single destination after success.
3. The cover producer validates SVG paths and its single destination, computes shared sheet geometry only, renders back-left/front-right artwork through `UNIT-SVG` to a temporary PDF, then commits that destination after success. It does not open a text PDF.
4. The selected producer reports success and application orchestration returns status 0.

Separate invocations have no cross-output collision check or transactional relationship.

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

The public commands are `ezbind text [OPTIONS] INPUT.pdf OUTPUT.pdf` and `ezbind cover [OPTIONS] --front FRONT.svg --back BACK.svg OUTPUT.pdf`. Both accept `--sheet`/`-s`, interspersed options, and `--`. Text rejects artwork flags; cover rejects text-only flags. Reject same-invocation source/destination collisions and replace the single existing destination only after successful generation. No cross-invocation collision or two-command transaction is promised. Top-level and command-specific help are supported. Diagnostics use standard error; exit statuses are those defined in the SRS.

#### PDF backend interface

Native dependencies are qpdf through `UNIT-QPDF` and librsvg/Cairo through `UNIT-SVG`, including the GLib/GIO, GDK-Pixbuf, and Pango/Cairo libraries linked in `ezbind.gpr`. Builds require their development headers/libraries, a C++17 compiler/linker, and Ada/C interoperability support. Runtime requires the corresponding shared libraries for the current dynamic-link configuration.

#### Filesystem interface

Each producer creates one temporary sibling output, rejects its own normalized source/destination collisions, and replaces its destination only after successful generation. GNAT.OS_Lib provides symbolic-link-aware path normalization and POSIX replacement rename on the supported Linux target; replacement does not delete the old destination before rename. Separate invocations cannot check each other’s paths together and are not transactional. Temporary-file names still use the existing fixed suffix; unique temporary ownership remains separate hardening work.

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

### 5.7 `Ezbind_Application` / UNIT-APP

Purpose: coordinate command-line processing and the selected producer.

Implemented responsibilities include `Run` and `Parse_Options`; parsing and validating command-specific options and positional arguments; standalone and command-specific help dispatch; rejecting combined mode, legacy `--cover-*` syntax, and cross-command options; and invoking `Produce_Text` or `Produce_Cover`. Each producer generates and commits only its own output. Cover production does not enter text-layout validation or qpdf input processing. The two producer invocations are independent and are not transactional.

### 5.8 `Ezbind_CLI` / UNIT-CLI

Purpose: render CLI help and usage text.

Implemented responsibilities are top-level and command-specific help text and applicable canonical usage rendering. Argument parsing, option validation, command dispatch, and producer ownership reside in `Ezbind_Application`, not this package.

### 5.9 `ezbind(1)` / UNIT-DOC

Purpose: document the public command interface.

The man page is maintained against the shared option inventory and canonical usage contract implemented across application parsing and `UNIT-CLI` usage rendering. It must include synopsis, description, options, defaults, units, output behavior, exit statuses, limitations, physical workflow, and examples.

## 6. Requirements traceability

The text and cover producers are distinct; shared geometry/commit behavior does not imply one combined transaction. REQ-CAP-001/023/025/026 and REQ-CLI-001/002/006/008 trace to parsing/dispatch in `UNIT-APP`, help/usage rendering in `UNIT-CLI`, command-specific producer paths, planned geometry responsibilities, `UNIT-QPDF` or `UNIT-SVG`, and `UNIT-DOC`. Cover verification confirms that text-layout validation and qpdf input processing are bypassed.

| Requirement group | Design units |
|---|---|
| REQ-CAP-001..024 | UNIT-APP, UNIT-PHY, UNIT-GEO, UNIT-IMP, UNIT-GRD, UNIT-PDF, UNIT-QPDF |
| REQ-CLI-001..009 | UNIT-APP (parsing/dispatch), UNIT-CLI (help/usage rendering), UNIT-DOC |
| REQ-DATA-001..003 | UNIT-PHY, UNIT-GEO, UNIT-IMP, UNIT-PDF |
| REQ-ENV-001..004 | UNIT-APP, UNIT-PDF, UNIT-QPDF |
| REQ-QUAL-001..005 | All units; project build and library controls |
| REQ-PDF-001..003 | UNIT-PDF, UNIT-QPDF, UNIT-CONT |
| REQ-DOC-001..003 | UNIT-DOC, UNIT-CLI (usage rendering), release packaging |
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

This update is self-evaluated by the implementing developer; the evaluation is not independent. The user is invited to review the revised design and its eventual implementation evidence.


- **Scope and references:** Present and aligned with the client-controlled SRS.
- **Component-wide decisions:** Backend, units, page model, errors, output policy, CLI, and capability boundary are stated with rationale.
- **Architecture:** Units, static/dynamic relationships, interfaces, and execution concept are identified.
- **Detailed design:** Each proposed unit has purpose, interfaces, data, logic, constraints, and dependencies.
- **Traceability:** Requirement groups map to design units.
- **Feasibility:** The design uses a narrow bridge to isolate the principal native dependency and defines a proof-of-concept gate.
- **Independence limitation:** This design is self-evaluated by the implementing developer; user design review is required before baseline.

Historical result: **the original design was accepted as the client-controlled baseline after user acknowledgement on 2026-09-21.** This project update has not undergone independent evaluation or new user acceptance; user review is invited.

## 9. Current gate

The original requirements and design baselines were accepted. B1 implementation and dependency pinning are complete, and CHG-015 split-command implementation with targeted verification is complete. The project remains at the B2 implementation-slice/test-readiness gate; broader option coverage, acceptance qualification, and physical duplex/fold review remain future work.

## 10. Design baseline acknowledgement

The user accepted the original Design Description on 2026-09-21. This Revision 1.3 project update records the user-authorized split as CHG-015. Targeted implementation verification is complete; broader acceptance and independent physical review remain pending. It does not claim new user acceptance of the revised design. The developer self-evaluated the implementation evidence; independent review remains invited.
