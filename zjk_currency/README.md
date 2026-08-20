# zjk_currency - currency amounts without a TCURX lookup

[![CI](https://github.com/jakkwi/SAP/actions/workflows/ci.yml/badge.svg)](https://github.com/jakkwi/SAP/actions/workflows/ci.yml)

Shifts currency amounts between the value a `CURR` field holds and the amount a
person actually reads, for currencies that do not use two decimal places.

Like [zjk_alpha](../zjk_alpha), the interesting part is not the arithmetic. It
is that the arithmetic depends on a database table, and is unit tested anyway.

## Why it exists

A `CURR` field always carries two decimal places, whatever the currency does.
Japanese yen has none, Tunisian dinar has three. SAP resolves this by shifting
the amount by a power of ten before it reaches the database, so the stored
digits and the real amount are not the same number:

| Currency | Decimals | Stored in the `CURR` field | Real amount |
| --- | --- | --- | --- |
| JPY | 0 | `10.00` | `1000` |
| EUR | 2 | `1234.56` | `1234.56` |
| TND | 3 | `12.34` | `1.234` |

Read `BSEG-WRBTR` for a yen document and print it without converting, and the
figure is a hundred times too small. This is one of the most reliable bugs in
SAP development, and it only shows up once real yen data appears.

The number of decimal places lives in `TCURX`. Anything that reads it directly
becomes untestable and drags a database dependency into pure arithmetic.

## Where the database access lives

It does not live in this project. `zcl_jk_currency` receives the decimal places
through `zif_jk_currency_decimals`, so the single line that touches the
database belongs to the caller, at the edge of the application:

```abap
" Illustrative - this SELECT is deliberately not part of the project, because
" a class containing it could not run outside an SAP system.
SELECT currency, currdec FROM tcurx INTO TABLE @DATA(rows).

DATA(exceptions) = VALUE zcl_jk_currency_decimals=>tcurx_table(
                     FOR row IN rows ( currency = CONV string( row-currency )
                                       decimals = row-currdec ) ).

DATA(amounts) = zcl_jk_currency=>create(
                  zcl_jk_currency_decimals=>create( exceptions ) ).
```

`TCURX` only lists currencies that deviate from two decimal places, so a
currency missing from it is not an error - it is an ordinary currency.

## Usage

```abap
" a CURR field holding 10.00 is 1000 JPY
DATA(real) = amounts->to_external( amount   = CONV #( '10.00' )
                                   currency = `JPY` ).

" and back, ready to be stored
DATA(stored) = amounts->to_internal( amount   = CONV #( '1000' )
                                     currency = `JPY` ).
```

| Currency | Method | Input | Result |
| --- | --- | --- | --- |
| `JPY` (0) | `to_external` | `10.00` | `1000` |
| `EUR` (2) | `to_external` | `1234.56` | `1234.56` |
| `TND` (3) | `to_external` | `12.34` | `1.234` |
| `JPY` (0) | `to_internal` | `1000` | `10.00` |
| `TND` (3) | `to_internal` | `1.234` | `12.34` |

Internal amounts use two decimal places, mirroring a `CURR` field. External
amounts use four, mirroring `BAPICURR`. That covers every currency in practical
use, but it is a ceiling, not a guarantee: a `TCURX` entry declaring five
decimal places would be rounded to four rather than rejected.

## Installing into an SAP system

This project lives in a monorepo, and abapGit reads `.abapgit.xml` from the root
of a repository, so package this folder as a ZIP and import it offline:

```bash
git archive --format=zip HEAD:zjk_currency -o zjk_currency.zip
```

1. Create package `ZJK_CURRENCY` (or a local `$ZJK_CURRENCY` on a trial system).
2. abapGit → *New Offline* → select that package.
3. *Import package from ZIP* → choose `zjk_currency.zip`.
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
  zif_jk_currency_decimals.intf.abap          where decimal places come from
  zcl_jk_currency_decimals.clas.abap          an in memory TCURX
  zcl_jk_currency.clas.abap                   the conversion itself
  *.clas.testclasses.abap                     ABAP Unit tests
  *.xml                                       abapGit metadata
scripts/report-unit-results.mjs               turns test results into a CI exit code
abaplint.json                                 static analysis configuration
abap_transpile.json                           transpiler configuration
```

## Notes on the tests

`zcl_jk_currency` is tested against a local double implementing
`zif_jk_currency_decimals`, which also records the currency it was asked about.
That last part matters: without it, a converter that ignored the currency and
assumed one fixed shift would still pass every arithmetic test.

Two further tests pin behaviour at the edges rather than on the happy path: a
fifth decimal place is rounded away rather than rejected, and a fractional
amount in a currency that has none is rounded half up. Neither should arise
from a well maintained `TCURX`, but both are now recorded decisions instead of
accidents nobody had looked at.

## Conventions

See [CONVENTIONS.md](../CONVENTIONS.md).

## Licence

MIT - see the [repository licence](../LICENSE).
