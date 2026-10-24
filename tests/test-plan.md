# ezbind Test Plan

**Project:** EZBIND
**Document:** Software Test Plan (STP)
**Identifier:** EZBIND-STP-001
**Status:** B2 implementation-slice plan; CHG-015 targeted verification complete; broader acceptance pending
**Date:** 2026-10-24 (project update)
**Revision:** 1.2

## 1. Scope

This plan covers unit, integration, component acceptance, and conditional system acceptance testing for `EZBIND-CLI` and its generated PDF output. It is aligned with the CHG-015 project update to `requirements/requirements-spec.md` Revision 1.3; targeted implementation verification of the split interface is recorded in the B2 Test Description. B1 and prior B2 results remain historical records; broader acceptance remains planned after the slice review.

## 2. Referenced documents

- `plan/project-plan.md`, EZBIND-SDP-001, Revision 1.1.
- `requirements/operational-concept.md`, EZBIND-OCD-001, Revision 1.1 project update.
- `requirements/requirements-spec.md`, EZBIND-SRS-001, Revision 1.3 project update.

## 3. Test environment

The test environment will use the selected Alire/GNAT toolchain, the selected Ada test harness, controlled synthetic PDF fixtures, representative user-supplied PDFs where available, and local PDF inspection/rendering tools. Tool versions, backend dependencies, platform, and deviations will be recorded in each Test Report.

The physical acceptance environment will include a duplex-capable printer, the selected paper size, a printed four/eight-page synthetic fixture, and a method for checking page sequence, fold direction, stacking order, and guide/margin placement.

## 4. Test identification and planned coverage

| Group | Purpose | Requirements |
|---|---|---|
| TEST-GEO | Verify units, dimensions, source crop fit, margins, reserves, fit, and grid rectangles. | REQ-CAP-003..004, 013..019, 022, 027; REQ-DATA-001; REQ-ENV-004 |
| TEST-IMP | Verify page order, padding, side/position assignment, orientation, and fold sequence. | REQ-CAP-005..007; REQ-DATA-002; REQ-PHY-003 |
| TEST-PDF | Verify input handling, page descriptors, CropBox/MediaBox fallback, clipping, rotation/UserUnit, output validity, visible preservation, metadata, and feature limitations. | REQ-CAP-002, 008..009, 027; REQ-PDF-001..003; REQ-QUAL-003 |
| TEST-CLI | Verify top-level and command-specific help; text/cover dispatch and arity; shared `--sheet`/`-s`, `--`, and interspersed options; rejection of text-only flags in cover and artwork flags in text; retired combined and `--cover-*` syntax; source/destination collisions; single-output replacement only after success. | REQ-CAP-001, 010..013, 020..021, 023..026; REQ-CLI-001..012 |
| TEST-COVER | Verify cover rendering, shared sheet geometry, back/front placement, center cut guide, absence of text-input/layout validation, one-output lifecycle, and independent two-command workflow limits. | REQ-CAP-025..026; REQ-CLI-001..009 |
| TEST-DOC | Verify `ezbind(1)` presence, required content, installation metadata, and correspondence with the executable interface. | REQ-DOC-001..003 |
| TEST-SEC | Verify local-only processing, temporary-file policy, and content-free ordinary diagnostics. | REQ-ENV-002..003; REQ-QUAL-004 |
| TEST-PHY | Verify printed duplex orientation, sequence, fold direction, stack order, and physical guides. | REQ-CAP-006, 012, 017; REQ-PHY-001..003 |
| TEST-BUILD | Verify Ada implementation, reproducible build instructions, and controlled artifacts. | REQ-QUAL-001..002, 005; REQ-ENV-001 |

## 5. Test classes

- normal functional tests;
- boundary and invalid-parameter tests;
- geometry/property tests;
- malformed, empty, encrypted, and unsupported-input tests;
- visual/rendering regression tests;
- deterministic-output tests;
- filesystem and overwrite tests;
- documentation and man-page consistency tests;
- privacy and diagnostic inspection;
- physical print/fold demonstration.

## 6. Progression criteria

Unit testing may proceed when a unit has a reviewed detailed design. Integration testing requires passing unit tests for participating units. Component acceptance requires integrated software, a reviewed Test Description, and a verified test environment. Release acceptance requires no unresolved Priority 1 or Priority 2 defects affecting required capabilities and documented disposition of all lower-priority issues.

## 7. Test schedule and products

- B1: geometry, imposition, and initial qpdf proof of concept — completed for the recorded slice.
- B2: implementation-slice CLI/PDF/integration tests and documentation synchronization — executed; broader option coverage and test-readiness remain active.
- B3: regression, portability, packaging, and release-hardening tests.

The Test Description will specify exact cases and procedures. The Test Report will record actual results, deviations, and problem/change IDs.

## 8. Independence and acceptance

The developer is also implementing the product, so full test independence is unavailable for self-evaluation, QA, and acceptance preparation. This limitation will be stated in each evaluation and Test Report. The user will be invited to witness or independently review the physical and software acceptance results.

## 9. Requirements traceability

The requirement-to-test-group matrix is maintained in `requirements/requirements-spec.md`, Section 5.1. `TEST-DOC` covers the command man-page and usage documentation. CHG-015 split-command executable cases trace to REQ-CAP-001/023/025/026 and REQ-CLI-001/002/006..008 and their targeted implementation results are recorded in the B2 Test Description. Broader acceptance execution remains pending.

## 10. Notes

This is the Revision 1.3 project update to the B2 test plan, dated 2026-10-24. Historical B1/B2 execution records are preserved and do not verify CHG-015. Targeted split-command results are recorded in the B2 Test Description. Broader B2/component acceptance and physical duplex/fold review remain pending; a separate acceptance Test Report remains planned after test readiness.
