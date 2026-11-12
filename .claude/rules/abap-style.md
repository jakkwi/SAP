---
paths:
  - "**/src/**"
  - "**/abaplint.json"
---
# ABAP style

CONVENTIONS.md is the source of truth; in short:
- Clean ABAP, no Hungarian prefixes (`lv_`, `ls_`, `lt_`, `lo_`...). abaplint rejects them.
- Global objects use the `ZJK_` / `ZCL_JK_` prefix; folder name = package name in lower case.
- Classes `CREATE PRIVATE` and `FINAL` unless there is a stated reason; no public attributes; returning over exporting.
- Methods under 40 statements; ABAP Doc on every public method.
- No hidden dependencies: no database reads or function module calls inside logic that should be testable; inject them.
- Do not loosen `abaplint.json` to get a change through.
