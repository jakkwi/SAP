# How work moves

The first three commits went straight to `main` by hand, with the suite run
locally and the results read out in conversation. That worked while the
repository was one person holding two small classes in their head. This is what
replaces it, and from here on `main` is reached only through a pull request.

## The shape

**A branch is one change.** Usually one mini project, named for what it adds:
`feat/zjk-range`, `feat/zjk-currency`. Process changes take a `ci/` or `docs/`
prefix, as this one does.

**A pull request is where it argues for itself.** The template in
`.github/pull_request_template.md` asks what changed, why, and - the part that
earns its place - whether the new behaviour has a test that fails without the
change.

**`main` is always green, and protected.** CI runs abaplint, the transpiler and
ABAP Unit for every project on every pull request. GitHub refuses to merge until
that check is green, and refuses a direct push to `main` outright.

## Branches

```bash
git switch -c feat/zjk-something
# write the class and its tests, then run the suite locally
cd zjk_something && npm test
git push -u origin feat/zjk-something
gh pr create --fill
```

Squash on merge: the branch history is working-out, `main` keeps one signed
commit per change.

## What CI does not do

**It does not run inside a real SAP system.** The abaplint transpiler and
[open-abap-core](https://github.com/open-abap/open-abap-core) execute the ABAP
on GitHub's runners, which is enough to catch logic errors fast, but it is not
the SAP kernel. Packed-number rounding in particular can differ in detail.
Before a project's README claims it runs in SAP, import it through abapGit and
run the unit tests in ADT with `Ctrl+Shift+F10`.

## The rule that keeps earning its place

> A green suite proves the tests ran, not that they tested anything.

It has already caught real gaps here:

- The unit reporter counted `0 of 0` tests as a pass. If the transpiler ever
  stopped emitting the test include, CI would have stayed green while checking
  nothing. It now fails an empty run.
- `zcl_jk_currency` is tested against a double that records the currency it was
  asked about. Without that, a converter that ignored the currency and applied
  one fixed shift would pass every arithmetic test.
- Every project's logic is mutation tested by hand before it lands: break the
  rule on purpose, confirm a test turns red, put it back.

When a test fails after a deliberate change, ask first whether it was describing
the rule or the furniture.

## Installing a project into SAP

Each project is self-contained and installs on its own. The per-project READMEs
carry the exact steps: `git archive` the project subtree into a ZIP, then import
it offline through abapGit. abapGit reads `.abapgit.xml` from the repository
root, which a monorepo cannot offer directly, so the ZIP route is the supported
one.
