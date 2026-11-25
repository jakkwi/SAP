# 0002: Run ABAP Unit on the transpiler, not in an SAP system

## Status

Accepted.

## Context

ABAP Unit tests normally run inside an SAP system. A CI pipeline that uses one
needs a reachable system, credentials and a way to deploy each change into it.
This repository has no SAP system attached to CI.

The abaplint transpiler compiles ABAP to JavaScript, and
[open-abap-core](https://github.com/open-abap/open-abap-core) implements
enough of the ABAP runtime for that JavaScript to run in Node.js, including
ABAP Unit test classes.

## Decision

Every package is checked by abaplint, transpiled with
`@abaplint/transpiler-cli` against open-abap-core, and its ABAP Unit tests are
run in Node.js. CI runs the same steps on GitHub's runners. A small script,
`scripts/report-unit-results.mjs`, turns the results into an exit code and
fails a run that reports no tests at all.

## Consequences

- Checks run on every push and pull request with no SAP system, and locally
  with only Node.js.
- The code is limited to what the transpiler and open-abap-core support. That
  is one reason the packages avoid database access and function modules (see
  [ADR 0003](0003-keep-database-and-function-modules-out-of-the-logic.md)).
- A green run does not prove the code behaves the same in an SAP system.
  open-abap-core is not the SAP kernel, and packed-number rounding in
  particular can differ. [WORKFLOW.md](../WORKFLOW.md) asks for an import and
  a test run in ADT before a package's README claims it runs in SAP.
