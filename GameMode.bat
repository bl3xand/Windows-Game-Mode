@echo off
chcp 65001 >nul

:: ========================================
:: SETTINGS
:: ========================================
set STEAM="C:\Program Files (x86)\Steam\Steam.exe"
set TV_AUDIO=LG TV SSCR2 (NVIDIA High Definition Audio)
set DESKTOP_AUDIO=Odyssey G60SD (NVIDIA High Definition Audio)
:: Timeout waiting for audio device after display switch (seconds)
set AUDIO_TIMEOUT=10
:: Big Picture launch timeout (steps of 0.5s, 120 = 60 sec)
set BP_TIMEOUT=120
:: ========================================

echo [1/5] Closing Steam...
tasklist /FI "IMAGENAME eq Steam.exe" | find /I "Steam.exe" >nul
if not errorlevel 1 (
    taskkill /IM Steam.exe /F >nul
    timeout /t 2 /nobreak >nul
)

echo [2/5] Launching Steam Big Picture...
start "" %STEAM% -bigpicture

echo [3/5] Switching display to TV...
DisplaySwitch.exe /external

echo [4/5] Switching audio to TV...
powershell -Command "if (-not (Get-Module -ListAvailable -Name AudioDeviceCmdlets)) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null; Install-Module -Name AudioDeviceCmdlets -Force -Scope CurrentUser | Out-Null }; Import-Module AudioDeviceCmdlets; $name = '%TV_AUDIO%'; $dev = $null; for ($i = 0; $i -lt %AUDIO_TIMEOUT%; $i++) { $dev = Get-AudioDevice -List | Where-Object { $_.Name -eq $name -and $_.Type -eq 'Playback' }; if ($dev) { break }; Write-Host \"[AUDIO] Waiting... $($i+1)/%AUDIO_TIMEOUT%\" ; Start-Sleep -Seconds 1 }; if ($dev) { Write-Host \"[AUDIO] Found device: $($dev.Name)\"; Set-AudioDevice -Index $dev.Index | Out-Null } else { Write-Host '[AUDIO] Audio device not found!' }"

echo [5/5] Starting watcher...
start "BP Watcher" powershell -Command "$ds = 'C:\Windows\System32\DisplaySwitch.exe'; $da = '%DESKTOP_AUDIO%'; Write-Host \"[WATCHER] DESKTOP_AUDIO = $da\"; $timeout = %BP_TIMEOUT%; $waited = 0; Write-Host '[WATCHER] Waiting for Big Picture...'; while ($waited -lt $timeout) { Start-Sleep -Milliseconds 500; $bp = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match 'Big Picture' }; if ($bp) { Write-Host '[WATCHER] Big Picture found!'; break }; $waited++ }; if ($waited -ge $timeout) { Write-Host '[WATCHER] Timeout!'; exit }; Write-Host '[WATCHER] Watching...'; while ($true) { Start-Sleep -Milliseconds 500; $steam = Get-Process steam -ErrorAction SilentlyContinue; $bp = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match 'Big Picture' }; if (-not $steam -or -not $bp) { Write-Host '[WATCHER] Steam/BP gone, confirming...'; Start-Sleep -Seconds 1; $steam2 = Get-Process steam -ErrorAction SilentlyContinue; $bp2 = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match 'Big Picture' }; if (-not $steam2 -or -not $bp2) { Write-Host '[WATCHER] Switching display...'; & $ds /internal; Write-Host '[WATCHER] Waiting for desktop audio device...'; Import-Module AudioDeviceCmdlets; $dev = $null; for ($i = 0; $i -lt %AUDIO_TIMEOUT%; $i++) { Start-Sleep -Seconds 1; $dev = Get-AudioDevice -List | Where-Object { $_.Name -eq $da -and $_.Type -eq 'Playback' }; if ($dev) { break }; Write-Host \"[WATCHER] Waiting... $($i+1)/%AUDIO_TIMEOUT%\" }; if ($dev) { Write-Host \"[WATCHER] Found device: $($dev.Name)\"; Set-AudioDevice -Index $dev.Index | Out-Null } else { Write-Host '[WATCHER] Audio device not found!' }; Write-Host '[WATCHER] Done!'; break } } }"

echo [OK] Game Mode active
exit
