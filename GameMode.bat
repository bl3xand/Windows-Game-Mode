@echo off
chcp 65001 >nul

set STEAM="C:\Program Files (x86)\Steam\Steam.exe"

:: Закрываем Steam если запущен
echo [1/4] Закрываем Steam...
tasklist /FI "IMAGENAME eq Steam.exe" | find /I "Steam.exe" >nul
if not errorlevel 1 (
    taskkill /IM Steam.exe /F >nul
    timeout /t 2 /nobreak >nul
)

:: Запускаем Steam в Big Picture пока переключается экран
echo [2/4] Запускаем Steam Big Picture...
start "" %STEAM% -bigpicture

echo [3/4] Переключаемся на TV...
DisplaySwitch.exe /external

echo [4/4] Запускаем наблюдатель...
start "BP Watcher" /min powershell -WindowStyle Hidden -Command "$ds = 'C:\Windows\System32\DisplaySwitch.exe'; $timeout = 120; $waited = 0; while ($waited -lt $timeout) { Start-Sleep -Milliseconds 500; $bp = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq 'Режим Big Picture' }; if ($bp) { break }; $waited++ }; if ($waited -ge $timeout) { exit }; while ($true) { Start-Sleep -Milliseconds 500; $steam = Get-Process steam -ErrorAction SilentlyContinue; $bp = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq 'Режим Big Picture' }; if (-not $steam -or -not $bp) { Start-Sleep -Seconds 1; $steam2 = Get-Process steam -ErrorAction SilentlyContinue; $bp2 = Get-Process steamwebhelper -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq 'Режим Big Picture' }; if (-not $steam2 -or -not $bp2) { & $ds /internal; break } } }"

echo [OK] Game Mode активен