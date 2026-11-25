# 0003: Keep database access and function modules out of the logic

## Status

Accepted. Applied in `zjk_alpha` and `zjk_currency`.

## Context

Standard SAP already offers what these two packages do: the conversion exit
function modules `CONVERSION_EXIT_ALPHA_INPUT` and `_OUTPUT`, and the `TCURX`
table for the decimal places of a currency. Logic that calls a function module
or reads a table directly cannot be unit tested without that system state, and
the transpiler setup in this repository provides no SAP database tables or
function modules (see [ADR 0002](0002-run-abap-unit-on-the-transpiler.md)).

## Decision

Where standard SAP hides such a dependency in otherwise pure logic, the
package re-implements the logic with plain language constructs. When the data
itself has to come from the database, the package takes it through an
interface and leaves the `SELECT` to the caller.

| Package | Instead of |
| --- | --- |
| `zjk_alpha` | Calling `CONVERSION_EXIT_ALPHA_INPUT` / `_OUTPUT`: `zcl_jk_alpha` uses string operations only |
| `zjk_currency` | Reading `TCURX`: decimal places come in through `zif_jk_currency_decimals`, and the caller reads the table |

[CONVENTIONS.md](../../CONVENTIONS.md) states the same rule for future
packages, under "No hidden dependencies".

## Consequences

- The public methods have fast, deterministic unit tests with no database or
  system state.
- `zjk_alpha` re-implements standard behaviour, so it can drift from the
  conversion exit. Its tests pin the behaviour it claims, and its README lists
  the cases it follows.
- A caller of `zjk_currency` writes the `TCURX` read itself; the package
  README shows the code.
