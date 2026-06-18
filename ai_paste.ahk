#Requires AutoHotkey v2.0
#SingleInstance Force

#HotIf WinActive("ahk_exe warp.exe") && (GetKeyState("LCtrl","P") || GetKeyState("RCtrl","P"))
^v:: {
    ; Check for CF_BITMAP (2), CF_DIB (8), and CF_DIBV5 (17)
    if (DllCall("IsClipboardFormatAvailable", "uint", 2) || DllCall("IsClipboardFormatAvailable", "uint", 8) || DllCall("IsClipboardFormatAvailable", "uint", 17)) {
        if (ProcessExist("agy.exe") || ProcessExist("claude.exe")) {
            tempFile := EnvGet("TEMP") "\ahk_clip_path.txt"
            if FileExist(tempFile)
                FileDelete(tempFile)

            psCommand := 'powershell.exe -NoProfile -WindowStyle Hidden -Command "'
                . 'Add-Type -AssemblyName System.Windows.Forms, System.Drawing; '
                . '$img = [System.Windows.Forms.Clipboard]::GetImage(); '
                . 'if ($img) { '
                . '    $timestamp = Get-Date -Format `'yyyyMMdd_HHmmss`'; '
                . '    $dir = Join-Path ([System.IO.Path]::GetTempPath()) `'ai_clip`'; '
                . '    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }; '
                . '    $path = Join-Path $dir (`'clip_`'+$timestamp+`'.png`'); '
                . '    $img.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); '
                . '    $path | Out-File -FilePath `'' tempFile '`' -Encoding utf8; '
                . '}"'
                
            RunWait(psCommand, , "Hide")
            
            if FileExist(tempFile) {
                outputPath := Trim(FileRead(tempFile), "`r`n`t ")
                FileDelete(tempFile)
                if (outputPath != "") {
                    ; Store original clipboard content
                    SavedClip := ClipboardAll()
                    
                    ; Set clipboard to the file path
                    A_Clipboard := '"' outputPath '"'
                    
                    ; Paste using Ctrl+V
                    Hotkey "^v", "Off"
                    Send "^v"
                    Sleep 150
                    Hotkey "^v", "On"
                    
                    ; Restore original clipboard content
                    A_Clipboard := SavedClip
                    SavedClip := ""
                    return
                }
            }
        }
        
        Send "!v"
    } else {
        Hotkey "^v", "Off"
        Send "^v"
        Sleep 100
        Hotkey "^v", "On"
    }
}
