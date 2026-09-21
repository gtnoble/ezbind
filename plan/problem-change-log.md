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
| BUG-001 | 2026-09-21 | Code, Test | 2 — Serious | B1 qpdf smoke test aborted because Ada represented 64-bit native bridge pointers as 32-bit C integers. | `src/ezbind_qpdf_bridge.ads`; POC-001 | Use address-sized opaque handles, make destination pages indirect, rebuild and rerun qpdf validation. | Handle representation corrected; clean sequential builds and text-bearing smoke test pass. | resolved | 2026-09-21 |

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

## Trend notes

No trend data is available at initialization. Review at each joint review.
