# ezbind

`ezbind` is an Ada command-line application for preparing ebook PDFs for a modified DFA home-bookbinding process. It arranges single-sheet folios for duplex printing, folding toward the spine, stacking, and gluing into a text block.

## Project status

The project is in **Build B2 implementation**. The current usable slice validates one input PDF, imposes four logical pages per folded sheet, pads incomplete folios with blanks, supports Letter/A4 output selection, optionally draws a vector margin grid, and uses an explicit overwrite option. The broader option set in the requirements remains staged work.

## Build with Alire

The project uses the canonical Alire executable-crate workflow. The native PDF bridge requires qpdf development headers/library and a C++17 compiler.

```text
alr build --development
(cd tests && alr build --development)
```

Builds should be run sequentially because the nested test crate pins the root crate and both projects may share generated root build state.

The tested native environment is Linux with qpdf 11.9.0, Alire 2.1.0, and Alire-selected GNAT native 15.2.1.

## Current command behavior

```text
Usage: ezbind [OPTIONS] INPUT.pdf --output OUTPUT.pdf
```

Implemented options:

- `--output PATH` — required output path.
- `--sheet letter|a4` — select the physical output sheet; Letter is the default.
- `--grid` — add light-gray vector lines in all configured margin areas, without crossing source content.
- `--grid-spacing VALUE` — set positive grid spacing using a physical value with `mm`, `in`, or `pt` suffix; the default is 5 mm.
- `--margin-top VALUE`, `--margin-bottom VALUE`, `--margin-fore-edge VALUE`, `--margin-spine VALUE` — set independent margins using `mm`, `in`, or `pt`; defaults are 36, 36, 36, and 48 pt.
- `--force` — replace an existing output; replacement is refused by default.
- `--help` and `-h` — print help without requiring an input PDF.

Normal output uses a landscape Letter or A4 sheet with two finished-page rectangles. The nominal folio assignment is front-left 4, front-right 1, back-left 2, and back-right 3. Page counts are padded to a multiple of four with blank logical pages. Default margins are 36 pt top/bottom/fore-edge and 48 pt spine. Margins are minimum clearance around the uniformly scaled source page; the source is not cropped or distorted. Physical option values require an explicit `mm`, `in`, or `pt` suffix.

Help returns status `0`. Invalid flags, missing option values, missing paths, duplicate positional input paths, and oversized paths return status `2` and print a diagnostic followed by the canonical usage line to standard error. Input-PDF failures return `3`; impossible layouts return `4`; output/filesystem failures return `5`; unexpected processing failures return `10`.

Output is written to a sibling temporary file and committed only after successful PDF generation. Ordinary diagnostics do not print extracted document text or complete PDF content.

The current slice does not yet expose cover-card pages, spine/fabric guides, crop/fold/registration marks, creep compensation, safe-area configuration, capability reporting, or full feature-preservation controls. Validate representative output before physical binding.

## B2 verification

The nested test executable runs the Ada core checks and qpdf bridge smoke test:

```text
(cd tests && alr build --development)
./tests/bin/ezbind_tests source.pdf /tmp/ezbind-b1-output.pdf
qpdf --check /tmp/ezbind-b1-output.pdf
```

The B2 execution record is [`tests/b2-test-description.md`](tests/b2-test-description.md). It records help/usage behavior, malformed-input handling, overwrite policy, one-page output, five-page padding, A4/grid output, and sequential root/test builds.

## Controlled project structure

- `plan/` — project plan, configuration status, and corrective-action records
- `requirements/` — operational concept and accepted requirements
- `design/` — accepted architecture and backend rationale
- `src/` — Ada and native bridge source
- `doc/` — command documentation, including `ezbind(1)`
- `tests/` — Alire test crate, test plans, procedures, and results
- `sdfs/` — project and component development logs

The project process, gates, risks, and traceability are documented in [`plan/project-plan.md`](plan/project-plan.md).
