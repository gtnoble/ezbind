# ezbind Test Plan

**Project:** EZBIND
**Document:** Software Test Plan (STP)
**Identifier:** EZBIND-STP-001
**Status:** B2 implementation-slice test plan and B1/B2 results reference
**Date:** 2026-09-21
**Revision:** 1.1

## 1. Scope

This plan covers unit, integration, component acceptance, and conditional system acceptance testing for `EZBIND-CLI` and its generated PDF output. It is aligned with client-controlled `requirements/requirements-spec.md` Revision 1.1. B1 results are recorded in `tests/b1-test-description.md`; B2 implementation-slice results are recorded in `tests/b2-test-description.md`; complete acceptance remains planned after the slice review.

## 2. Referenced documents

- `plan/project-plan.md`, EZBIND-SDP-001, Revision 1.1.
- `requirements/operational-concept.md`, EZBIND-OCD-001, Revision 1.0.
- `requirements/requirements-spec.md`, EZBIND-SRS-001, Revision 1.1.

## 3. Test environment

The test environment will use the selected Alire/GNAT toolchain, the selected Ada test harness, controlled synthetic PDF fixtures, representative user-supplied PDFs where available, and local PDF inspection/rendering tools. Tool versions, backend dependencies, platform, and deviations will be recorded in each Test Report.

The physical acceptance environment will include a duplex-capable printer, the selected paper size, a printed four/eight-page synthetic fixture, and a method for checking page sequence, fold direction, stacking order, and guide/margin placement.

## 4. Test identification and planned coverage

| Group | Purpose | Requirements |
|---|---|---|
| TEST-GEO | Verify units, dimensions, source crop fit, margins, reserves, fit, and grid rectangles. | REQ-CAP-003..004, 013..019, 022, 027; REQ-DATA-001; REQ-ENV-004 |
| TEST-IMP | Verify page order, padding, side/position assignment, orientation, and fold sequence. | REQ-CAP-005..007; REQ-DATA-002; REQ-PHY-003 |
| TEST-PDF | Verify input handling, page descriptors, CropBox/MediaBox fallback, clipping, rotation/UserUnit, output validity, visible preservation, metadata, and feature limitations. | REQ-CAP-002, 008..009, 027; REQ-PDF-001..003; REQ-QUAL-003 |
| TEST-CLI | Verify options, defaults, help, canonical usage, invalid flags, diagnostics, exit statuses, cover/guide/mark behavior, and overwrite policy. | REQ-CAP-010..013, 020..021, 023..026; REQ-CLI-001..009 |
| TEST-COVER | Verify SVG cover rendering, sheet dimensions, back/front placement, center cut-guide appearance, and cover-only/combined output lifecycle. | REQ-CAP-025..026; REQ-CLI-001..009 |
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

The requirement-to-test-group matrix is maintained in `requirements/requirements-spec.md`, Section 5.1. `TEST-DOC` covers the man-page and usage-documentation requirements. Detailed cases will use `TEST-*` identifiers and trace to individual `REQ-*` identifiers before the Test Readiness Review.

## 10. Notes

This document is the active test-plan baseline for B2 implementation-slice planning. B1 and B2 implementation-slice results are recorded in their respective Test Descriptions; a separate acceptance Test Report remains planned after test readiness.
