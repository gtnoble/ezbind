# ezbind

`ezbind` is an Ada command-line application for preparing ebook PDFs for a modified DFA home-bookbinding process. It arranges single-sheet folios for duplex printing, folding toward the spine, stacking, and gluing into a text block.

## Project status

The project remains in **Build B2 implementation and targeted verification**. The `text` and `cover` commands are implemented. CHG-015 targeted implementation verification is complete; broader B2 acceptance and independent physical duplex/fold review remain pending. The wider option set in the requirements remains staged work.

## Build with Alire

The project uses the canonical Alire executable-crate workflow. The native PDF bridges require qpdf and librsvg/Cairo development headers/libraries plus a C++17 compiler.

```text
alr build --development
(cd tests && alr build --development)
```

Builds should be run sequentially because the nested test crate pins the root crate and both projects may share generated root build state.

The tested native environment is Linux with qpdf 11.9.0, Alire 2.1.0, and Alire-selected GNAT native 15.2.1.

## Commands

```text
ezbind text [OPTIONS] INPUT.pdf OUTPUT.pdf
ezbind cover [OPTIONS] --front FRONT.svg --back BACK.svg OUTPUT.pdf
ezbind --help
```

`text` produces only the imposed folio PDF. `cover` produces only the separate cardstock cover PDF. Use two separate invocations when both are needed. There is no combined mode and no compatibility alias for the former `--cover-front`, `--cover-back`, or `--cover-output` spelling. Top-level help lists commands; `ezbind text --help` and `ezbind cover --help` show command-specific help. Help works on its own.

The `text` command’s second positional path, `OUTPUT.pdf`, is its folio output path. For example: `ezbind text --sheet a4 book.pdf bound.pdf`.

Implemented command options:

- `-s letter|a4`, `--sheet letter|a4` — select the physical output sheet; Letter is the default.
- `-g`, `--grid` — add light-gray vector lines in all configured margin areas, without crossing source content.
- `-G VALUE`, `--grid-spacing VALUE` — set positive grid spacing using a physical value with `mm`, `in`, or `pt` suffix; the default is 5 mm.
- `--crop-top VALUE`, `--crop-bottom VALUE`, `--crop-left VALUE`, `--crop-right VALUE` — remove source-page edge distances using `mm`, `in`, or `pt`; values are measured from the effective CropBox, falling back to MediaBox, and default to zero. Edges are visual page edges after rotation.
- `-t VALUE`, `--margin-top VALUE`; `-b VALUE`, `--margin-bottom VALUE`; `-e VALUE`, `--margin-fore-edge VALUE`; `-i VALUE`, `--margin-spine VALUE` — set independent output margins using `mm`, `in`, or `pt`; defaults are zero for all four margins.
- `--front PATH` and `--back PATH` — required SVG artwork paths for `cover`; cover output is the final positional path.
- `-h`, `--help` — print help without requiring an input PDF.

`text` requires exactly two positional paths (`INPUT.pdf OUTPUT.pdf`); `cover` requires the artwork flags and exactly one positional `OUTPUT.pdf`. Both accept interspersed options and `--` to end option parsing. Prefer placing options first. Supply option values as separate arguments (`--sheet a4`, not `--sheet=a4`); attached short values and grouped short flags are not supported. Text-only options are rejected by cover; artwork options are rejected by text.

The cover command writes one landscape Letter or A4 cardstock sheet. The back-cover SVG is rendered on the left half and the front-cover SVG on the right half, so the center cut puts both cut edges toward the spine. A dashed gray center cut guide is printed over the artwork, inset 12 pt from the top and bottom edges. Artwork is rendered proportionally to fit its half-sheet viewport; matching the SVG aspect ratio to the selected card size is recommended. Each invocation has one output. The text input or cover artwork files must not be the same destination in that invocation.

Normal output uses a landscape Letter or A4 sheet with two finished-page rectangles. The nominal folio assignment is front-left 4, front-right 1, back-left 2, and back-right 3. Page counts are padded to a multiple of four with blank logical pages. Default output margins are zero on all four edges. Source crop options are independent: the requested edge content is removed, the remaining positive-area source page is clipped, and it is then fitted uniformly into the output content rectangle without distortion. Crop values are measured from each page's effective CropBox, falling back to MediaBox, and are interpreted as visual edges after rotation. Physical option values require an explicit `mm`, `in`, or `pt` suffix.

Help returns status `0`. Invalid flags, missing option values, missing paths, extra positional paths, incomplete cover options, command/option mismatches, and oversized paths return status `2` and print a diagnostic followed by the applicable command usage to standard error. Input-PDF failures return `3`; impossible layouts return `4`; output/filesystem or SVG-rendering failures return `5`; unexpected processing failures return `10`. Status `6` is reserved for missing/unusable runtime dependencies by the interface contract, but is not currently returned by the application; loader failures occur before its error handling.

### Output replacement and safety

Each command replaces its existing destination without prompting only after successful generation; there is no overwrite switch. Same-invocation source/destination collisions are rejected. Separate invocations cannot check cross-invocation path collisions together.

Outputs are written to sibling files named `DESTINATION.ezbind.tmp` before replacement. Do not use these names for source files or other data, or run concurrent invocations targeting the same destination. Temporary-file ownership is not yet hardened.

Each command commits its one output only after successful generation. If both outputs are desired, run two commands; they are independent, cannot check cross-invocation path collisions together, and do not form a transaction. One command’s success or failure makes no claim about the other command’s destination.

Success messages identify written destinations on standard output; errors and usage diagnostics go to standard error. Ordinary diagnostics do not print extracted document text or complete PDF content.

### Examples

Create an A4 folio with a 12 mm spine margin:

```sh
ezbind text --sheet a4 --margin-spine 12mm book.pdf bound.pdf
```

Generate a separate cover sheet (run the text command separately if a folio is also needed):

```sh
ezbind cover --sheet a4 --back back.svg --front front.svg covers.pdf
```

Generate only a cover sheet:

```sh
ezbind cover --back back.svg --front front.svg covers.pdf
```

Use `--` before positional filenames that begin with a dash:

```sh
ezbind text --sheet a4 -- -book.pdf -bound.pdf
```

**Migration:** the former combined and `--cover-*` syntax is removed without compatibility aliases. Replace a combined invocation with two commands, for example `ezbind text book.pdf bound.pdf` and `ezbind cover --front front.svg --back back.svg covers.pdf`. Each destination is replaced only after its own command succeeds.

### Printing and binding

Print the folio duplex, confirm orientation with a small asymmetric sample, fold each sheet toward the spine, then keep the generated folio order when stacking. Print covers separately on matching cardstock and cut along the dashed center guide. See [`ezbind(1)`](doc/ezbind.1) for the full physical workflow.

The current slice does not yet expose auto-crop, spine/fabric guides, crop/fold/registration marks, creep compensation, safe-area configuration, capability reporting, or full feature-preservation controls. Source cropping applies to imported page content; annotation and form-field transformation remains subject to backend limitations. Validate representative output before physical binding.

## B2 verification

The targeted CHG-015 CLI regression suite was executed from the repository root after building; see the dated evidence in the B2 Test Description. To repeat it:

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

The B2 execution record is [`tests/b2-test-description.md`](tests/b2-test-description.md). Historical CLI results are preserved with supersession notes. The CHG-015 section records targeted implementation verification of the `text`/`cover` split; earlier results do not verify this interface. This does not complete broader B2 acceptance. Independent user review and physical duplex/fold qualification remain pending.

## Controlled project structure

- `plan/` — project plan, configuration status, and corrective-action records
- `requirements/` — operational concept and accepted requirements
- `design/` — accepted architecture and backend rationale
- `src/` — Ada and native bridge source
- `doc/` — command documentation, including `ezbind(1)`
- `tests/` — Alire test crate, test plans, procedures, and results
- `sdfs/` — project and component development logs

The project process, gates, risks, and traceability are documented in [`plan/project-plan.md`](plan/project-plan.md).
