# Conventions

Standards applied across every project in this repository. Where a rule can be
machine-checked it lives in `abaplint.json` and fails the build rather than a
review.

## Naming

- **Clean ABAP, no Hungarian notation.** `abaplint` actively rejects `lv_`,
  `ls_`, `lt_`, `lo_`, `lr_` and `l_` prefixes on local variables.
- **Global objects** carry the `ZJK_` customer prefix: `ZCL_JK_ALPHA`,
  `ZIF_JK_...`, package `ZJK_ALPHA`.
- **Folder name = package name, lower case.** `zjk_alpha` installs into
  `ZJK_ALPHA`.
- **Names describe intent, not type.** `to_internal`, not `convert_string_1`.

## Class design

- `CREATE PRIVATE` and `FINAL` unless there is a stated reason otherwise -
  a utility class is not a base class.
- No public attributes (`no_public_attributes`); expose behaviour, not state.
- Returning parameters over exporting (`prefer_returning_to_exporting`), so
  calls compose into expressions.
- Methods stay under 40 statements. A longer method is a missing abstraction.
- Every public method carries ABAP Doc describing behaviour and parameters.

## No hidden dependencies

The recurring theme across these projects: logic that reads from the database
or calls a function module cannot be unit tested, and cannot run outside an SAP
system. Where standard SAP hides such a dependency in otherwise pure logic, the
project re-implements it with plain language constructs so the transpiler can
run it and the tests can cover it.

## Tests

- Every public method is covered.
- Tests are named after the **behaviour** they assert, not the method they
  call: `pads_numeric_input_to_18`, not `test_to_internal_1`.
- Tests are deterministic and free of system state - no database, no
  `sy-datum`, no configuration.
- `WITH_UNIT_TESTS` is set to `X` in the class metadata, otherwise abapGit
  drops the test include on serialisation.

## Static analysis

`abaplint.json` is deliberately strict: `check_syntax`, `unknown_types`,
`obsolete_statement`, `unused_variables`, upper-case keywords, 120 column
limit, no tabs, 7-bit ASCII. Warnings are errors - the build is green or it is
broken.

## Git

- Work goes straight to `main`. This is a single author repository, so there are
  no pull requests and no branch protection. CI runs on every push, and a red
  build is fixed rather than worked around.
- Commits are GPG signed.
- Commit subjects are imperative and scoped to one project:
  `zjk_alpha: never truncate input longer than the target length`.
- `src/**/*.xml` is marked `linguist-generated` - abapGit writes it, so it is
  reviewed as metadata rather than as code.
- Secrets never enter the repository; `.gitignore` blocks `.env`, `*.pse`,
  `*.p12`, `*.pem` and `*.key` at the root.
