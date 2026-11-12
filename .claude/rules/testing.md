---
paths:
  - "**/src/**"
  - "**/scripts/**"
---
# Testing

- ABAP Unit, run on Node.js through the transpiler: `npm test` inside the project folder (lint, transpile, unit).
- Every public method is covered. Tests are named after behaviour (`pads_numeric_input_to_18`).
- Tests are deterministic: no database, no system state, no dates or random values without injection.
- A new project starts from `_template/` and follows `_template/CHECKLIST.md`.
