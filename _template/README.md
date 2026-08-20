# zjk_PROJECT - ONE LINE SUMMARY

[![CI](https://github.com/jakkwi/SAP/actions/workflows/ci.yml/badge.svg)](https://github.com/jakkwi/SAP/actions/workflows/ci.yml)

TWO OR THREE SENTENCES: what the object does, and what makes it worth reading.

## Why it exists

The problem this solves, and why the obvious standard approach is awkward.
This is the section a reviewer actually reads - lead with the engineering
reason, not with the feature list.

## Usage

```abap
DATA(result) = zcl_jk_PROJECT=>do_something( `input` ).
```

| Input | Method | Result | Reason |
| --- | --- | --- | --- |
| `x` | `do_something` | `y` | why |

## Installing into an SAP system

See [Installing a project](../README.md#installing-a-project-into-an-sap-system)
in the repository README.

Package: `ZJK_PROJECT` (or `$ZJK_PROJECT` on a trial system).

## Running the checks locally

No SAP system required - only Node.js 20+.

```bash
npm install
npm test
```

## Repository layout

```
src/                                      ABAP objects, serialised by abapGit
  zcl_jk_PROJECT.clas.abap                the class
  zcl_jk_PROJECT.clas.testclasses.abap    ABAP Unit tests
  *.xml                                   abapGit metadata
scripts/report-unit-results.mjs           turns test results into a CI exit code
abaplint.json                             static analysis configuration
abap_transpile.json                       transpiler configuration
```

## Licence

MIT - see the [repository licence](../LICENSE).
