# ezbind Configuration Status

**Project:** EZBIND
**Status:** Client-acknowledged baseline; B2 implementation slice under project control
**Date:** 2026-10-24

| Configuration item | Identifier | Revision/status | Control level | Notes |
|---|---|---|---|---|
| Project Plan | EZBIND-SDP-001 | Rev 1.1 baseline | Client | User change request accepted 2026-09-21 |
| Problem/Change Log | EZBIND-PCL-001 | Initial | Project | Active |
| Configuration Status | EZBIND-CS-001 | Initial | Project | Active |
| Project Development Log | EZBIND-SDF-001 | Initial | Project | Active |
| Requirements Specification | EZBIND-SRS-001 | Rev 1.2 project update | Project | CHG-013 records user-approved positional paths and replacement policy; targeted verification passed |
| Design Description | EZBIND-SDD-001 | Rev 1.1 project update | Project | CHG-013 documents revised CLI, path normalization, and Unix replacement rename |
| Source code | EZBIND-CLI | B2 positional CLI increment | Project | Removed output/force switches, added positional paths and unconditional replacement; root/nested builds pass |
| Test products | EZBIND-TEST | B2 TD Rev 1.1 | Project | 15 CLI regressions, core/native bridge tests, and Letter/A4 replacement/qpdf checks pass; physical acceptance pending |

## Control rules

- Draft artifacts are under author control until committed and reviewed.
- Committed artifacts are project-level controlled.
- User-acknowledged plans/specifications are client-controlled.
- Changes to client-controlled artifacts require an entry in the Problem/Change Log and user agreement before editing.
