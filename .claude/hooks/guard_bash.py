"""PreToolUse hook for Bash: blocks unsafe commands, secret leaks and AI attribution.

Exit code 2 blocks the call and sends stderr back to the agent.
"""

import json
import re
import sys

data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")
if not isinstance(cmd, str):
    cmd = " ".join(map(str, cmd))

BLOCKED = [
    # destructive
    (
        r"\brm\s+-[a-zA-Z]*r[a-zA-Z]*f|\brm\s+-[a-zA-Z]*f[a-zA-Z]*r",
        "Recursive force delete is blocked. Delete specific files instead.",
    ),
    (
        r"Remove-Item\b.*-Recurse\b.*-Force|Remove-Item\b.*-Force\b.*-Recurse",
        "Recursive force delete is blocked.",
    ),
    (r"\bgit\s+push\b.*(--force\b|--force-with-lease\b|\s-f\b)", "Force push is blocked."),
    (r"\bgit\s+reset\s+--hard\b", "git reset --hard is blocked. Ask the user first."),
    (r"\bgit\s+clean\s+-[a-zA-Z]*f", "git clean -f is blocked. Ask the user first."),
    (
        r"--no-verify\b|--no-gpg-sign\b",
        "Skipping hooks or signing is blocked. Fix what failed instead.",
    ),
    # remote code execution / supply chain
    (
        r"\b(curl|wget|iwr|Invoke-WebRequest)\b[^|]*\|\s*(sh|bash|zsh|python|pwsh|powershell|iex)\b",
        "Piping downloaded content into a shell is blocked.",
    ),
    (r"\b(iex|Invoke-Expression)\b", "Invoke-Expression is blocked."),
    (
        r"--index-url|--extra-index-url|--registry[= ]",
        "Custom package indexes or registries are blocked.",
    ),
    # secrets
    (
        r"(cat|type|Get-Content|less|more|head|tail)\s+[^|;&]*\.env(?![\w.]*example)\b",
        "Reading .env files is blocked.",
    ),
    (
        r"(cat|type|Get-Content)\s+[^|;&]*(id_rsa|id_ed25519|\.pem\b|\.key\b|credentials)",
        "Reading key or credential files is blocked.",
    ),
    (
        r"\$env:[A-Z_]*(KEY|TOKEN|SECRET)|echo\s+\$[A-Z_]*(KEY|TOKEN|SECRET)",
        "Printing secrets from the environment is blocked.",
    ),
    # attribution
    (r"Co-Authored-By", "Do not add Co-Authored-By trailers or any AI attribution."),
    (r"Generated with \[?Claude", "Do not add AI attribution to commits or PRs."),
]

for pattern, msg in BLOCKED:
    if re.search(pattern, cmd, re.IGNORECASE):
        print(msg, file=sys.stderr)
        sys.exit(2)

sys.exit(0)
