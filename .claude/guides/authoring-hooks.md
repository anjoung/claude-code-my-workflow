# Authoring Hooks

**Location:** `.claude/hooks/script-name.sh` (or `.py`), registered in `.claude/settings.json`

## Events

| Event | Can Block? | Use Case |
|-------|------------|----------|
| `PreToolUse` | Yes (exit 2) | Protect files, validate inputs |
| `PostToolUse` | No | Log activity, trigger builds |
| `Stop` | Yes (JSON) | Enforce logging, require verification |
| `PreCompact` | No | Save state before compression |
| `Notification` | No | Desktop alerts |
| `SubagentStop` | No | Chain workflows |
| `SessionStart` / `SessionEnd` | No | Init / cleanup |
| `UserPromptSubmit` | No | Preprocessing |

## Protocol

- **Input:** JSON on stdin. Extract fields with `jq` (Bash) or `json.load(sys.stdin)` (Python).
- **Allow:** exit `0`, no stdout needed.
- **Block (PreToolUse):** exit `2`, optional stderr message.
- **Block (Stop):** exit `0`, stdout JSON `{"decision": "block", "reason": "..."}`.
- **Fail open:** wrap everything in `try/except: sys.exit(0)` or `|| exit 0`. Never break Claude.

## Windows Notes

- Use `python` not `python3` in commands.
- Use relative paths (`.claude/hooks/...`), not `$CLAUDE_PROJECT_DIR`.
- Temp state: `Path(tempfile.gettempdir())` not `/tmp/`.
- Notifications: detect OS — `osascript` (macOS) vs `powershell.exe` (Windows).

## Registration in settings.json

```json
"EventType": [
  {
    "matcher": "Edit|Write",
    "hooks": [{ "type": "command", "command": ".claude/hooks/my-hook.sh", "timeout": 5 }]
  }
]
```

Omit `matcher` to fire on all tool uses. Timeout default: 5s (use 10s for stateful Python hooks).

## Bash Skeleton (stateless)

```bash
#!/bin/bash
INPUT=$(cat)
FIELD=$(echo "$INPUT" | jq -r '.field // "default"')
# Your logic
if [ CONDITION ]; then
  echo "Blocked: reason" >&2
  exit 2
fi
exit 0
```

## Python Skeleton (stateful)

```python
#!/usr/bin/env python
import json, sys, tempfile
from pathlib import Path

STATE_DIR = Path(tempfile.gettempdir()) / "claude-my-hook"

def main():
    hook_input = json.load(sys.stdin)
    if hook_input.get("stop_hook_active", False):
        sys.exit(0)
    # Your logic
    sys.exit(0)

if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.exit(0)  # Fail open
```
