# zjk_range - the IN operator, spelled out

[![CI](https://github.com/jakkwi/SAP/actions/workflows/ci.yml/badge.svg)](https://github.com/jakkwi/SAP/actions/workflows/ci.yml)

Evaluates a select-options table the way ABAP's `IN` operator does, as an
ordinary method you can call on a single value.

Where [zjk_alpha](../zjk_alpha) and [zjk_currency](../zjk_currency) convert one
value into another, this project decides a yes or no question: does a value
satisfy a selection? The interest is not the loop, it is the handful of rules
around it that almost everyone half remembers.

## Why it exists

`value IN selection` reads like plain English, and that is the trap. The rules
it hides are easy to get wrong, and each one is a real defect when you do:

| Rule | What surprises people |
| --- | --- |
| Empty selection | Matches **everything**, not nothing. An unfilled parameter must not filter the result down to zero rows. |
| Exclusion versus inclusion | An `E` row always wins over an `I` row, whatever order they sit in. |
| Only exclusions | A selection made of `E` rows alone matches everything it does not exclude. |
| `BT` with reversed bounds | `BT` from `M` to `A` matches nothing. It is not reordered for you. |
| Character comparison | `15` sorts before `9`. A range over a character field is not numeric. |

Get the first one wrong in a report and an empty selection screen returns no
data instead of all of it - a bug users report as "the report is broken", and
one that never appears while you test with the field filled in.

## What it covers

All ten options a selection row can carry:

| Option | Meaning | Option | Meaning |
| --- | --- | --- | --- |
| `EQ` | equal | `LE` | less or equal |
| `NE` | not equal | `BT` | between, inclusive |
| `GT` | greater than | `NB` | not between |
| `GE` | greater or equal | `CP` | covers pattern (`*`, `+`, `#`) |
| `LT` | less than | `NP` | no pattern |

Both signs, `I` and `E`. An option the row does not recognise matches nothing,
rather than raising, so a malformed row cannot select data by accident.

## Usage

```abap
DATA(material) = VALUE zcl_jk_range=>range_table(
                   ( sign = 'I' option = 'CP' low = `MAT-*` )
                   ( sign = 'E' option = 'EQ' low = `MAT-0000` ) ).

IF zcl_jk_range=>matches( value     = `MAT-4711`
                          selection = material ) = abap_true.
  " selected: matches the pattern and is not the excluded number
ENDIF.
```

| Value | Selection | Result |
| --- | --- | --- |
| `MAT-4711` | `I CP MAT-*` | selected |
| `MAT-0000` | `I CP MAT-*`, `E EQ MAT-0000` | rejected, the exclusion wins |
| anything | empty | selected |
| `C` | `I BT M..A` | rejected, bounds reversed |

## A note on comparison

Comparison is character based, which is what a selection over a `CHAR`, `NUMC`
or `DATS` field does, and it is the common case. A selection over a genuinely
numeric field orders by magnitude instead; this class does not try to guess the
underlying type, it commits to character semantics and documents the choice.

## Installing into an SAP system

This project lives in a monorepo, and abapGit reads `.abapgit.xml` from the root
of a repository, so package this folder as a ZIP and import it offline:

```bash
git archive --format=zip HEAD:zjk_range -o zjk_range.zip
```

1. Create package `ZJK_RANGE` (or a local `$ZJK_RANGE` on a trial system).
2. abapGit → *New Offline* → select that package.
3. *Import package from ZIP* → choose `zjk_range.zip`.
4. Pull, then activate the objects.
5. Run the unit tests in ADT with `Ctrl+Shift+F10`.

## Running the checks locally

No SAP system required - only Node.js 20+.

```bash
npm install
npm test
```

## Project layout

```
src/
  zcl_jk_range.clas.abap                the evaluator
  zcl_jk_range.clas.testclasses.abap    ABAP Unit tests
  *.xml                                 abapGit metadata
scripts/report-unit-results.mjs         turns test results into a CI exit code
abaplint.json                           static analysis configuration
abap_transpile.json                     transpiler configuration
```

## Notes on the tests

The suite is in three parts: the sign rules that make `IN` surprising, the ten
options one at a time, and the edge cases the README calls out. The sign tests
are the point - an implementation that treated an empty selection as "match
nothing", or let row order decide an include versus exclude clash, would still
pass every option test on its own.

## Conventions

See [CONVENTIONS.md](../CONVENTIONS.md).

## Licence

MIT - see the [repository licence](../LICENSE).
