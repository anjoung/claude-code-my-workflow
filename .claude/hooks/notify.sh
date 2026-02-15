#!/bin/bash
# Desktop notification when Claude needs attention
# Triggers on: permission prompts, idle prompts, auth events
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude needs attention"')
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')

if command -v osascript &>/dev/null; then
  # macOS
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null
elif command -v powershell.exe &>/dev/null; then
  # Windows
  powershell.exe -NoProfile -Command "
    Add-Type -AssemblyName System.Windows.Forms
    \$n = New-Object System.Windows.Forms.NotifyIcon
    \$n.Icon = [System.Drawing.SystemIcons]::Information
    \$n.Visible = \$true
    \$n.ShowBalloonTip(5000, '$TITLE', '$MESSAGE', 'Info')
    Start-Sleep -Seconds 1
    \$n.Dispose()
  " 2>/dev/null
fi
exit 0
