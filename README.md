# SAP

[![CI](https://github.com/jakkwi/SAP/actions/workflows/ci.yml/badge.svg)](https://github.com/jakkwi/SAP/actions/workflows/ci.yml)

A collection of small, self-contained ABAP projects.

Each one solves a concrete problem from day-to-day SAP work, and each is built
the way application code should be but rarely is: the source lives in Git, it is
statically analysed on every push, and its ABAP Unit tests run in continuous
integration **without an SAP system** - using the abaplint transpiler and
[open-abap-core](https://github.com/open-abap/open-abap-core).

The algorithms here are deliberately modest. The engineering around them is the
point.

## Projects

| Project | What it does | Worth a look for |
| --- | --- | --- |
| [zjk_alpha](zjk_alpha) | ALPHA conversion (`CONVERSION_EXIT_ALPHA_INPUT` / `_OUTPUT`) re-implemented as a dependency-free class | Replacing an untestable function module with pure, fully covered logic |
| [zjk_currency](zjk_currency) | Currency amounts shifted between `CURR` storage and their real magnitude, as `TCURX` defines | Keeping a database dependency out of pure arithmetic by injecting it |
| [zjk_range](zjk_range) | Evaluates a select-options table the way the `IN` operator does, all ten options and both signs | Getting the non-obvious selection rules right: empty matches all, exclusion wins |

## How these projects are built

Every project follows the same pipeline, and every step runs on GitHub's
runners with no SAP system in the loop:

| Stage | Tool | What it catches |
| --- | --- | --- |
| Serialisation | [abapGit](https://abapgit.org) | Keeps ABAP objects as reviewable text under `src/` |
| Static analysis | [abaplint](https://abaplint.org) | Syntax errors, obsolete statements, Clean ABAP naming violations |
| Transpilation | `@abaplint/transpiler-cli` | ABAP compiled to JavaScript against open-abap-core |
| Unit tests | ABAP Unit via Node | Behavioural regressions, in seconds rather than minutes |

This matters because the usual ABAP feedback loop is a transport and a system.
Here it is a `git push` and about a minute.

## Repository layout

```
.github/workflows/ci.yml    one pipeline; discovers projects automatically
_template/                  scaffold for the next mini project
zjk_alpha/                  ALPHA conversion
zjk_currency/               currency amount conversion
zjk_range/                  select-options range evaluation
CONVENTIONS.md              ABAP and repository standards
LICENSE                     MIT, covers everything here
```

Each project folder is named after the ABAP package it installs into
(`zjk_alpha` → `ZJK_ALPHA`) and is self-contained: its own `abaplint.json`,
transpiler configuration, dependencies and tests.

## Running the checks locally

No SAP system required - only Node.js 20+.

```bash
cd zjk_alpha
npm install
npm test
```

`npm test` runs lint, transpile and unit tests in sequence - exactly what CI
does. Individual stages are available as `npm run lint`, `npm run transpile`
and `npm run unit`.

## Installing a project into an SAP system

abapGit reads `.abapgit.xml` from the **root** of a repository, so a monorepo
like this one cannot be pulled directly as an online repository. Package a
single project folder instead - `git archive` on a subtree produces a ZIP with
`.abapgit.xml` and `src/` exactly where abapGit expects them:

```bash
git archive --format=zip HEAD:zjk_alpha -o zjk_alpha.zip
```

Then in the SAP system:

1. Create package `ZJK_ALPHA` (or a local `$ZJK_ALPHA` on a trial system).
2. abapGit → *New Offline* → select that package.
3. *Import package from ZIP* → choose `zjk_alpha.zip`.
4. Pull, then activate the objects.
5. Run the unit tests in ADT with `Ctrl+Shift+F10`.

Folder logic is `PREFIX` with `/src/` as the starting folder, so the CI
configuration, README and tooling stay out of the SAP system.

## Adding a new project

`_template/` is a working scaffold. Copy it and follow
[the checklist](_template/CHECKLIST.md):

```bash
cp -r _template zjk_yourname
```

CI needs no changes - it discovers every top-level folder containing a
`package.json`, and skips folders beginning with `_`.

## Conventions

Naming, testing and commit standards are documented in
[CONVENTIONS.md](CONVENTIONS.md) and enforced by `abaplint.json` where a rule
can be machine-checked.

## Licence

MIT - see [LICENSE](LICENSE).
