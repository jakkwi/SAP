## What this changes

<!-- One paragraph. What the repository does now that it did not before, or what
     it stops doing wrong. Not a list of files. -->

## Why

<!-- The problem, not the solution. If a rule of ABAP or SAP drove the design,
     name it here. -->

## How it was checked

- [ ] `npm run lint` - abaplint reports 0 issues
- [ ] `npm run transpile` - ABAP compiles against open-abap-core
- [ ] `npm run unit` - every ABAP Unit test passes
- [ ] New behaviour has a test that **fails without the change**

<!-- The last one matters most. A green suite proves the tests ran, not that
     they tested anything. Two examples from this repository: a "0 of 0 passed"
     run used to be green until the reporter was taught to fail on an empty run,
     and a currency converter that ignored the currency entirely would still
     pass every arithmetic assertion until a test double began recording which
     currency it was asked about. Break the new rule on purpose and watch a test
     go red before trusting it. -->

## Left undone

<!-- Anything knowingly not finished, and why. Better here than found later.
     "Not run inside a real SAP system" belongs here for anything whose kernel
     behaviour the transpiler cannot fully stand in for. -->
