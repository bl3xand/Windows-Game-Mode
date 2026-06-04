@echo off
chcp 65001 >nul

:: ========================================
:: SETTINGS
:: ========================================
set STEAM="C:\Program Files (x86)\Steam\Steam.exe"
:: Big Picture launch timeout (steps of 0.5s, 120 = 60 sec)
set BP_TIMEOUT=120
:: ========================================

:: Kill Steam if running
echo [1/4] Closing Steam...
tasklist /FI "IMAGENAME eq Steam.exe" | find /I "Steam.exe" >nul
if not errorlevel 1 (
    taskkill /IM Steam.exe /F >nul
    timeout /t 2 /nobreak >nul
)

:: Launch Steam in Big Picture while display switches
echo [2/4] Launching Steam Big Picture...
start "" %STEAM% -bigpicture

echo [3/4] Switching to TV...
DisplaySwitch.exe /external

echo [4/4] Starting watcher...
start "BP Watcher" /min powershell -WindowStyle Hidden -Command "$ds = 'C:\Windows\System32\DisplaySwitch.exe'; $timeout = %BP_TIMEOUT%; $waited = 0; while ($waited -lt $timeout) { Start-Sleep -Milliseconds 500; $bp = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match 'Big Picture' }; if ($bp) { break }; $waited++ }; if ($waited -ge $timeout) { exit }; while ($true) { Start-Sleep -Milliseconds 500; $steam = Get-Process steam -ErrorAction SilentlyContinue; $bp = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match 'Big Picture' }; if (-not $steam -or -not $bp) { Start-Sleep -Seconds 1; $steam2 = Get-Process steam -ErrorAction SilentlyContinue; $bp2 = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match 'Big Picture' }; if (-not $steam2 -or -not $bp2) { & $ds /internal; break } } }"

echo [OK] Game Mode active
