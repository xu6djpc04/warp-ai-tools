# Setup Claude Code status line (session + week usage)
# Usage: .\setup-statusline.ps1

$claudeDir = "$env:USERPROFILE\.claude"
$settingsPath = "$claudeDir\settings.json"
$scriptPath = "$claudeDir\statusline-command.sh"

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir | Out-Null
}

# Detect Python 3 (skip Windows Store placeholder)
$pythonCmd = $null
foreach ($cmd in @("python", "python3")) {
    try {
        $path = (Get-Command $cmd -ErrorAction Stop).Source
        if ($path -notlike "*WindowsApps*") {
            $ver = & $cmd --version 2>&1
            if ($ver -match "Python 3") {
                $pythonCmd = $cmd
                Write-Host "Found Python: $path ($ver)"
                break
            }
        }
    } catch {}
}

if (-not $pythonCmd) {
    Write-Host "Error: Python 3 not found. Please install from https://python.org" -ForegroundColor Red
    exit 1
}

# Write statusline-command.sh
$shContent = @'
#!/bin/sh
PYTHONIOENCODING=utf-8 PYTHON_CMD -c "
import sys, json, datetime

try:
    data = json.loads(sys.stdin.read())
    rl = data.get('rate_limits', {})
except Exception:
    sys.exit(0)

def fmt_reset(ts):
    try:
        return datetime.datetime.fromtimestamp(int(ts)).strftime('%m/%d %H:%M')
    except Exception:
        return ''

parts = []

five = rl.get('five_hour', {})
if five.get('used_percentage') is not None:
    pct = five['used_percentage']
    reset = fmt_reset(five['resets_at']) if five.get('resets_at') else ''
    parts.append('Session: ' + str(round(pct)) + '%' + (' resets ' + reset if reset else ''))

week = rl.get('seven_day', {})
if week.get('used_percentage') is not None:
    pct = week['used_percentage']
    reset = fmt_reset(week['resets_at']) if week.get('resets_at') else ''
    parts.append('Week: ' + str(round(pct)) + '%' + (' resets ' + reset if reset else ''))

if parts:
    sys.stdout.buffer.write(' | '.join(parts).encode('utf-8'))
" <<< "$(cat)"
'@

$shContent = $shContent -replace 'PYTHON_CMD', $pythonCmd
[System.IO.File]::WriteAllText($scriptPath, $shContent, [System.Text.Encoding]::UTF8)
Write-Host "Written: $scriptPath"

# Update settings.json (preserve existing settings)
$settings = @{}
if (Test-Path $settingsPath) {
    try {
        $json = Get-Content $settingsPath -Raw -Encoding UTF8
        $parsed = $json | ConvertFrom-Json
        $parsed.PSObject.Properties | ForEach-Object { $settings[$_.Name] = $_.Value }
    } catch {
        Write-Host "Warning: Could not parse existing settings.json, creating new one." -ForegroundColor Yellow
    }
}

$settings["statusLine"] = [ordered]@{
    type    = "command"
    command = "bash ~/.claude/statusline-command.sh"
}

$json = $settings | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.Encoding]::UTF8)
Write-Host "Updated: $settingsPath"

Write-Host ""
Write-Host "Done! Restart Claude Code to see the status line." -ForegroundColor Green
