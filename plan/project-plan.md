# ezbind Project Plan

**Project:** ezbind — home bookbinding PDF preparation CLI  
**Document:** Software Development Plan (SDP)  
**Identifier:** EZBIND-SDP-001  
**Status:** Draft — awaiting client acknowledgement  
**Date:** 2026-09-21  
**Revision:** 0.1

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

The user brief in the initiating conversation is the source of the initial project objectives. Detailed requirements have not yet been baselined; requirements analysis is gated on acknowledgement of this plan and resolution of the open decisions in Section 13.

## 2. Referenced documents

- User initiating brief, 2026-09-21.
- `requirements/requirements-spec.md` — to be created after this plan is acknowledged.
- `design/design-description.md` — to be created after requirements review and acknowledgement.
- `tests/test-plan.md` — initial test-planning placeholder; to be baselined with the requirements.
- `sdfs/project-development-log.md` — project development log.
- `plan/problem-change-log.md` — corrective-action and change record.
- `plan/configuration-status.md` — configuration status accounting.

## 3. Required work and products

### 3.1 Deliverable software

One operational Ada CLI application, configuration-free by default, with documented command syntax and deterministic PDF output for a given input and parameter set.

### 3.2 Supporting products

- Project Plan (this document).
- Operational concept and Requirements Specification.
- Software Design Description.
- Test Plan, Test Description, and Test Report, consolidated where practical.
- User Manual and Installation/Build instructions when deployment preparation begins.
- Version Description for each release.
- Project and component development logs.
- Problem/change log, configuration status records, review records, and self-evaluation records.

### 3.3 Project components

For the first build, the deliverable is treated as one software component, `EZBIND-CLI`, with logical units for command-line parsing, PDF inspection, binding geometry, imposition, margin-grid rendering, PDF emission, and diagnostics. The final decomposition remains a design decision subject to requirements analysis.

## 4. Development process and build strategy

### 4.1 Lifecycle

Use an evolutionary, multi-build lifecycle. Requirements will be baselined for the current build, implemented and tested, then reviewed before the next build. Activities may iterate when geometry experiments or output-PDF validation reveal a requirement or design issue.

### 4.2 Planned builds

| Build | Objective | Exit evidence |
|---|---|---|
| B0 — project initialization | Establish process, workspace, toolchain policy, initial brief, and open-decision register. | Acknowledged Project Plan and initialized project library. |
| B1 — geometry and PDF proof of concept | Validate page geometry, folio ordering/orientation, margin modes, and a minimal output PDF on representative fixtures. | Requirements/design review; automated geometry tests; inspected sample output. |
| B2 — usable CLI | Implement validated input handling, complete CLI options, diagnostics, grid rendering, and deterministic PDF generation. | Component acceptance test cycle and user review. |
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
| Development environment (§5.2) | Active | Git project library; Alire/GNAT/GPRbuild; controlled fixtures and tools. |
| System requirements analysis (§5.3) | Active, deferred past plan gate | Software-only system; operational concept and system-level needs will be captured after acknowledgement. |
| System design (§5.4) | Active, deferred past requirements gate | Single software system; architecture will be documented after requirements review. |
| Software requirements analysis (§5.5) | Active, deferred past plan gate | Requirements and verification matrix will be baselined before implementation. |
| Software design (§5.6) | Active, deferred past requirements gate | Design description will follow requirements review and will require user acknowledgement before implementation. |
| Implementation/unit test (§5.7) | Planned for B1 onward | Ada implementation with unit tests recorded in SDFs. |
| Unit integration/test (§5.8) | Planned for B1 onward | Progressive integration with PDF fixture validation. |
| Acceptance testing (§5.9) | Planned for B2 | User-facing CLI and output-PDF qualification; developer independence limitation applies. |
| HW/SW integration (§5.10) | Not applicable | Software-only project. |
| System acceptance (§5.11) | Conditional | May be combined with component acceptance because the system is software-only; confirm at requirements review. |
| Prepare for use (§5.12) | Planned for B2/B3 | Local installation, user documentation, and release packaging. |
| Prepare for handover (§5.13) | Conditional | Activate if the user identifies a separate maintainer or support team. |
| Configuration management (§5.14) | Active | Git, controlled artifact levels, status accounting, and release tags. |
| Product evaluation (§5.15) | Active | Self-evaluate each artifact before presenting it; independence limitation recorded. |
| Quality assurance (§5.16) | Active, inline | Process/product checks by the developer; independence limitation recorded. |
| Corrective action (§5.17) | Active | Problem/change log with category and priority for every entry. |
| Joint reviews (§5.18) | Active | Plan review now; requirements, design, test-readiness, and release reviews later. |
| Risk management (§5.19.1) | Active | Risk register in this plan; update at every review. |
| Management indicators (§5.19.2) | Active | Report requirements volatility, component progress, open problems, milestone status, scope changes, and test trend. |
| Security/privacy (§5.19.3) | Conditional | Local PDFs may contain sensitive content; confirm process and product expectations below. No network processing is planned. |
| Subagent management (§5.19.4) | Active when delegated | Delegated work must be reviewable and must not bypass project controls. |
| Process improvement (§5.19.7) | Active | Retrospective after each build; proposed plan changes require user agreement. |

## 6. Development environment

### 6.1 Controlled tools

- Ada is the required deliverable language, as specified by the user.
- Alire is the package/build environment.
- GNAT and GPRbuild are the compiler/build tools; the exact selected toolchain must be recorded and made reproducible before B1 implementation.
- Git is the project library and configuration-management tool.
- AUnit or an equivalent Ada test framework may be evaluated for unit tests.
- PDF inspection/rendering utilities may be used as test support tools, but they must not become an undocumented runtime dependency.

### 6.2 PDF implementation strategy

No PDF library is selected at B0. B1 will evaluate an Ada PDF-generation library, native-library bindings, and controlled external-tool orchestration against these criteria: ability to preserve/import source pages, precise placement and rotation, vector grid rendering, output portability, dependency availability, licensing, error reporting, and deterministic testing. The selected strategy will be recorded in the Design Description before it becomes a project constraint.

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
- CLI help, diagnostics, exit statuses, and file handling;
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
- **Design review:** Design Description, PDF strategy, geometry model, and test architecture; no B1 implementation baseline before acknowledgement.
- **Test-readiness review:** test environment, fixtures, Test Description, and tool verification.
- **Build/release review:** results, open problems, Version Description, and process retrospective.

At each management review report: requirements volatility; component progress; open problems by priority; planned versus actual milestones; scope changes; and pass/fail/deferred test counts.

## 11. Resources and user participation

Developer resources currently available are the local Linux development environment, Ada toolchain, Git, PDF command-line inspection/rendering tools, and the project workspace. The user is expected to provide decisions on the open questions in Section 13, representative PDFs or permission to use synthetic fixtures, and review/acknowledgement at the defined gates.

No developer-site installation, formal user training, or separate maintenance-team handover is currently planned. These remain open until confirmed.

## 12. Initial schedule

Dates below are sequence targets, not commitments, until the B0 review is acknowledged.

| Milestone | Target sequence | Dependency |
|---|---|---|
| B0 workspace and plan | Complete in current initialization | None |
| User acknowledgement of plan/open decisions | Next gate | User review |
| Operational concept and requirements draft | After B0 acknowledgement | Clarified physical and CLI parameters |
| Requirements review/baseline | Following requirements draft | User review |
| Architecture/design draft | After requirements baseline | Requirements review |
| Design review/baseline | Before B1 implementation | User review |
| B1 proof of concept | After design baseline | Toolchain/backend selection |
| B2 usable CLI | After B1 review | Validated geometry and PDF strategy |
| B3 release hardening | After B2 acceptance | User feedback and open-problem closure |

## 13. Open decisions requiring user input

These are intentionally unresolved and block requirements baselining:

1. **Physical sheet and page model:** What paper sizes and source page sizes must be supported? Is one source page printed on each side of a sheet, or can a side contain multiple source pages? Are folios always one sheet folded once?
2. **Folio/signature structure:** What exact page ordering is desired for a folded folio stack? Should the output add blank padding pages to complete a folio/signature, and how is the folio size specified?
3. **Cover cards:** Should the generated PDF include cover-card pages, blank placeholders, registration marks, or only the text-block pages? If included, where and how many?
4. **Fabric strip:** Should the PDF reserve/mark a fabric overlap area, add a spine guide, or merely leave the specified margin? The physical fabric itself cannot be printed by the application.
5. **Margins:** Which margins are independently configurable (top, bottom, fore-edge, spine/gutter), what units should the CLI accept, and are margins measured from the trimmed page or sheet edge?
6. **Grid:** Grid spacing, line weight/color, whether the grid appears only in margins or across the page, and whether the grid must avoid the gutter/fabric area.
7. **Binding geometry:** Is creep compensation required? Are crop marks, fold marks, registration marks, bleed, or printer-safe-area constraints required?
8. **Input PDF assumptions:** Must the tool preserve selectable text, links, annotations, bookmarks, metadata, forms, and embedded fonts? How should encrypted or malformed PDFs be handled?
9. **Output and operation:** Target OSes, expected maximum PDF size/page count, overwrite policy, stdout/stderr conventions, exit codes, configuration files, and batch operation requirements.
10. **Acceptance:** Will the user witness acceptance testing? Will representative source PDFs and physical print/fold observations be supplied? Is an independent reviewer available?
11. **Project constraints:** Any memory, storage, performance, privacy, licensing, installation, maintenance, or formal configuration-audit requirements beyond the current brief?

## 14. Risk register

| ID | Risk | Likelihood/impact | Mitigation | Owner/status |
|---|---|---|---|---|
| R-001 | The physical meaning of “modified DFA” is underspecified, producing a visually plausible but physically incorrect page order. | High/High | Resolve Section 13 questions; create fold/order diagrams and synthetic fixtures; require physical review of representative output. | Developer / Open |
| R-002 | The selected Ada/PDF approach cannot import and reposition existing PDF page content with sufficient fidelity. | Medium/High | Evaluate candidate libraries/tools in B1 before architecture baseline; retain backend abstraction. | Developer / Open |
| R-003 | Printer non-printable areas or unrequested creep cause clipped or misregistered output. | Medium/High | Make sheet/margin/printer assumptions explicit; validate dimensions and render output; support marks only if required. | Developer / Open |
| R-004 | Source PDFs contain features the chosen backend cannot preserve. | Medium/High | Define preservation requirements; inspect representative PDFs; report unsupported features rather than silently dropping them. | Developer / Open |
| R-005 | Toolchain differences between system GNAT and Alire-selected GNAT make builds irreproducible. | Medium/Medium | Select and record one build path; verify clean build in the project library; document versions. | Developer / Open |
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

Result: **acceptable as a draft for client review; not client-controlled until acknowledged.**

## 16. Current gate

The project must remain at the B0 plan/open-decisions gate until the user acknowledges this Project Plan and provides answers or explicit deferrals for the Section 13 decisions. Requirements analysis, requirements baselining, and implementation are not authorized by this draft alone.

## 17. Notes

The plan is tailored for a greenfield, software-only, single-developer project. Any requirement designated critical by the user, any user-site installation, any separate maintenance handover, any witnessed acceptance session, or any development-process security/privacy constraint will require a corresponding plan update before the affected activity begins.
