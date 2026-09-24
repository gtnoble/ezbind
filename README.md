# ezbind

`ezbind` is an Ada command-line application for preparing ebook PDFs for a modified DFA home-bookbinding process. It arranges single-sheet folios for duplex printing, folding toward the spine, stacking, and gluing into a text block.

## Project status

The project is in **Build B2 implementation**. The current usable slice validates one input PDF, imposes four logical pages per folded sheet, pads incomplete folios with blanks, supports Letter/A4 output selection, optionally draws a vector margin grid, generates a separate one-sheet cover PDF from front/back SVG artwork, and uses an explicit overwrite option. The broader option set in the requirements remains staged work.

## Build with Alire

The project uses the canonical Alire executable-crate workflow. The native PDF bridges require qpdf and librsvg/Cairo development headers/libraries plus a C++17 compiler.

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

- `-o PATH`, `--output PATH` — required output path.
- `-s letter|a4`, `--sheet letter|a4` — select the physical output sheet; Letter is the default.
- `-g`, `--grid` — add light-gray vector lines in all configured margin areas, without crossing source content.
- `-G VALUE`, `--grid-spacing VALUE` — set positive grid spacing using a physical value with `mm`, `in`, or `pt` suffix; the default is 5 mm.
- `--crop-top VALUE`, `--crop-bottom VALUE`, `--crop-left VALUE`, `--crop-right VALUE` — remove source-page edge distances using `mm`, `in`, or `pt`; values are measured from the effective CropBox, falling back to MediaBox, and default to zero. Edges are visual page edges after rotation.
- `-t VALUE`, `--margin-top VALUE`; `-b VALUE`, `--margin-bottom VALUE`; `-e VALUE`, `--margin-fore-edge VALUE`; `-i VALUE`, `--margin-spine VALUE` — set independent output margins using `mm`, `in`, or `pt`; defaults are 36, 36, 36, and 48 pt.
- `-f`, `--force` — replace existing folio and cover outputs; replacement is refused by default.
- `--cover-front PATH` — SVG artwork for the front cover. This option must be paired with the other cover options.
- `--cover-back PATH` — SVG artwork for the back cover. This option must be paired with the other cover options.
- `--cover-output PATH` — separate one-page PDF output for the cardstock cover sheet.
- `-h`, `--help` — print help without requiring an input PDF.

When cover mode is selected, the cardstock output is one landscape Letter or A4 sheet. The back-cover SVG is rendered on the left half and the front-cover SVG on the right half, so the center cut puts both cut edges toward the spine. A dashed gray center cut guide is printed over the artwork, inset 12 pt from the top and bottom edges. Artwork is rendered proportionally to fit its half-sheet viewport; matching the SVG aspect ratio to the selected card size is recommended. The folio output and cover output must be different paths when both modes are combined. Cover-only mode omits the positional input PDF and `--output`; it requires the three cover options and writes only `--cover-output`.

Normal output uses a landscape Letter or A4 sheet with two finished-page rectangles. The nominal folio assignment is front-left 4, front-right 1, back-left 2, and back-right 3. Page counts are padded to a multiple of four with blank logical pages. Default output margins are 36 pt top/bottom/fore-edge and 48 pt spine. Source crop options are independent: the requested edge content is removed, the remaining positive-area source page is clipped, and it is then fitted uniformly into the output content rectangle without distortion. Crop values are measured from each page's effective CropBox, falling back to MediaBox, and are interpreted as visual edges after rotation. Physical option values require an explicit `mm`, `in`, or `pt` suffix.

Help returns status `0`. Invalid flags, missing option values, missing paths, duplicate positional input paths, incomplete cover options, and oversized paths return status `2` and print a diagnostic followed by the canonical usage line to standard error. Input-PDF failures return `3`; impossible layouts return `4`; output/filesystem or SVG-rendering failures return `5`; unexpected processing failures return `10`.

Folio and cover outputs are written to sibling temporary files and committed only after successful generation. Ordinary diagnostics do not print extracted document text or complete PDF content.

The current slice does not yet expose auto-crop, spine/fabric guides, crop/fold/registration marks, creep compensation, safe-area configuration, capability reporting, or full feature-preservation controls. Source cropping applies to imported page content; annotation and form-field transformation remains subject to backend limitations. Validate representative output before physical binding.

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
