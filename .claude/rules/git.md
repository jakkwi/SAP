# Git and GitHub

- One branch per issue: `issue-<n>-<short-name>`. The PR body starts with `Closes #<n>`.
- Small commits, imperative subject in English, under 72 characters.
- No Co-Authored-By trailers and no mention of Claude or AI in commits, PRs, code or docs. A hook blocks it.
- Never force push, never rewrite `main`, never skip hooks.
- Before a PR: `npm test (in each changed project folder)` passes, docs updated if behaviour changed.
