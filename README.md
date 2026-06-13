# warp-ai-tools

在 Warp Terminal 使用 Claude Code 或 Antigravity CLI 的輔助工具集。

## 工具清單

### 1. ai_paste.ahk — 圖片貼上工具
在 Warp 中用 `Ctrl+V` 貼上剪貼簿圖片，自動存成 PNG 檔並將路徑傳給 AI 工具。
- 支援 Claude Code（`claude.exe`）與 Antigravity CLI（`agy.exe`）
- 僅在 Warp 視窗啟用，不影響其他應用程式

**安裝方式：** 執行 `安裝AI貼圖工具.ps1`（需先安裝 AutoHotkey）

---

### 2. statusline-command.sh — Statusline 顯示腳本
在 Warp 底部顯示目前 Claude Code 的模型名稱與用量資訊。

**顯示格式：**
```
Sonnet 4.6 | S:25% 06/13 15:50 | W:2% 06/18 16:00
```

**安裝方式：** 執行 `setup-statusline.ps1`

---

## 系統需求

- Windows 10 / 11
- [Warp Terminal](https://www.warp.dev/)
- [AutoHotkey v2](https://www.autohotkey.com/)（ai_paste 需要）
- Claude Code 或 Antigravity CLI
