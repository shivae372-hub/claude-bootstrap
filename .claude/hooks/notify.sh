#!/bin/bash
# Notification hook: notify.sh
# Sends a desktop notification when Claude needs your attention.
# Works on macOS, Linux (notify-send), and Windows (WSL).

MESSAGE="Claude Code needs your input"
TITLE="Claude Code"

# ─── Detect OS and send notification ────────────────────────────

# macOS
if command -v osascript &> /dev/null; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null
  exit 0
fi

# Linux with notify-send (GNOME, KDE, etc.)
if command -v notify-send &> /dev/null; then
  notify-send "$TITLE" "$MESSAGE" --urgency=normal 2>/dev/null
  exit 0
fi

# WSL (Windows Subsystem for Linux)
if command -v powershell.exe &> /dev/null; then
  powershell.exe -Command "
    Add-Type -AssemblyName System.Windows.Forms
    \$notify = New-Object System.Windows.Forms.NotifyIcon
    \$notify.Icon = [System.Drawing.SystemIcons]::Information
    \$notify.Visible = \$true
    \$notify.ShowBalloonTip(3000, '$TITLE', '$MESSAGE', [System.Windows.Forms.ToolTipIcon]::Info)
    Start-Sleep -Seconds 4
    \$notify.Dispose()
  " 2>/dev/null
  exit 0
fi

# Fallback: terminal bell
printf '\a'
exit 0
