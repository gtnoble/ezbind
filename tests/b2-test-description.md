# ezbind B2 Test Description

**Project:** EZBIND  
**Document:** B2 Test Description  
**Identifier:** EZBIND-B2-TD-001  
**Status:** B2 implementation-slice execution record  
**Date:** 2026-09-21  
**Revision:** 1.0

## Scope

This record covers the implemented B2 slice: CLI parsing, qpdf input validation, two-sided folded-folio output, blank padding, Letter/A4 selection, optional vector grid, temporary-output cleanup, and overwrite control. It does not claim completion of the full B2 requirements set.

## Environment

- Linux host.
- Alire 2.1.0 with Alire-selected GNAT native 15.2.1.
- qpdf 11.9.0 and qpdf development headers.
- `qpdf --check`, `pdfinfo`, and `pdftotext`.
- Sequential root and nested Alire development builds.

## Executed cases

| ID | Procedure | Expected/result |
|---|---|---|
| TEST-CLI-001 | Run `./bin/ezbind --help`. | Status 0; canonical usage is first line; option/status summary follows. **Pass.** |
| TEST-CLI-002 | Run an unknown flag and an invocation missing `--output`. | Status 2; diagnostic and canonical usage go to standard error; no output is created. **Pass.** |
| TEST-CLI-003 | Supply a positional path longer than the bounded parser storage. | Status 2; content-free usage diagnostic; no output. **Pass.** |
| TEST-PDF-001 | Run one-page input with `--output`. | Status 0; two landscape Letter output pages; `qpdf --check` passes; text extraction remains available. **Pass.** |
| TEST-PDF-002 | Run malformed input. | Status 3; no output and no sibling temporary file. **Pass.** |
| TEST-IMP-001 | Run a five-page synthetic PDF. | Four output sides after padding to eight logical positions. **Pass.** |
| TEST-GEO-001 | Run five-page input with `--sheet a4 --grid`. | Four A4 output sides; `qpdf --check` passes; vector grid path is emitted. **Pass.** |
| TEST-GEO-002 | Run with independent margin options using `mm`, `in`, and `pt` values and a custom grid spacing. | Status 0; output remains valid and the selected values affect the layout. Invalid, negative, zero-spacing, or unitless values return status 2 without output. **Pass.** |
| TEST-GEO-003 | Use asymmetric margins and inspect source placement/grid regions. | Spine clearance is on each fold-facing inner edge; fore-edge clearance is outer; source placement is uniformly fitted inside custom content rectangles and grid lines do not cross them. **Pass.** |
| TEST-CLI-004 | Run with an existing output, then with `--force`. | Without force status 5 and target unchanged; with force status 0 and replacement passes `qpdf --check`. **Pass.** |
| TEST-BUILD-001 | Build root and nested test crates sequentially; run Ada/qpdf smoke tests. | Both builds pass; core and bridge tests pass; output passes `qpdf --check`. **Pass.** |

## Deferred cases

Cover-card pages, spine/fabric guides, crop/fold/registration marks, creep, safe-area configuration, broad PDF feature preservation, encrypted-input policy, capability reporting, deterministic metadata, and physical duplex acceptance remain deferred or incomplete in this implementation slice.

## Independence limitation

The developer executed and evaluated these tests, so independent acceptance-test authority is unavailable. The user should independently review representative output and the physical duplex/fold behavior before treating the product as ready for binding work.
