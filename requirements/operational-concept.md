# ezbind Operational Concept Description

**Project:** ezbind
**Document:** Operational Concept Description (OCD)
**Identifier:** EZBIND-OCD-001
**Status:** Draft for requirements review
**Date:** 2026-09-21
**Revision:** 1.0

## Contents

1. Scope
2. Referenced documents
3. Current situation
4. Justification for change
5. Concept for the new system
6. Operational environment
7. Impacts
8. Analysis
9. Notes

## 1. Scope

ezbind is a local command-line program for transforming one ebook PDF into a duplex-printable PDF for a modified DFA home-bookbinding process. The resulting sheets are printed, folded once with the fold toward the spine, stacked, and glued along the spine side. Physical cover cards and fabric are added by the user.

This document defines the intended user workflow and physical assumptions. Detailed software requirements are in `requirements/requirements-spec.md`.

## 2. Referenced documents

- `plan/project-plan.md`, EZBIND-SDP-001, Revision 1.1.
- `requirements/requirements-spec.md`, EZBIND-SRS-001, Revision 1.1.
- User-approved resolutions to the B0 open-decision register, 2026-09-21.

## 3. Current situation

A user has an ebook PDF whose pages are arranged for ordinary reading or ordinary document printing. Preparing it manually for folded-folio binding requires calculating page order, rotating and placing pages on sheet sides, accounting for margins and the spine reserve, and optionally adding a writing grid. Manual imposition is error-prone, especially for documents whose page count is not divisible by four.

The physical workflow is:

1. Run ezbind against one input PDF.
2. Select a sheet/page geometry and optional layout parameters.
3. Print the generated PDF duplex using the required printer settings.
4. Fold each sheet once with the fold toward the spine.
5. Stack the folded folios in output order.
6. Glue the spine side into a text block.
7. Add physical cover cards and a fabric strip that overlaps the front and back cards and reinforces the spine.

The application does not control the printer or perform physical binding.

## 4. Justification for change

The new system is intended to reduce manual imposition work and make the result repeatable. It should make the folio ordering explicit, prevent impossible layouts, preserve the visible ebook content, and provide optional note-taking margins without requiring page-by-page editing.

## 5. Concept for the new system

### 5.1 User role

The user is an operator who supplies the input PDF, selects physical/layout options, runs the command, prints the output, and performs the physical folding and binding.

### 5.2 Normal operation

Folio mode uses two positional paths, INPUT.pdf OUTPUT.pdf. Combined mode adds all three named cover options; cover-only mode uses zero positional paths and requires --cover-front, --cover-back, and --cover-output. Options may be interspersed, -- ends option parsing, and examples prefer options first. Defaults produce Letter or A4 folded-folio output with zero margins, no creep, no printed marks, no cover artwork, and no spine/fabric guide. The program validates inputs, geometry, options, and path collisions before writing. Existing destinations are replaced without prompting only after successful generation.

The source page is treated as the finished book-page size. A folded sheet contains two source-page positions on each side, for four logical pages per sheet. For a four-page unit, the nominal imposed positions are:

| Printed side | Left position | Right position |
|---|---:|---:|
| Front | 4 | 1 |
| Back | 2 | 3 |

The exact duplex flip/orientation is a controlled implementation detail that must be verified using the physical acceptance fixture; it must produce the stated folded sequence.

### 5.3 Optional operation

The user may request:

- separate front and back SVG cover artwork rendered to a cardstock cover-sheet PDF;
- custom top, bottom, fore-edge, and spine margins;
- millimetres, inches, or points for physical dimensions;
- a 5 mm default graph-paper-like vector grid in margins;
- blank cover-card pages;
- a spine/fabric guide;
- crop, fold, or registration marks;
- explicit creep compensation;
- a printer safe-area reserve;

Existing outputs are replaced without prompting after successful generation.

The application must describe active non-default options in diagnostics or output metadata sufficiently for the user to identify the layout used. The input PDF and source SVGs must not be destinations; normalized path aliases are rejected, and the two output paths must differ.

### 5.4 Error operation

Invalid PDF input, unsupported PDF conditions, impossible geometry, missing dependencies, and filesystem errors produce a diagnostic on standard error, a nonzero exit status, and no misleading completed output. The program must not expose document contents in ordinary diagnostics.

### 5.5 Physical additions

Cover cards and fabric remain physical additions. The default folio output does not print cover artwork. When front/back SVG options are supplied, the program emits a separate cardstock cover-sheet PDF with back artwork left and front artwork right; the user prints it, cuts the center, and uses the two resulting cards. Optional blank cover-card pages and a spine/fabric guide remain aids for layout and registration only; they do not represent the physical materials.

## 6. Operational environment

- Initial target: Linux desktop systems.
- Execution: local, offline-capable processing; no network service is required.
- Input/output: local filesystem PDF files.
- Tool invocation: shell or terminal.
- Physical output: duplex-capable printer and user-supplied paper, cover cards, adhesive, and fabric.
- Support utilities: PDF inspection/rendering utilities may be used during development and acceptance testing.

## 7. Impacts

### 7.1 Positive impacts

- Less manual page-order calculation.
- Repeatable folio output.
- Configurable note-taking margins.
- Early detection of impossible layouts.
- A reproducible command suitable for regression testing.

### 7.2 Limitations and responsibilities

The user remains responsible for printer duplex settings, paper handling, physical trimming if any, adhesive and fabric placement, and confirming that the physical output is suitable before committing a valuable book. Printer-specific non-printable areas must be supplied or conservatively reserved by the user.

## 8. Analysis

### 8.1 Alternatives considered

- **Manual PDF editing:** available but error-prone and not repeatable.
- **General-purpose booklet imposition:** may impose page order but does not expose the modified DFA spine/margin/grid needs.
- **Graphical editor workflow:** potentially flexible but unnecessarily complex for repeatable command-line production.
- **ezbind:** focuses on one validated physical workflow and keeps layout parameters explicit.

### 8.2 Accepted baseline assumptions

The user accepted the proposed B0 resolutions on 2026-09-21:

- Letter, A4, and custom physical dimensions are supported.
- The source page represents the finished page.
- Each sheet is folded once and carries four logical pages.
- Blank padding completes a multiple of four.
- Cover cards are excluded by default.
- Fabric is physical; only an optional guide is printed.
- Margins are independently configurable and measured from finished-page edges.
- Grid is optional, light gray, vector, and confined to margins.
- Creep and marks are optional and disabled by default.
- Processing is local and Linux is the initial target.

## 9. Notes

The physical duplex flip setting is printer-dependent. The generated PDF and user documentation must state the expected duplex orientation and the physical acceptance procedure. Any later change to the folio model requires a change report because it affects core requirements, design, tests, and physical usability.
