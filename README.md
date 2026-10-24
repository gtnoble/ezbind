# ezbind

`ezbind` is an Ada command-line application for preparing ebook PDFs for a modified DFA home-bookbinding process. It arranges single-sheet folios for duplex printing, folding toward the spine, stacking, and gluing into a text block.

## Project status

The project is in **Build B2 implementation**. The current usable slice validates inputs, imposes four logical pages per folded sheet, pads incomplete folios with blanks, supports Letter/A4 output selection, optionally draws a vector margin grid, and generates a separate one-sheet cover PDF from front/back SVG artwork. The broader option set in the requirements remains staged work.

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
Usage: ezbind [OPTIONS] INPUT.pdf OUTPUT.pdf
```

The second positional path, `OUTPUT.pdf`, is the required folio output path. For example: `ezbind --sheet a4 book.pdf bound.pdf`.

Implemented options:

- `-s letter|a4`, `--sheet letter|a4` — select the physical output sheet; Letter is the default.
- `-g`, `--grid` — add light-gray vector lines in all configured margin areas, without crossing source content.
- `-G VALUE`, `--grid-spacing VALUE` — set positive grid spacing using a physical value with `mm`, `in`, or `pt` suffix; the default is 5 mm.
- `--crop-top VALUE`, `--crop-bottom VALUE`, `--crop-left VALUE`, `--crop-right VALUE` — remove source-page edge distances using `mm`, `in`, or `pt`; values are measured from the effective CropBox, falling back to MediaBox, and default to zero. Edges are visual page edges after rotation.
- `-t VALUE`, `--margin-top VALUE`; `-b VALUE`, `--margin-bottom VALUE`; `-e VALUE`, `--margin-fore-edge VALUE`; `-i VALUE`, `--margin-spine VALUE` — set independent output margins using `mm`, `in`, or `pt`; defaults are zero for all four margins.
- `--cover-front PATH` — SVG artwork for the front cover. This option must be paired with the other cover options.
- `--cover-back PATH` — SVG artwork for the back cover. This option must be paired with the other cover options.
- `--cover-output PATH` — separate one-page PDF output for the cardstock cover sheet.
- `-h`, `--help` — print help without requiring an input PDF.

Folio mode requires exactly two positional paths (`INPUT.pdf OUTPUT.pdf`). Options may appear before, between, or after them; `--` ends option parsing. Prefer placing options first. Supply option values as separate arguments (`--sheet a4`, not `--sheet=a4`); attached short values and grouped short flags are not supported. Invoke `ezbind --help` or `ezbind -h` on its own. Combined mode adds all three cover options. Cover-only mode supplies zero positional paths and requires `--cover-front`, `--cover-back`, and `--cover-output`.

When cover mode is selected, the cardstock output is one landscape Letter or A4 sheet. The back-cover SVG is rendered on the left half and the front-cover SVG on the right half, so the center cut puts both cut edges toward the spine. A dashed gray center cut guide is printed over the artwork, inset 12 pt from the top and bottom edges. Artwork is rendered proportionally to fit its half-sheet viewport; matching the SVG aspect ratio to the selected card size is recommended. The folio output and cover output must be different paths when both modes are combined. Cover-only mode omits both positional paths; it requires the three named cover options and writes only `--cover-output`.

Normal output uses a landscape Letter or A4 sheet with two finished-page rectangles. The nominal folio assignment is front-left 4, front-right 1, back-left 2, and back-right 3. Page counts are padded to a multiple of four with blank logical pages. Default output margins are zero on all four edges. Source crop options are independent: the requested edge content is removed, the remaining positive-area source page is clipped, and it is then fitted uniformly into the output content rectangle without distortion. Crop values are measured from each page's effective CropBox, falling back to MediaBox, and are interpreted as visual edges after rotation. Physical option values require an explicit `mm`, `in`, or `pt` suffix.

Help returns status `0`. Invalid flags, missing option values, missing paths, extra positional paths, incomplete cover options, and oversized paths return status `2` and print a diagnostic followed by the canonical usage line to standard error. Input-PDF failures return `3`; impossible layouts return `4`; output/filesystem or SVG-rendering failures return `5`; unexpected processing failures return `10`. Status `6` is reserved for missing/unusable runtime dependencies by the interface contract, but is not currently returned by the application; loader failures occur before its error handling.

### Output replacement and safety

Existing destination files are replaced without prompting after successful generation; there is no overwrite switch. The folio and cover output paths must be distinct. The input PDF and source SVG paths must not also be destinations. Path checks resolve relative components and symbolic links, but do not identify distinct hard links to the same file.

Outputs are written to sibling files named `DESTINATION.ezbind.tmp` before replacement. Do not use these names for source files or other data, or run concurrent invocations targeting the same destination. Temporary-file ownership is not yet hardened.

Combined output is not transactional: the cover is committed first, then the folio. A later folio-commit failure can leave a replaced cover even though the command returns an error. Generation failures before commit leave existing destinations unchanged; a nonzero exit status does not guarantee that neither output changed.

Success messages identify written destinations on standard output; errors and usage diagnostics go to standard error. Ordinary diagnostics do not print extracted document text or complete PDF content.

### Examples

Create an A4 folio with a 12 mm spine margin:

```sh
ezbind --sheet a4 --margin-spine 12mm book.pdf bound.pdf
```

Generate a folio and a separate cover sheet:

```sh
ezbind --sheet a4 --cover-back back.svg --cover-front front.svg \
  --cover-output covers.pdf book.pdf bound.pdf
```

Generate only a cover sheet:

```sh
ezbind --cover-back back.svg --cover-front front.svg --cover-output covers.pdf
```

Use `--` before positional filenames that begin with a dash:

```sh
ezbind --sheet a4 -- -book.pdf -bound.pdf
```

**Migration:** `-o`/`--output` and `-f`/`--force` were removed, with no compatibility aliases. Replace `ezbind book.pdf -o bound.pdf --force` with `ezbind book.pdf bound.pdf`. All destinations are now replaced without prompting.

### Printing and binding

Print the folio duplex, confirm orientation with a small asymmetric sample, fold each sheet toward the spine, then keep the generated folio order when stacking. Print covers separately on matching cardstock and cut along the dashed center guide. See [`ezbind(1)`](doc/ezbind.1) for the full physical workflow.

The current slice does not yet expose auto-crop, spine/fabric guides, crop/fold/registration marks, creep compensation, safe-area configuration, capability reporting, or full feature-preservation controls. Source cropping applies to imported page content; annotation and form-field transformation remains subject to backend limitations. Validate representative output before physical binding.

## B2 verification

Run the CLI regression suite from the repository root after building:

```sh
python3 tests/test_cli.py
```

It requires Python 3 and the built executable, creates its own fixtures in temporary directories, and does not modify user PDFs. Set `EZBIND_BIN=/absolute/path/to/ezbind` to test another executable. A missing executable skips the suite, so a skipped run is not verification.

The nested test executable runs Ada core checks and, when supplied a source PDF, the qpdf bridge smoke test:

```text
(cd tests && alr build --development)
./tests/bin/ezbind_tests source.pdf /tmp/ezbind-b1-output.pdf
qpdf --check /tmp/ezbind-b1-output.pdf
```

The B2 execution record is [`tests/b2-test-description.md`](tests/b2-test-description.md). Historical CLI results are preserved with a supersession note. The 2026-10-24 verification section records the new positional interface and unconditional-overwrite checks. Run the executable-level regression suite with `python3 tests/test_cli.py` after building.

## Controlled project structure

- `plan/` — project plan, configuration status, and corrective-action records
- `requirements/` — operational concept and accepted requirements
- `design/` — accepted architecture and backend rationale
- `src/` — Ada and native bridge source
- `doc/` — command documentation, including `ezbind(1)`
- `tests/` — Alire test crate, test plans, procedures, and results
- `sdfs/` — project and component development logs

The project process, gates, risks, and traceability are documented in [`plan/project-plan.md`](plan/project-plan.md).
