# 安裝 AutoHotkey
winget install AutoHotkey.AutoHotkey --accept-package-agreements --accept-source-agreements

# 下載腳本
$repoUrl = "https://raw.githubusercontent.com/xu6djpc04/warp-ai-tools/main/ai_paste.ahk"
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ai_paste.ahk"
Invoke-WebRequest -Uri $repoUrl -OutFile $startupPath -UseBasicParsing

# 啟動
Start-Process $startupPath
Write-Host "完成！Ctrl+V 貼圖已啟用（Claude Code + Antigravity，僅 Warp 視窗）。" -ForegroundColor Green
