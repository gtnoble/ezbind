# ezbind

`ezbind` is an Ada command-line application for preparing ebook PDFs for a modified DFA home-bookbinding process. It is intended to arrange single-sheet folios for duplex printing, folding toward the spine, stacking, and gluing into a text block.

## Project status

The project is in **Build B1 implementation**. The accepted requirements and design are in place. The current executable provides the canonical help and invalid-command-line behavior and includes the physical-unit, geometry, imposition, and qpdf bridge proof-of-concept components. Full PDF layout orchestration and the complete option set remain planned B2 work.

## Build with Alire

The project uses the canonical Alire executable-crate workflow. The selected development toolchain is recorded by Alire; the native PDF bridge requires qpdf development headers/library and a C++17 compiler.

```text
alr build --development
(cd tests && alr build --development)
```

Builds should be run sequentially because the nested test crate pins the root crate and both projects may share generated root build state.

The tested native environment is Linux with qpdf 11.9.0, Alire 2.1.0, and Alire-selected GNAT native 15.2.1.

## Current command behavior

The current B1 executable supports help and usage-error behavior:

```text
./bin/ezbind --help
./bin/ezbind --bad-option
```

The canonical usage line is:

```text
Usage: ezbind [OPTIONS] INPUT.pdf --output OUTPUT.pdf
```

`--help` and `-h` return status `0`. Invalid flags and incomplete command lines return status `2`, print a diagnostic followed by the usage line to standard error, and do not create output.

PDF transformation options shown in the planned `ezbind(1)` interface are not all implemented in this B1 snapshot. Do not use this snapshot for physical binding output yet.

## B1 tests and qpdf proof of concept

The nested test executable runs the Ada core checks and, when given a source PDF and output path, exercises the qpdf bridge:

```text
./tests/bin/ezbind_tests source.pdf /tmp/ezbind-b1-output.pdf
qpdf --check /tmp/ezbind-b1-output.pdf
pdfinfo /tmp/ezbind-b1-output.pdf
pdftotext /tmp/ezbind-b1-output.pdf -
```

The B1 proof of concept has verified valid Letter output, vector content insertion, and selectable text preservation for a text-bearing fixture. See [`tests/b1-test-description.md`](tests/b1-test-description.md) for the recorded procedure and results.

## Controlled project structure

- `plan/` — project plan, configuration status, and corrective-action records
- `requirements/` — operational concept and accepted requirements
- `design/` — accepted architecture and backend rationale
- `src/` — Ada and C++ deliverable source
- `doc/` — command documentation, including `ezbind(1)`
- `tests/` — Alire test crate, test plans, procedures, and results
- `sdfs/` — project and component development logs
- `releases/` — release and version descriptions

The project process, gates, risks, and traceability are documented in [`plan/project-plan.md`](plan/project-plan.md).
