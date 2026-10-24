# ezbind B2 Test Description

**Project:** EZBIND  
**Document:** B2 Test Description  
**Identifier:** EZBIND-B2-TD-001  
**Status:** B2 implementation-slice execution record; CHG-015 targeted verification complete, broader acceptance pending
**Date:** 2026-10-24
**Revision:** 1.3

## Scope

This record covers the implemented B2 slice: CLI parsing, qpdf input validation, two-sided folded-folio output, blank padding, Letter/A4 selection, optional vector grid, separate SVG cover-card output, temporary-output cleanup, and overwrite control. It does not claim completion of the full B2 requirements set.

## Environment

- Linux host.
- Alire 2.1.0 with Alire-selected GNAT native 15.2.1.
- qpdf 11.9.0, librsvg 2.58.0, Cairo 1.18.0, and development headers.
- `qpdf --check`, `pdfinfo`, `pdftotext`, `pdftoppm`, and GNU roff tools.
- Sequential root and nested Alire development builds.

## Historical executed cases

These cases describe the interface before the 2026-10-24 CHG-013 update. Later results document that intervening interface, now also superseded by CHG-015; neither historical result set verifies the authorized split. Old output/force flags were removed by CHG-013.

| ID | Procedure | Expected/result |
|---|---|---|
| TEST-CLI-001 | Run `./bin/ezbind --help`. | Status 0; canonical usage is first line; option/status summary follows. **Pass.** |
| TEST-CLI-002 | Run an unknown flag and an invocation missing `--output`. | Status 2; diagnostic and canonical usage go to standard error; no output is created. **Pass.** |
| TEST-CLI-003 | Supply a positional path longer than the bounded parser storage. | Status 2; content-free usage diagnostic; no output. **Pass.** |
| TEST-PDF-001 | Run one-page input with `--output`. | Status 0; two landscape Letter output pages; `qpdf --check` passes; text extraction remains available. **Pass.** |
| TEST-PDF-006 | Run qpdf bridge descriptor and clipped-placement smoke checks. | Effective CropBox geometry is returned; zero and nonzero visual crop margins produce valid output; selectable text remains available. **Pass.** |
| TEST-PDF-002 | Run malformed input. | Status 3; no output and no sibling temporary file. **Pass.** |
| TEST-IMP-001 | Run a five-page synthetic PDF. | Four output sides after padding to eight logical positions. **Pass.** |
| TEST-GEO-001 | Run five-page input with `--sheet a4 --grid`. | Four A4 output sides; `qpdf --check` passes; vector grid path is emitted. **Pass.** |
| TEST-GEO-000 | Run the Ada geometry core check with zero margins. | The resulting left and right content rectangles equal their respective finished-page rectangles. **Pass.** |
| TEST-GEO-002 | Run with independent margin options using `mm`, `in`, and `pt` values and a custom grid spacing. | Status 0; output remains valid and the selected values affect the layout. Invalid, negative, zero-spacing, or unitless values return status 2 without output. **Pass.** |
| TEST-GEO-003 | Use asymmetric margins and inspect source placement/grid regions. | Spine clearance is on each fold-facing inner edge; fore-edge clearance is outer; source placement is uniformly fitted inside custom content rectangles and grid lines do not cross them. **Pass.** |
| TEST-GEO-004 | Use `--crop-top`, `--crop-bottom`, `--crop-left`, and `--crop-right` with physical values. | Source crop values are parsed independently from output margins, applied before uniform fit, and crop margins that leave no positive-area page return status 4 without output. **Pass.** |
| TEST-CLI-004 | Run with an existing output, then with `--force`. | Without force status 5 and target unchanged; with force status 0 and replacement passes `qpdf --check`. **Pass.** |
| TEST-CLI-005 | Run the equivalent output, sheet, grid, grid-spacing, margin, and force invocations using `-o`, `-s`, `-g`, `-G`, `-t`, `-b`, `-e`, `-i`, and `-f`. | Each short alias has the same behavior and output validity as its long option. **Pass.** |
| TEST-COVER-001 | Generate Letter covers from asymmetric back/front SVG fixtures. | Status 0; separate cover PDF has one 792 × 612 pt page; qpdf validation and `BACK`/`FRONT` text extraction pass; rendered colors show back-left/front-right placement. **Pass.** |
| TEST-COVER-002 | Generate A4 covers from the same fixtures. | Status 0; separate cover PDF has one 841.89 × 595.28 pt page; qpdf validation passes. **Pass.** |
| TEST-COVER-003 | Run the nested test executable with SVG fixture paths. | Direct librsvg/Cairo bridge smoke test passes; qpdf smoke test and Ada core tests also pass. **Pass.** |
| TEST-COVER-004 | Supply incomplete cover options, identical folio/cover output paths, and a missing SVG. | Incomplete options and path collision return status 2; missing SVG returns status 5; no misleading output remains. **Pass.** |
| TEST-COVER-005 | Generate cover-only output with a nonexistent text-block PDF path omitted from the command. | Status 0; one-page cover PDF is written and validated without opening a text-block input. **Pass.** |
| TEST-COVER-006 | Render Letter and A4 cover sheets and inspect the vector center cut guide in cover-only and combined workflows. | Letter and A4 cover-only outputs pass; each PDF has the expected page size and passes `qpdf --check`. 72 dpi Letter and A4 rasters show the gray dashed line at the midpoint with 12 pt end insets and visible dash gaps over artwork. Combined A4 folio-plus-cover invocation succeeds and both outputs validate. **Pass.** |
| TEST-BUILD-001 | Build root and nested test crates sequentially; run Ada/qpdf/librsvg smoke tests. | Both builds pass; core, qpdf, and SVG bridge tests pass; outputs pass `qpdf --check`. **Pass.** |

## Deferred cases

Spine/fabric guides, crop/fold/registration marks, creep, safe-area configuration, broad PDF feature preservation, encrypted-input policy, capability reporting, deterministic metadata, and physical duplex acceptance remain deferred or incomplete in this implementation slice. SVG compatibility beyond librsvg's supported static SVG subset and font/resource portability remain subject to artwork-specific validation.

## Historical supersession note — CHG-013 CLI and overwrite policy

The original executed cases are historical records for the interface in effect when executed. Their **Pass** results are preserved. CHG-013 then removed `-o`/`--output` and `-f`/`--force`; its verification is recorded separately below. CHG-015 subsequently supersedes that combined/cover-only interface with explicit `text` and `cover` subcommands. Neither earlier set of passes verifies CHG-015; targeted CHG-015 results are recorded separately below.

## Historical CLI replacement-policy verification (CHG-013) — 2026-10-24

- Root `alr build --development` and nested `(cd tests && alr build --development)` passed, run sequentially. A final root development build restored generated development configuration after the nested build.
- `python3 tests/test_cli.py`: **15 tests passed**. Covers canonical help, positional folio generation, cover-only and combined generation, replacement of existing destinations, retired flags, missing/extra/empty/oversized operands, `--`, interspersed options, normalized and symbolic-link collisions, and unchanged destinations on invalid PDF/SVG generation failures.
- Temporary source PDFs were generated from the checked-in SVG fixtures, with all outputs isolated in temporary directories. Letter and A4 combined invocations with grid and 12 mm spine margin were each executed twice to exercise replacement; all four resulting PDFs passed `qpdf --check`.
- The nested Ada test executable passed core, qpdf input/placement, and librsvg/Cairo cover bridge checks using those temporary fixtures; both bridge outputs passed `qpdf --check`.
- `groff -man -Tutf8 doc/ezbind.1` and `git diff --check` passed.
- This is targeted implementation verification, not full acceptance of the broader B2 requirements. Existing fixed-suffix temporary files and nontransactional two-output commits remain separate hardening work.

## CHG-015 split-command targeted implementation verification — complete

This update is self-evaluated by the implementing developer and is not an independent acceptance evaluation. The user is invited to review the implementation and evidence.

The authorized interface defines `ezbind text [OPTIONS] INPUT.pdf OUTPUT.pdf` and `ezbind cover [OPTIONS] --front FRONT.svg --back BACK.svg OUTPUT.pdf`. The targeted checks covered top-level and command-specific help on their own; `--sheet`/`-s`, interspersed options, and `--`; option ownership and positional arity; rejection of combined mode and old `--cover-*` syntax; cover operation without text input or text-layout validation; per-invocation replacement and normalized collision behavior; and the two-command workflow. The final CLI suite passed **16 test methods**, including assertions requiring the exact selected-command usage line, independent two-command generation, all physical-option parsing, invalid values, and impossible crop/layout preservation.

Sequential root `alr build --development`, nested `(cd tests && alr build --development)`, and final root development build passed. After review identified a usage-output expectation mismatch, the source was corrected, the root rebuilt, and the expanded 16-method CLI suite passed with the strengthened exact-usage assertion.

`/tmp/ezbind-split-integration.py` was executed. It generated source from the checked-in cover SVGs and ran both commands twice each for Letter and A4, using the text grid, 5 mm spacing, 12 mm spine margin, and 1 mm top source crop. Checks confirmed one cover page and two text sides, exact Letter/A4 geometry, BACK/FRONT extraction, and `qpdf --check` success for all outputs. Nested executable core, qpdf, and librsvg bridge smoke tests passed; both native bridge outputs passed qpdf validation. No sibling temporary file remained. Source inspection confirmed the cover producer has no text-layout validation or qpdf input path.

`groff -man -Tutf8 doc/ezbind.1` and `git diff --check` passed.

This is targeted implementation verification, not broader B2 acceptance. Each command commits one output; separate invocations are not transactional and no transaction guarantee is made. Historical results above remain intact and apply only to their interfaces. Independent acceptance and physical duplex/fold review remain pending.

## Independence limitation

The developer executed and evaluated these tests, so independent acceptance-test authority is unavailable. The user should independently review representative output and the physical duplex/fold behavior before treating the product as ready for binding work.
