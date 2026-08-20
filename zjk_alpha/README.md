# zjk_alpha - ALPHA conversion in plain ABAP

[![CI](https://github.com/jakkwi/SAP/actions/workflows/ci.yml/badge.svg)](https://github.com/jakkwi/SAP/actions/workflows/ci.yml)

A dependency-free re-implementation of the classic ALPHA conversion routine
(`CONVERSION_EXIT_ALPHA_INPUT` / `_OUTPUT`) as a small ABAP class.

The point of this project is not the algorithm - it is the setup around it:
the ABAP source lives in Git, is statically analysed by abaplint and the ABAP Unit
tests run on every push **without an SAP system**, using the abaplint transpiler
and [open-abap-core](https://github.com/open-abap/open-abap-core).

## Why it exists

Conversion exits are function modules. That makes them awkward to unit test,
impossible to run outside an SAP system, and a hidden database dependency in
otherwise pure logic. This class does the same job with nothing but string
operations, so it can be covered by fast, deterministic unit tests.

## Usage

```abap
" external -> internal
DATA(internal) = zcl_jk_alpha=>to_internal( `4711` ).
" internal = '000000000000004711'

" with an explicit target length
DATA(short) = zcl_jk_alpha=>to_internal( input  = `4711`
                                         length = 10 ).
" short = '0000004711'

" internal -> external
DATA(external) = zcl_jk_alpha=>to_external( `000000000000004711` ).
" external = '4711'
```

Behaviour follows the standard conversion exit:

| Input | Method | Result | Reason |
| --- | --- | --- | --- |
| `4711` | `to_internal` | `000000000000004711` | numeric, padded to 18 |
| `MAT-001` | `to_internal` | `MAT-001` | not numeric, untouched |
| `4711` (length 3) | `to_internal` | `4711` | longer than target, never truncated |
| `000000000000000000` | `to_external` | `0` | never collapses to an empty string |

## Installing into an SAP system

This project lives in a monorepo, and abapGit reads `.abapgit.xml` from the root
of a repository - so package this folder as a ZIP and import it offline:

```bash
git archive --format=zip HEAD:zjk_alpha -o zjk_alpha.zip
```

1. Create package `ZJK_ALPHA` (or a local `$ZJK_ALPHA` on a trial system).
2. abapGit → *New Offline* → select that package.
3. *Import package from ZIP* → choose `zjk_alpha.zip`.
4. Pull, then activate the objects.
5. Run the unit tests in ADT with `Ctrl+Shift+F10`.

Folder logic is `PREFIX` with `/src/` as the starting folder, so everything
outside `src/` (CI configuration, README, tooling) is ignored by abapGit.

## Running the checks locally

No SAP system required - only Node.js 20+.

```bash
npm install
npm run lint       # abaplint: syntax check and code style
npm run transpile  # ABAP -> JavaScript
npm run unit       # ABAP Unit tests via open-abap
npm test           # all of the above
```

## Project layout

```
src/                                    ABAP objects, serialised by abapGit
  zcl_jk_alpha.clas.abap                the class
  zcl_jk_alpha.clas.testclasses.abap    ABAP Unit tests
  *.xml                                 abapGit metadata
scripts/report-unit-results.mjs         turns test results into a CI exit code
abaplint.json                           static analysis configuration
abap_transpile.json                     transpiler configuration
```

The pipeline behind the badge is shared by the whole repository and lives in
[`.github/workflows/ci.yml`](../.github/workflows/ci.yml).

## Conventions

See [CONVENTIONS.md](../CONVENTIONS.md). In short: Clean ABAP naming with no
Hungarian notation, every public method covered by tests, and tests named after
the behaviour they describe rather than the method they call.

## Licence

MIT - see the [repository licence](../LICENSE).
