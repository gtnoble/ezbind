# ezbind Project Plan

**Project:** ezbind — home bookbinding PDF preparation CLI
**Document:** Software Development Plan (SDP)
**Identifier:** EZBIND-SDP-001
**Status:** Client-acknowledged baseline
**Date:** 2026-09-21
**Revision:** 1.1

## 1. Overview

### 1.1 Purpose

ezbind will be an Ada command-line application that accepts an ebook PDF and produces a new PDF arranged for a modified DFA home-bookbinding process. The target physical process prints pages on single-sheet folios, folds the folios with the fold toward the spine, stacks them, glues the spine side into a text block, adds cover cards, and reinforces/hinges the spine with a fabric strip.

### 1.2 Scope

The initial product scope is:

- inspect and validate an input ebook PDF;
- calculate a binding layout from page, sheet, fold, margin, and folio parameters;
- place source pages in the required printed order and orientation;
- support configurable page margins;
- support either blank margins or a graph-paper-like note-taking grid in the margins;
- emit a print-ready output PDF;
- report invalid inputs and layout constraints without silently producing an unsafe or misleading layout;
- provide a command-line interface suitable for local use.

The following are outside the initial scope unless explicitly added through change control: graphical UI, network service, ebook format conversion other than PDF input, printer control, physical fabrication instructions beyond layout metadata, automated cover-art design, and cloud processing.

### 1.3 System type

Software-only system. No hardware-software integration activity is planned. The application operates on user-provided local files and produces local output files.

### 1.4 Governing user brief

The user brief in the initiating conversation is the source of the initial project objectives. The user acknowledged this plan and accepted the proposed resolutions to the Section 13 decision items on 2026-09-21. Requirements analysis is authorized; requirements and design remain subject to their own review gates.

## 2. Referenced documents

- User initiating brief, 2026-09-21.
- `requirements/requirements-spec.md` — client-controlled EZBIND-SRS-001, Revision 1.1, accepted 2026-09-21.
- `design/design-description.md` — client-controlled EZBIND-SDD-001, Revision 1.0, accepted 2026-09-21.
- `tests/test-plan.md` — draft EZBIND-STP-001, Revision 1.1, aligned with the updated requirements review.
- `sdfs/project-development-log.md` — project development log.
- `plan/problem-change-log.md` — corrective-action and change record.
- `plan/configuration-status.md` — configuration status accounting.

## 3. Required work and products

### 3.1 Deliverable software

One operational Ada CLI application, built as a canonical Alire executable crate, with documented command syntax and deterministic PDF output for a given input and parameter set.

### 3.2 Supporting products

- Project Plan (this document).
- Operational concept and Requirements Specification.
- Software Design Description.
- Test Plan, Test Description, and Test Report, consolidated where practical.
- User Manual and Installation/Build instructions when deployment preparation begins.
- Versioned command man-page documentation, initially `ezbind(1)`, including the canonical usage statement.
- Version Description for each release.
- Project and component development logs.
- Problem/change log, configuration status records, review records, and self-evaluation records.

### 3.3 Project components

For the first build, the deliverable is treated as one software component, `EZBIND-CLI`, with logical units for command-line parsing, PDF inspection, binding geometry, imposition, margin-grid rendering, PDF emission, and diagnostics. The accepted architecture maps these responsibilities to the Ada and native bridge units recorded in the Design Description. The B2 implementation slice adds the application orchestration and explicit qpdf destination-page lifecycle.

## 4. Development process and build strategy

### 4.1 Lifecycle

Use an evolutionary, multi-build lifecycle. Requirements will be baselined for the current build, implemented and tested, then reviewed before the next build. Activities may iterate when geometry experiments or output-PDF validation reveal a requirement or design issue.

### 4.2 Planned builds

| Build | Objective | Exit evidence |
|---|---|---|
| B0 — project initialization | Establish process, workspace, toolchain policy, initial brief, and open-decision register. | Acknowledged Project Plan and initialized project library. |
| B1 — geometry and PDF proof of concept | Validate page geometry, folio ordering/orientation, margin modes, and a minimal output PDF on representative fixtures. | Alire builds; Ada core tests; qpdf bridge proof; independent PDF checks. **Completed for the implemented slice.** |
| B2 — usable CLI | Implement the validated CLI and the first usable PDF-imposition slice, then expand the remaining option set through controlled increments. | B2 implementation-slice tests, documentation review, test-readiness review, and user review. **Active; slice implemented.** |
| B3 — release hardening | Improve portability, documentation, regression fixtures, packaging, and known-error handling based on B2 results. | Release evaluation, Version Description, and user acceptance decision. |

Build boundaries are provisional and may be revised only through the change-control process after plan acknowledgement.

### 4.3 Standards and methods

- Requirements use unique identifiers (`REQ-*`) and state verification method.
- Design elements use unique identifiers (`UNIT-*`) and trace to requirements.
- Tests use unique identifiers (`TEST-*`) and trace to requirements and design.
- Ada source follows the project Ada style policy: Mixed_Case identifiers, three-space indentation, lowercase reserved words, named ends, and warnings treated as defects where practical.
- Geometry calculations use explicit physical units and conversion rules; no unlabelled page-dimension literals are permitted in the design.
- Key decisions record alternatives, selection criteria, and rationale.

## 5. Active activities and tailoring

| Activity | Status | Tailoring for this project |
|---|---|---|
| Planning and oversight (§5.1) | Active | This plan, reviews, indicators, and change control. |
| Development environment (§5.2) | Active | Git project library; canonical Alire crate; Alire-selected GNAT/GPRbuild; qpdf 11.9.0 development package; controlled fixtures and tools. |
| System requirements analysis (§5.3) | Active, deferred past plan gate | Software-only system; operational concept and system-level needs will be captured after acknowledgement. |
| System design (§5.4) | Complete for current scope | Single software system; accepted architecture is recorded in the SDD. |
| Software requirements analysis (§5.5) | Complete for current scope | Client-controlled SRS and requirement-to-test traceability are recorded. |
| Software design (§5.6) | Complete for current scope | Client-controlled SDD records the accepted architecture and B1 design basis. |
| Implementation/unit test (§5.7) | Active in B2 | Ada application orchestration, native bridge, and core units are implemented and tested; results are recorded in the B1/B2 Test Descriptions and SDF. |
| Unit integration/test (§5.8) | Active in B2 | Two-sided PDF generation, padding, Letter/A4 selection, grid emission, overwrite handling, and sequential Alire root/test builds are integrated and tested. |
| Acceptance testing (§5.9) | Planned after B2 slice | User-facing CLI and output-PDF qualification remain separate from the developer-run B2 implementation-slice tests; independence limitation applies. |
| HW/SW integration (§5.10) | Not applicable | Software-only project. |
| System acceptance (§5.11) | Conditional | May be combined with component acceptance because the system is software-only; confirm at requirements review. |
| Prepare for use (§5.12) | Planned for B2/B3 | Local installation, user documentation, and release packaging. |
| Prepare for handover (§5.13) | Conditional | Activate if the user identifies a separate maintainer or support team. |
| Configuration management (§5.14) | Active | Git, controlled artifact levels, status accounting, and release tags. |
| Product evaluation (§5.15) | Active | Self-evaluate each artifact before presenting it; independence limitation recorded. |
| Quality assurance (§5.16) | Active, inline | Process/product checks by the developer; independence limitation recorded. |
| Corrective action (§5.17) | Active | Problem/change log with category and priority for every entry. |
| Joint reviews (§5.18) | Active | Plan, requirements, and design reviews are complete; B2 implementation-slice results and test-readiness review are next. |
| Risk management (§5.19.1) | Active | Risk register in this plan; update at every review. |
| Management indicators (§5.19.2) | Active | Report requirements volatility, component progress, open problems, milestone status, scope changes, and test trend. |
| Security/privacy (§5.19.3) | Conditional | Local PDFs may contain sensitive content; confirm process and product expectations below. No network processing is planned. |
| Subagent management (§5.19.4) | Active when delegated | Delegated work must be reviewable and must not bypass project controls. |
| Process improvement (§5.19.7) | Active | Retrospective after each build; proposed plan changes require user agreement. |

## 6. Development environment

### 6.1 Controlled tools

- Ada is the required deliverable language, as specified by the user.
- Alire is the package/build environment.
- Alire selects and records the GNAT native 15.2.1 and GPRbuild 25.0.1 toolchain for the tested build path; qpdf 11.9.0 is a documented Linux native dependency.
- Git is the project library and configuration-management tool.
- AUnit or an equivalent Ada test framework may be evaluated for unit tests.
- PDF inspection/rendering utilities may be used as test support tools, but they must not become an undocumented runtime dependency.

### 6.2 PDF implementation strategy

The design selects qpdf native APIs behind a project-owned C-compatible C++ bridge. The B1 proof of concept passed for page import, placement, vector content insertion, valid Letter output, and selectable text preservation. The B2 slice extends that bridge with explicit destination-page creation for two-sided folio output. qpdf remains the native PDF dependency for the B2 implementation path.

### 6.3 Project library

The repository root is the controlled project library. Generated build output belongs in ignored directories and must not be treated as source. Source, documents, fixtures, test records, and release descriptions are versioned. Client-controlled artifacts may not be changed without a logged change and user agreement.

## 7. Requirements and traceability approach

The Requirements Specification will separate user requirements from design decisions. Every requirement will include its source, priority, acceptance/verification method, and planned build. Traceability will be maintained in both directions:

`brief/objective → requirement → design unit → test case → result`

Unresolved physical-binding assumptions will be recorded as questions rather than silently converted into requirements.

## 8. Test and evaluation approach

Testing will cover:

- pure geometry and page-order properties;
- odd/even page counts and padding behavior;
- paper/page size and unit conversion boundaries;
- margins, gutter, and grid clipping behavior;
- portrait/landscape and source-page rotation;
- malformed, encrypted, unsupported, and empty PDFs;
- output PDF structural validity and renderability;
- deterministic output for deterministic inputs;
- CLI help, canonical usage output, invalid-flag diagnostics, exit statuses, file handling, and man-page consistency;
- representative end-to-end print/fold fixtures reviewed visually.

Acceptance tests will run on the target or an agreed equivalent environment. Because the developer is also implementing the product, acceptance, product evaluation, and QA independence limitations will be explicitly reported; the user will be invited to independently review output and results.

## 9. Configuration management

### 9.1 Identification

Project identifier: `EZBIND`. Artifact identifiers use the prefixes listed in Section 4.3. Release versions use semantic versioning after the first public release. Git commits provide revision identity; release tags and Version Descriptions identify accepted releases.

### 9.2 Control levels

- **Author control:** drafts and uncommitted working files.
- **Project-level control:** committed artifacts reviewed internally against the relevant checklist.
- **Client control:** artifacts explicitly acknowledged by the user, including the Project Plan, baselined Requirements Specification, and baselined Design Description.

### 9.3 Change procedure

Record every substantive issue or requested change in `plan/problem-change-log.md` with category and priority. Assess impact on requirements, design, tests, schedule, risks, and releases. Changes to client-controlled artifacts wait for user agreement. Update traceability and status accounting in the same change set.

### 9.4 Configuration audits

No formal client configuration audit has been requested. The project will support one if the user requests it before release; the scope and date will then be recorded here.

## 10. Reviews, reporting, and gates

- **B0 plan review:** this plan and open decisions; current gate.
- **Requirements review:** Operational Concept/Requirements Specification and traceability; no implementation beyond exploratory tooling before acknowledgement.
- **Design review:** Design Description, PDF strategy, geometry model, and test architecture; complete. B2 implementation-slice results and test-readiness review are next.
- **Test-readiness review:** test environment, fixtures, Test Description, and tool verification.
- **Build/release review:** results, open problems, Version Description, and process retrospective.

At each management review report: requirements volatility; component progress; open problems by priority; planned versus actual milestones; scope changes; and pass/fail/deferred test counts.

## 11. Resources and user participation

Developer resources currently available are the local Linux development environment, Ada toolchain, Git, PDF command-line inspection/rendering tools, and the project workspace. The user is expected to review B1/B2 results, provide representative PDFs or permission to use synthetic fixtures, and review the B2 test-readiness and physical-output package.

No developer-site installation, formal user training, or separate maintenance-team handover is currently planned. These remain open until confirmed.

## 12. Initial schedule

Dates below are sequence targets, not commitments, until the B2 implementation-slice review and test-readiness review are complete.

| Milestone | Target sequence | Dependency |
|---|---|---|
| B0 workspace and plan | Complete in current initialization | None |
| User acknowledgement of plan/open decisions | Next gate | User review |
| Operational concept and requirements draft | After B0 acknowledgement | Clarified physical and CLI parameters |
| Requirements review/baseline | Following requirements draft | User review |
| Architecture/design draft | After requirements baseline | Requirements review |
| Design review/baseline | Before B1 implementation | User review |
| B1 proof of concept | Completed 2026-09-21 | Design baseline; native dependency verification |
| B2 usable CLI | Active implementation slice | B1 results review and controlled B2 scope |
| B3 release hardening | After B2 acceptance | User feedback and open-problem closure |

## 13. Accepted B0 decisions

The user accepted the proposed resolutions for all B0 open-decision items on 2026-09-21. They form the B1 requirements baseline; the accepted Design Description defines the implementation basis.

- Letter, A4, and custom sheet dimensions are supported; the source page is the finished-page target size.
- Each sheet is folded once and carries four logical pages using standard booklet ordering.
- Blank padding completes a multiple of four.
- Cover cards are excluded by default, with optional blank front/back card pages.
- Fabric remains physical; an optional spine/fabric guide may be printed.
- Top, bottom, fore-edge, and spine margins are independently configurable from finished-page edges.
- Margins are blank by default; optional 5 mm light-gray vector grid lines are confined to margin areas.
- Creep, crop/fold/registration marks, and safe-area reserves are optional and disabled by default.
- Input handling, preservation, local-only processing, Linux targeting, CLI semantics, and acceptance approach follow the accepted resolutions recorded in the requirements documents.

## 14. Risk register

| ID | Risk | Likelihood/impact | Mitigation | Owner/status |
|---|---|---|---|---|
| R-001 | The physical meaning of “modified DFA” is underspecified, producing a visually plausible but physically incorrect page order. | High/High | Resolve Section 13 questions; create fold/order diagrams and synthetic fixtures; require physical review of representative output. | Developer / Open |
| R-002 | The selected Ada/PDF approach cannot import and reposition existing PDF page content with sufficient fidelity. | Medium/High | qpdf bridge proof passed for the B1 slice; retain backend abstraction and expand mixed-page/feature tests in B2. | Developer / Mitigated |
| R-003 | Printer non-printable areas or unrequested creep cause clipped or misregistered output. | Medium/High | Make sheet/margin/printer assumptions explicit; validate dimensions and render output; support marks only if required. | Developer / Open |
| R-004 | Source PDFs contain features the chosen backend cannot preserve. | Medium/High | Define preservation requirements; inspect representative PDFs; report unsupported features rather than silently dropping them. | Developer / Open |
| R-005 | Toolchain differences between host GNAT and the Alire-selected GNAT make builds irreproducible. | Medium/Medium | Canonical Alire build path selected and verified with sequential root/test development builds. | Developer / Mitigated |
| R-006 | User-provided PDFs may contain private content and could be exposed by temporary files or diagnostics. | Medium/High | Default to local processing; avoid content logging; define temporary-file cleanup and privacy expectations before implementation. | Developer / Open |
| R-007 | Scope expands into a general print-imposition engine before the binding workflow is validated. | Medium/Medium | Use evolutionary builds and change control; keep B1 focused on one validated physical workflow. | Developer / Open |

## 15. Self-evaluation of this plan

Applied the plan criteria from the process reference:

- **Applicable information:** Present for the B0 planning gate; later-phase details are explicitly marked deferred or conditional.
- **Scope:** Matches the initiating brief and identifies exclusions and unresolved physical parameters.
- **Feasibility:** The staged approach defers PDF-backend commitment until a proof of concept.
- **Schedule:** Uses sequence milestones because user decisions and physical validation dates are not yet available.
- **Visibility:** Defines plan, requirements, design, test-readiness, and release reviews plus management indicators.
- **Supportability:** Requires controlled source, build-toolchain selection, design records, and release descriptions.
- **Independence limitation:** Explicitly recorded for self-evaluation, QA, and acceptance testing.

Result: **accepted as the client-controlled baseline after user acknowledgement on 2026-09-21.**

## 16. Current gate

The B0 plan/open-decisions, requirements, and design gates were closed by user acknowledgement on 2026-09-21. The B1 proof-of-concept and the first B2 implementation slice are complete. The project is at the B2 implementation-slice/test-readiness gate; broader CLI options, acceptance testing, and physical qualification remain incomplete.

## 17. Notes

The plan is tailored for a greenfield, software-only, single-developer project. Any requirement designated critical by the user, any user-site installation, any separate maintenance handover, any witnessed acceptance session, or any development-process security/privacy constraint will require a corresponding plan update before the affected activity begins.

## 18. Baseline acknowledgement

The user acknowledged the Project Plan and accepted the proposed resolutions for all Section 13 decision items on 2026-09-21. The user subsequently requested the `ezbind(1)` man page and canonical CLI usage behavior on 2026-09-21; this authorized Revision 1.1. The user accepted the requirements baseline and Design Description on 2026-09-21. B1 implementation, the B2 implementation slice, and their documentation are recorded; B2 expansion and acceptance testing remain active. The plan remains client-controlled. Any further change to the accepted baseline requires a Problem/Change Log entry and user agreement.
