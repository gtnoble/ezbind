# ezbind Problem/Change Log

**Project:** EZBIND
**Status:** Active
**Date opened:** 2026-09-21

Every entry must include a category and one priority. Categories: Plans, Concept, Requirements, Design, Code, Database/data file, Test, Manuals, Other. Priorities: 1 Critical, 2 Serious, 3 Moderate, 4 Minor, 5 Negligible.

| ID | Date | Category | Priority | Description | Affected product/version | Corrective action | Actions to date | Status | Date resolved |
|---|---|---|---|---|---|---|---|---|---|
| CHG-001 | 2026-09-21 | Plans, Concept, Requirements | 3 — Moderate | User accepted the proposed resolutions for all B0 open-decision items and authorized advancement from planning to requirements analysis. | EZBIND-SDP-001 Rev 1.0; EZBIND-OCD-001 Rev 1.0; EZBIND-SRS-001 Rev 1.0 draft | Record acceptance, update baseline status, and create requirements products. | Acceptance recorded; controlled artifacts updated; requirements review package drafted. | resolved | 2026-09-21 |
| CHG-002 | 2026-09-21 | Requirements, Manuals, Test | 3 — Moderate | User requested man-page documentation and a canonical usage statement for help and invalid-flag invocations. | EZBIND-SRS-001 Rev 1.1 draft; EZBIND-STP-001 Rev 1.1 draft; EZBIND-SDP-001 Rev 1.1 | Add `ezbind(1)`, define help/invalid-flag behavior, update traceability and deliverable records. | Requirements and test-plan drafts updated; plan deliverable list and canonical usage contract updated. | resolved | 2026-09-21 |
| CHG-003 | 2026-09-21 | Requirements, Design | 3 — Moderate | User accepted the complete requirements baseline and authorized transition to design. | EZBIND-SRS-001 Rev 1.1; EZBIND-SDP-001 Rev 1.1 | Record requirements acceptance, advance configuration control, and produce the Design Description. | SRS marked client-controlled; Design Description accepted and source work authorized. | resolved | 2026-09-21 |
| CHG-004 | 2026-09-21 | Design, Code, Other | 4 — Minor | B1 implementation adopts canonical Alire executable naming (`Ezbind`) and flattened Ada package names (`Ezbind_*`) because Ada executable and parent-package units cannot share the same root unit. Generated Alire configuration is restored to Alire ownership. | EZBIND-SDD-001 Rev 1.0; `alire.toml`; `ezbind.gpr`; `config/` | Record the implementation mapping and use the canonical Alire-generated project structure. | Design unit references synchronized; Alire metadata/build-switches added; generated config restored; root and test builds pass. | resolved | 2026-09-21 |
| CHG-005 | 2026-09-21 | Plans, Design, Test, Manuals | 4 — Minor | Documentation no longer matched the B1 implementation status, canonical Alire workflow, or actual CLI capability boundary. | README.md; EZBIND-SDP-001 Rev 1.1; EZBIND-SDD-001 Rev 1.0; EZBIND-STP-001 Rev 1.1; EZBIND-B1-TD-001 Rev 1.1; doc/ezbind.1 | Synchronize status, commands, toolchain, POC results, and implemented-versus-planned CLI behavior. | Documentation updated and rendered man page reviewed. | resolved | 2026-09-21 |
| CHG-006 | 2026-09-21 | Code, Test, Manuals | 2 — Serious | B2 implementation work authorized by the existing evolutionary build plan required replacing the B1 CLI-only boundary with validated two-sided folio generation and synchronizing user documentation. | EZBIND-CLI B2 implementation slice; `README.md`; `doc/ezbind.1`; `tests/b2-test-description.md` | Implement the staged B2 slice without changing the client-controlled requirements/design baselines; execute CLI, PDF, geometry, padding, overwrite, and build checks. | Application orchestration, explicit qpdf destination-page lifecycle, accepted folio order, Letter/A4 selection, grid option, temporary output commit, and bounded path parsing implemented. Tests recorded in B2 Test Description; documentation synchronization completed in the current update. | resolved | 2026-09-21 |
| BUG-001 | 2026-09-21 | Code, Test | 2 — Serious | B1 qpdf smoke test aborted because Ada represented 64-bit native bridge pointers as 32-bit C integers. | `src/ezbind_qpdf_bridge.ads`; POC-001 | Use address-sized opaque handles, make destination pages indirect, rebuild and rerun qpdf validation. | Handle representation corrected; clean sequential builds and text-bearing smoke test pass. | resolved | 2026-09-21 |
| CHG-007 | 2026-09-21 | Code, Test, Manuals | 3 — Moderate | The next controlled B2 increment required exposing independent top, bottom, fore-edge, and spine margins plus configurable positive grid spacing with explicit physical units. | EZBIND-CLI B2 implementation slice; `README.md`; `doc/ezbind.1`; `tests/b2-test-description.md` | Add bounded `mm`, `in`, and `pt` parsing, connect the values to geometry/grid generation, reject invalid values before output creation, and synchronize user documentation. | `Ezbind_Physical.Parse` and CLI options implemented; expanded Ada tests, valid custom-margin generation, invalid-option checks, qpdf validation, text preservation, and man-page rendering pass. | resolved | 2026-09-21 |
| CHG-008 | 2026-09-21 | Code, Test, Manuals | 3 — Moderate | The user clarified that margins must surround a uniformly scaled source page without distortion and that the spine margin belongs on the fold-facing inner edge. | `src/ezbind_geometry.adb`; `src/ezbind_imposition.adb`; `src/ezbind_application.adb`; user documentation | Place source pages in margin-bounded content rectangles, preserve aspect ratio through qpdf fit behavior, correct inner/outer edge geometry, and confine grid lines to all reserved strips. | Implementation and geometry assertions updated; documentation synchronized; root and nested builds pass; qpdf validity, output dimensions, text preservation, CLI help, man-page rendering, and emitted grid-coordinate checks pass. | resolved | 2026-09-21 |
| CHG-009 | 2026-09-22 | Requirements, Design, Code, Test, Manuals | 3 — Moderate | The user requested functional cover-card PDF generation from separate front/back SVG artwork using the newly installed librsvg development package. | `REQ-CAP-025`; `src/ezbind_application.adb`; `src/ezbind_svg_bridge.*`; `src/ez_svg_bridge.*`; `ezbind.gpr`; README; `doc/ezbind.1`; B2 test records | Add paired cover SVG CLI options and a separate cover-output path; render directly with librsvg/Cairo onto a landscape sheet with back-left/front-right placement; validate atomic output, path pairing, SVG failures, Letter/A4 geometry, and qpdf validity; synchronize controlled documentation. | Implemented direct native bridge, CLI/application lifecycle, fixtures, integration smoke test, public documentation, requirements/design traceability, and B2 execution cases. Root and nested builds, Letter/A4 generation, qpdf checks, text extraction, path collision, missing SVG, and direct bridge tests pass. | resolved | 2026-09-22 |

| CHG-013 | 2026-10-24 | Requirements, Concept, Design, Code, Test, Manuals | 3 — Moderate | User approved two positional folio paths, removal of output/force switches, and unconditional destination replacement after generation. | CLI/application source; tests/test_cli.py; README; man page; OCD/SRS/SDD; B2 test record | Implement the revised CLI, synchronize controlled documentation, and verify replacement and invalid-invocation behavior. | Parser/help and Unix replacement rename implemented; normalized source/destination guards added. Root/nested builds, 15 CLI regressions, core/native bridge tests, Letter/A4 qpdf checks, man rendering, and diff checks pass. Historical results preserved. Fixed-suffix temporary ownership and multi-output rollback remain separate hardening work. | resolved | 2026-10-24 |

| CHG-014 | 2026-10-24 | Manuals, Design, Test | 4 — Minor | Follow-up documentation audit found incomplete workflow examples, misleading usage-error ordering, and undocumented current overwrite limits. | README; man page; SDD; SRS/TD headers; development log | Clarify supported syntax, migration, examples, test execution, commit order, dependencies, and reserved status 6; preserve historical outcomes. | Documentation checked against implementation; all four README conversion examples execute successfully in temporary directories and generated PDFs pass qpdf checks; man-page rendering and whitespace checks pass. Historical results preserved. | resolved | 2026-10-24 |

## CHG-001 rationale

The priority is 3 because the change affects project scope and baseline status but has a known, controlled resolution and does not block the accepted capability.

## CHG-002 rationale

The priority is 3 because the change adds acceptance-relevant documentation and command-line behavior, but it has a defined implementation and test approach.

## CHG-003 rationale

The priority is 3 because requirements acceptance enables the planned design activity and has a controlled transition path; no required capability is impaired.

## CHG-003 resolution

The Design Description was produced, independently reviewed for feasibility, accepted by the user, and advanced to client control. B1 source creation is authorized.

## BUG-001 resolution rationale

The initial POC failure could prevent the essential PDF capability, so it was Priority 2. The resolution was isolated, verified by rebuild and independent PDF checks, and did not require a requirements change.

## CHG-004 rationale

This is a minor implementation/documentation clarification with no user-visible requirement change. It preserves the accepted architecture while following the canonical Alire executable layout.

## CHG-005 rationale

This is a minor documentation synchronization change. It corrects user-facing status and capability claims without changing software requirements or implementation behavior.

## Trend notes

No trend data is available at initialization. Review at each joint review.

| CHG-010 | 2026-09-22 | Requirements, Code, Test, Manuals | 3 — Moderate | Cover-card generation incorrectly required processing a text-block PDF and a folio output path. | `REQ-CAP-026`; `src/ezbind_application.adb`; `src/ezbind_cli.adb`; README; `doc/ezbind.1`; B2 test records | Permit a complete cover-only invocation with front/back SVGs and `--cover-output`; bypass qpdf input processing; retain combined mode and reject incomplete/mixed argument sets. | Cover-only parser and direct render/commit branch implemented; Letter output, qpdf validation, text extraction, temporary-file cleanup, invalid invocations, and combined-mode regression checks pass. | resolved | 2026-09-22 |

| CHG-011 | 2026-09-23 | Requirements, Design, Code, Test, Manuals | 3 — Moderate | User authorized deterministic per-edge source cropping and explicitly deferred automatic whitespace cropping. | `REQ-CAP-027`; source-crop bridge/application/docs/tests | Add global visual source crop options in physical units, inspect effective CropBox geometry with MediaBox fallback, clip retained Form XObjects before proportional placement, reject impossible retained rectangles before output creation, and document annotation/form limitations. Do not add auto-crop or a renderer dependency. | Implementation and verification completed; root/nested builds and crop regression checks pass. | resolved | 2026-09-23 |

| BUG-002 | 2026-09-23 | Code, Test, Manuals | 4 — Minor | The impossible-crop diagnostic said source crop margins remove page content, which incorrectly suggested that ordinary content removal was invalid. | `src/ezbind_application.adb`; `src/ez_qpdf_bridge.cpp`; README; `doc/ezbind.1`; B2 test record | State that source content removal is valid and reject only crops leaving zero or negative page area; add a positive-area regression check. | Diagnostic and documentation corrected; valid substantial crop and zero-area rejection verified. | resolved | 2026-09-23 |

| CHG-012 | 2026-09-24 | Requirements, Design, Code, Test, Manuals | 4 — Minor | Cover-card PDFs identified the center cut location in instructions but did not print a visible cut guide. | `REQ-CAP-025`; `src/ez_svg_bridge.cpp`; design description; README; `doc/ezbind.1`; test plan and B2 test description | Draw an always-enabled 0.5 pt dashed gray vector guide at the cover-sheet midpoint, inset 12 pt from top/bottom; verify Letter/A4 rendering and synchronize controlled requirements/design with approval. | Renderer, controlled requirements/design, test plan/record, and user documentation updated. Root and nested builds pass; Letter/A4 cover-only PDFs pass qpdf validation; rendered Letter raster confirms the centered dashed line and 12 pt insets; combined folio-plus-cover invocation succeeds. | resolved | 2026-09-24 |
