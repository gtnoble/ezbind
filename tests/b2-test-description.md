# ezbind B2 Test Description

**Project:** EZBIND  
**Document:** B2 Test Description  
**Identifier:** EZBIND-B2-TD-001  
**Status:** B2 implementation-slice execution record  
**Date:** 2026-09-21  
**Revision:** 1.0

## Scope

This record covers the implemented B2 slice: CLI parsing, qpdf input validation, two-sided folded-folio output, blank padding, Letter/A4 selection, optional vector grid, separate SVG cover-card output, temporary-output cleanup, and overwrite control. It does not claim completion of the full B2 requirements set.

## Environment

- Linux host.
- Alire 2.1.0 with Alire-selected GNAT native 15.2.1.
- qpdf 11.9.0, librsvg 2.58.0, Cairo 1.18.0, and development headers.
- `qpdf --check`, `pdfinfo`, `pdftotext`, `pdftoppm`, and GNU roff tools.
- Sequential root and nested Alire development builds.

## Executed cases

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
| TEST-BUILD-001 | Build root and nested test crates sequentially; run Ada/qpdf/librsvg smoke tests. | Both builds pass; core, qpdf, and SVG bridge tests pass; outputs pass `qpdf --check`. **Pass.** |

## Deferred cases

Spine/fabric guides, crop/fold/registration marks, creep, safe-area configuration, broad PDF feature preservation, encrypted-input policy, capability reporting, deterministic metadata, and physical duplex acceptance remain deferred or incomplete in this implementation slice. SVG compatibility beyond librsvg's supported static SVG subset and font/resource portability remain subject to artwork-specific validation.

## Independence limitation

The developer executed and evaluated these tests, so independent acceptance-test authority is unavailable. The user should independently review representative output and the physical duplex/fold behavior before treating the product as ready for binding work.
