# Architecture

This repository holds three small ABAP packages and the tooling that checks
them. Read the [README](../README.md) first; this page explains how the parts
fit together and where each one lives.

## Components

Each `zjk_*` folder is one ABAP package. The packages do not reference each
other: no object in one package uses an object from another, so each can be
installed, tested and read on its own.

| Package | Objects |
| --- | --- |
| [zjk_alpha](../zjk_alpha) | `zcl_jk_alpha`: static methods `to_internal` and `to_external`, a string based ALPHA conversion |
| [zjk_currency](../zjk_currency) | `zcl_jk_currency` (the conversion), `zif_jk_currency_decimals` (where decimal places come from), `zcl_jk_currency_decimals` (an in memory `TCURX`) |
| [zjk_range](../zjk_range) | `zcl_jk_range`: static method `matches`, which evaluates a select-options table like the `IN` operator |

Every class is `FINAL` and `CREATE PRIVATE`. `zjk_alpha` and `zjk_range` are
stateless and expose only static methods. `zjk_currency` is the one package
with instances, because it needs a dependency passed in.

## How data flows in zjk_currency

`zjk_currency` is the only package whose logic depends on something outside
itself: the number of decimal places a currency uses, which SAP keeps in the
database table `TCURX`. The package never reads that table.

1. The caller reads `TCURX` (or any other source) and builds a
   `zcl_jk_currency_decimals=>tcurx_table`.
2. `zcl_jk_currency_decimals=>create` wraps that table and returns a
   `zif_jk_currency_decimals`. A currency missing from the table gets the
   default of two decimal places.
3. `zcl_jk_currency=>create` takes that interface reference and returns a
   converter.
4. `to_external` and `to_internal` ask the interface for the currency's
   decimal places and shift the amount by the matching power of ten.

In the unit tests a local double implements `zif_jk_currency_decimals`
instead, so no database is involved. The reasoning is in
[ADR 0003](adr/0003-keep-database-and-function-modules-out-of-the-logic.md).

## How the checks run

The ABAP code is checked without an SAP system. Each package defines the
same npm scripts in its `package.json`:

| Stage | What happens |
| --- | --- |
| `npm run lint` | abaplint checks the sources against `abaplint.json` (ABAP version 7.55) |
| `npm run transpile` | `@abaplint/transpiler-cli` compiles `src/` and its ABAP Unit tests to JavaScript in `output/`, against [open-abap-core](https://github.com/open-abap/open-abap-core) |
| `npm run unit` | Node runs the generated tests, then `scripts/report-unit-results.mjs` prints each result and fails on any failed test or on an empty run |
| `npm test` | All three in order |

The CI workflow in [.github/workflows/ci.yml](../.github/workflows/ci.yml) has
three jobs:

| Job | What it does |
| --- | --- |
| Discover projects | Finds every top-level folder with a `package.json`, skipping folders that start with `_` or `.` |
| Build | One matrix leg per discovered folder: `npm ci`, lint, transpile, unit tests, on Node.js 22 |
| All checks passed | Passes only when every build leg passed; this is the single check branch protection requires |

A new package therefore needs no change to CI. Why the tests run on a
transpiler rather than in SAP, and what that misses, is in
[ADR 0002](adr/0002-run-abap-unit-on-the-transpiler.md).

## How a package reaches an SAP system

abapGit reads `.abapgit.xml` from the root of a repository, and this
repository has three packages, so it cannot be pulled as one abapGit online
repository. Each package folder carries its own `.abapgit.xml` (starting folder
`/src/`, folder logic `PREFIX`) and is exported with `git archive` as a ZIP,
then imported through abapGit offline. The steps are in the
[README](../README.md#installing-a-project-into-an-sap-system), the reasoning
in [ADR 0001](adr/0001-one-repository-of-independent-packages.md).

## Where things live

| Path | Contents |
| --- | --- |
| `zjk_*/src/` | ABAP sources (`*.clas.abap`, `*.intf.abap`), tests (`*.clas.testclasses.abap`) and abapGit metadata (`*.xml`) |
| `zjk_*/abaplint.json` | Static analysis rules, identical in every package |
| `zjk_*/abap_transpile.json` | Transpiler settings: input `src`, output `output`, open-abap-core as library |
| `zjk_*/scripts/report-unit-results.mjs` | Turns the transpiled test results into console output and an exit code |
| `zjk_*/package.json` | npm scripts and the abaplint toolchain versions, locked in `package-lock.json` |
| `_template/` | Scaffold for a new package, with a [checklist](../_template/CHECKLIST.md) |
| `.github/workflows/ci.yml` | The one CI pipeline for all packages |
| `.github/pull_request_template.md` | Questions every pull request answers |
| [CONVENTIONS.md](../CONVENTIONS.md) | Naming, class design, test and Git standards |
| [docs/WORKFLOW.md](WORKFLOW.md) | How a change moves from a branch to `main`, and what CI does not check |
| [docs/adr/](adr) | Decisions behind the shape of the repository |
