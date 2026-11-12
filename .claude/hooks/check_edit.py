"""PostToolUse hook for Edit/Write: no new long dashes, Python formatted.

Only lines that are new compared to the last commit are checked, so older text
does not block an edit. Exit 2 shows the problem to the agent so it fixes it.
"""
import json
import shutil
import subprocess
import sys
from pathlib import Path

DASHES = ("\u2014", "\u2013")
SKIP_SUFFIXES = set()

data = json.load(sys.stdin)
path = Path(data.get("tool_input", {}).get("file_path", ""))
if not path.is_file() or path.suffix.lower() in SKIP_SUFFIXES:
    sys.exit(0)

try:
    text = path.read_text(encoding="utf-8")
except (UnicodeDecodeError, OSError):
    sys.exit(0)


def committed_lines(p: Path) -> set[str]:
    try:
        rel = p.resolve().relative_to(Path.cwd().resolve()).as_posix()
        old = subprocess.run(["git", "show", f"HEAD:{rel}"], capture_output=True, text=True, encoding="utf-8")
        return set(old.stdout.splitlines()) if old.returncode == 0 else set()
    except (ValueError, OSError):
        return set()


old = committed_lines(path)
bad = [
    i + 1
    for i, line in enumerate(text.splitlines())
    if any(d in line for d in DASHES) and line not in old
]
if bad:
    print(f"{path}: long dash on new line(s) {bad}. Use a comma, colon, parentheses or a plain hyphen.", file=sys.stderr)
    sys.exit(2)

if path.suffix == ".py" and shutil.which("ruff"):
    subprocess.run(["ruff", "format", "--quiet", str(path)], check=False)

sys.exit(0)
