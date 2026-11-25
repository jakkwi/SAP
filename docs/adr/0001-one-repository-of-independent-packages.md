# 0001: One repository of independent packages

## Status

Accepted. In place since the first commit.

## Context

The repository holds several small ABAP projects. abapGit, the tool that
moves ABAP objects between Git and an SAP system, reads `.abapgit.xml` from the
root of a repository and treats the whole repository as one package tree. One
repository per project would install with a plain abapGit online pull, but
would mean one CI setup, one licence and one set of conventions per project.

## Decision

Keep every project in this one repository, one top-level folder per ABAP
package (`zjk_alpha` installs into `ZJK_ALPHA`). Each folder is self-contained:
its own `.abapgit.xml`, `abaplint.json`, transpiler configuration, npm
dependencies and tests. No package uses objects from another.

To install a package, export its folder with `git archive` as a ZIP and import
it through abapGit offline. The folder's `.abapgit.xml` sets `/src/` as the
starting folder, so only the ABAP objects reach the SAP system.

## Consequences

- One CI workflow, one set of conventions and one licence cover every package.
- A package cannot be pulled as an abapGit online repository. Installing it is
  a manual ZIP export and import, and abapGit cannot pull later changes into
  the system by itself.
- The tooling files (`abaplint.json`, `scripts/report-unit-results.mjs`) are
  copied into each package rather than shared, so a change to them has to be
  made in every folder.
