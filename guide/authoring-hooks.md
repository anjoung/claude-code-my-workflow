# Claude Code Hook Authoring Guide

A practical reference for creating custom hooks that extend Claude Code's behavior.

## Overview

**What is a hook?**
A hook is an executable script (Bash or Python) that intercepts events in Claude Code's execution lifecycle. Hooks can validate operations, enforce policies, maintain state, or integrate with external tools.

**Where do hooks live?**
```
.claude/hooks/
├── protect-files.sh
├── log-reminder.py
├── pre-compact.sh
└── notify.sh
```

**How are they registered?**
Add an entry to `.claude/settings.json` under the `"hooks"` key (see Registration section below).

**Scale:** Most hooks are 8-50 lines. Only use Python when you need persistent state or complex logic.

---

## Available Events

| Event | Fires | Can Block? | Common Use Cases |
|-------|-------|------------|------------------|
| `PreToolUse` | Before any tool executes | Yes | Protect files, validate inputs, enforce naming |
| `PostToolUse` | After a tool executes | No | Log activity, trigger builds, update indexes |
| `Stop` | When Claude attempts to finish responding | Yes | Enforce session logging, require verification |
| `PreCompact` | Before context auto-compression | No | Save state, append to logs, snapshot context |
| `Notification` | Permission prompts, idle alerts, auth | No | Desktop notifications, external integrations |
| `SubagentStop` | When a subagent finishes | No | Aggregate results, chain workflows |
| `SessionStart` | When a session begins | No | Initialize state, load context |
| `SessionEnd` | When a session ends | No | Cleanup, final logging |
| `UserPromptSubmit` | When user submits a prompt | No | Log user requests, trigger preprocessing |

---

## Input Protocol (stdin JSON)

Claude Code passes event context to your hook via stdin as JSON.

### PreToolUse
```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/absolute/path/to/file.txt",
    "old_string": "...",
    "new_string": "..."
  }
}
```

### PostToolUse
```json
{
  "tool_name": "Read",
  "tool_input": {"file_path": "/path/to/file"},
  "tool_output": "file contents..."
}
```

### Stop
```json
{
  "cwd": "/project/directory",
  "stop_hook_active": false
}
```

### PreCompact
```json
{
  "trigger": "auto"
}
```
*Trigger values: `"auto"` (context limit) or `"manual"` (user `/clear`)*

### Notification
```json
{
  "message": "Allow Claude to use git?",
  "title": "Claude Code"
}
```

---

## Output Protocol

Your hook communicates decisions via exit codes and output streams.

### Allow the Operation
```bash
exit 0  # No stdout needed
```

### Block (PreToolUse only)
```bash
echo "Blocked: CLAUDE.md is protected" >&2
exit 2
```

### Block (Stop event only)
```bash
# Must output JSON to stdout
echo '{"decision": "block", "reason": "Session log required before stopping"}'
exit 0  # Always exit 0 for Stop hooks
```

### Error Handling (Fail Open)
```bash
exit 1  # RESERVED for unexpected errors only
        # Claude will treat this as "allow" but log a warning
```

**CRITICAL RULE: Hooks must FAIL OPEN**
- A buggy hook should never break Claude
- Exit 0 on any unexpected error (after optional logging)
- See templates below for proper error handling

---

## Bash Hook Template (Stateless)

Use this for simple validation, file protection, or event logging.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Read stdin JSON (if needed)
INPUT=$(cat)

# Example: Extract tool_name from PreToolUse event
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")

# Your logic here
if [[ "$TOOL_NAME" == "Edit" ]]; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

  if [[ "$FILE" == */CLAUDE.md ]]; then
    echo "Blocked: CLAUDE.md is protected" >&2
    exit 2  # Block the operation
  fi
fi

# Allow by default
exit 0
```

**Error Handling Pattern:**
```bash
# For non-critical operations, fail open
RESULT=$(risky_command 2>/dev/null || echo "")

# For critical checks, use || exit 0
jq -r '.field' <<<"$INPUT" 2>/dev/null || exit 0
```

---

## Python Hook Template (Stateful)

Use this when you need persistent state, complex logic, or JSON handling.

```python
#!/usr/bin/env python3
import sys
import json
import hashlib
from pathlib import Path

def get_state_dir():
    """Get hook state directory, keyed by project."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
    state_dir = Path(f"/tmp/claude-hook-name/{project_hash}")
    state_dir.mkdir(parents=True, exist_ok=True)
    return state_dir

def load_state(state_dir):
    """Load persistent state."""
    state_file = state_dir / "state.json"
    if state_file.exists():
        return json.loads(state_file.read_text())
    return {"counter": 0}

def save_state(state_dir, state):
    """Save persistent state."""
    state_file = state_dir / "state.json"
    state_file.write_text(json.dumps(state, indent=2))

def main():
    # CRITICAL: Wrap everything in try/except to fail open
    try:
        # Read stdin JSON
        input_data = json.load(sys.stdin)

        # Load state
        state_dir = get_state_dir()
        state = load_state(state_dir)

        # Your logic here
        state["counter"] += 1

        # Example: Block after 15 operations (Stop hook)
        if state["counter"] >= 15:
            output = {
                "decision": "block",
                "reason": "Counter threshold reached"
            }
            print(json.dumps(output))
            state["counter"] = 0  # Reset
            save_state(state_dir, state)
            sys.exit(0)

        # Save state
        save_state(state_dir, state)

        # Allow
        sys.exit(0)

    except Exception as e:
        # FAIL OPEN: Log error but allow operation
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == "__main__":
    main()
```

---

## Settings.json Registration

Add your hook to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/log-reminder.py",
            "timeout": 5
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-compact.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Matcher Notes:**
- Only `PreToolUse` and `PostToolUse` support matchers
- Matcher is a regex applied to the tool name: `"Edit|Write|Read"`
- Omit matcher to run on all invocations of that event
- Multiple matchers = multiple entries in the array

**Timeout:**
- Default: 5 seconds
- Hook must complete within timeout or it's killed (and fails open)

---

## State Management

**When to use state:**
- Counting operations (e.g., "log every 15 responses")
- Tracking session history
- Rate limiting or quotas
- Caching expensive computations

**Where to store state:**
```
/tmp/claude-hook-name/<project-hash>/state.json
```

**Project hash:**
```python
import hashlib
project_hash = hashlib.md5(CLAUDE_PROJECT_DIR.encode()).hexdigest()[:8]
```

**Cleanup:**
- State in `/tmp/` is ephemeral (lost on reboot)
- For persistent state, use `$CLAUDE_PROJECT_DIR/.claude/state/`
- Implement periodic cleanup if state grows unbounded

**Concurrency:**
- Hooks run serially, not in parallel
- No locking needed for state files

---

## Environment Variables

Available in all hooks:

| Variable | Value | Example |
|----------|-------|---------|
| `$CLAUDE_PROJECT_DIR` | Absolute path to project root | `/Users/you/my-project` |

**Usage:**
```bash
# Bash
LOG_DIR="$CLAUDE_PROJECT_DIR/quality_reports/session_logs"

# Python
import os
project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
```

---

## Checklist: Before You Ship Your Hook

- [ ] Hook is executable: `chmod +x .claude/hooks/your-hook.sh`
- [ ] Shebang is correct: `#!/usr/bin/env bash` or `#!/usr/bin/env python3`
- [ ] Error handling uses fail-open pattern
- [ ] Python hooks wrap `main()` in `try/except Exception: sys.exit(0)`
- [ ] Bash hooks use `|| exit 0` for critical commands
- [ ] Exit codes are correct:
  - `exit 0` to allow
  - `exit 2` to block (PreToolUse only)
  - `exit 0` + JSON to block (Stop only)
- [ ] Stop hook outputs valid JSON if blocking
- [ ] Registered in `.claude/settings.json`
- [ ] Matcher is correct (if using PreToolUse/PostToolUse)
- [ ] Timeout is reasonable (default 5s is usually fine)
- [ ] State directory uses project hash (if stateful)
- [ ] Tested with: `echo '{"tool_name": "Edit"}' | .claude/hooks/your-hook.sh`
- [ ] Hook does not use `exit 1` (reserved for unexpected errors)

---

## Examples from This Project

**Simple validation (Bash):**
```bash
# protect-files.sh - Block edits to CLAUDE.md
if [[ "$FILE" =~ CLAUDE\.md$ ]]; then
  echo "Blocked: CLAUDE.md is protected" >&2
  exit 2
fi
```

**Stateful enforcement (Python):**
```python
# log-reminder.py - Require session log every 15 responses
if response_count >= 15:
    output = {"decision": "block", "reason": "Session log required"}
    print(json.dumps(output))
```

**Event logging (Bash):**
```bash
# pre-compact.sh - Timestamp session log before compression
echo "--- Context compressed at $(date -Iseconds) ---" >> "$LOG_FILE"
```

**External integration (Bash):**
```bash
# notify.sh - macOS desktop notification
osascript -e "display notification \"$MSG\" with title \"$TITLE\""
```

---

## Tips

1. **Start simple:** Most hooks are <20 lines. Don't over-engineer.
2. **Test in isolation:** `echo '{"tool_name": "Edit"}' | your-hook.sh`
3. **Log liberally:** stderr goes to Claude's debug logs
4. **Fail open:** A broken hook should never break Claude
5. **Mind the timeout:** Default 5s is usually enough; avoid slow operations
6. **Use matchers:** Don't run on every PreToolUse if you only care about Edit/Write
7. **State is optional:** Most hooks are stateless validators

---

## Troubleshooting

**Hook doesn't fire:**
- Check `.claude/settings.json` syntax (valid JSON?)
- Verify event name spelling (case-sensitive)
- Check matcher regex (if using PreToolUse/PostToolUse)

**Hook blocks everything:**
- Check exit codes (exit 2 blocks, exit 0 allows)
- For Stop hooks, verify JSON output format

**Hook causes errors:**
- Ensure shebang is correct
- Verify file is executable (`chmod +x`)
- Check fail-open error handling (wrap in try/except or || exit 0)

**State not persisting:**
- Verify state directory exists and is writable
- Check project hash calculation
- Remember `/tmp/` is cleared on reboot

---

**Next Steps:**
1. Copy a template above
2. Replace comments with your logic
3. Test in isolation
4. Register in settings.json
5. Ship and iterate
