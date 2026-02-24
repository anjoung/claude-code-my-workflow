# Claude Code Settings Setup

## Architecture

Permissions are split into two layers:

| Layer | File | Scope | Contains |
|-------|------|-------|----------|
| **Global** | `~/.claude/settings.json` | All projects | Tool permissions, deny list, plugins |
| **Project** | `.claude/settings.json` | This project only | Hooks, project-specific script permissions |

Global permissions apply everywhere automatically. Project settings add hooks and any project-specific scripts on top.

## New Project Setup

1. Copy `.claude/settings.json` from the template:
   ```bash
   mkdir -p .claude/hooks
   cp /path/to/my-workflow/docs/setting_project_template.json .claude/settings.json
   ```

2. Copy the hook scripts:
   ```bash
   cp /path/to/my-workflow/.claude/hooks/*.sh .claude/hooks/
   cp /path/to/my-workflow/.claude/hooks/*.py .claude/hooks/
   ```

3. Customize `protect-files.sh` — edit the `PROTECTED_PATTERNS` array for your project.

4. Add any project-specific script permissions to `.claude/settings.json` under `permissions.allow`.

## Files in This Directory

| File | Purpose |
|------|---------|
| `setting_global.json` | Reference copy of `~/.claude/settings.json` |
| `setting_project_template.json` | Template for new project `.claude/settings.json` |
| `setting_NBER.json` | Archive — the 66-entry bloat this setup replaces |

## Stata Version Upgrades

When upgrading Stata, update **2 lines** in `~/.claude/settings.json`:
```
"Bash(\"/c/Program Files/StataNow19/StataSE-64.exe\" *)",
"Bash(\"C:/Program Files/StataNow19/StataSE-64.exe\" *)",
```
Change `StataNow19` to the new version folder name. No other files need editing.

## Deny List

The global settings deny these destructive operations:
- `rm -rf /` — recursive delete of root
- `git push --force` — force-push (can overwrite upstream)
- `git reset --hard` — discard all local changes

Claude Code's built-in safety checks also apply on top of these.

## Troubleshooting

**Permissions not working in a project?**
There's a known issue where project settings may replace rather than merge with global settings. If `git status` prompts for permission in a project, add the needed permissions to that project's `.claude/settings.json` as a workaround.
