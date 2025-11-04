@echo off
echo ========================================
echo   Running Flutter App on Chrome
echo   (Without Firebase - Web Only)
echo ========================================
echo.

REM Backup original pubspec.yaml
echo [1/5] Backing up pubspec.yaml...
copy pubspec.yaml pubspec.yaml.backup >nul

REM Comment out Firebase dependencies
echo [2/5] Temporarily disabling Firebase...
powershell -Command "(Get-Content pubspec.yaml) -replace '  firebase_core:', '  # firebase_core:' -replace '  firebase_messaging:', '  # firebase_messaging:' -replace '  flutter_local_notifications:', '  # flutter_local_notifications:' | Set-Content pubspec.yaml"

REM Run flutter pub get
echo [3/5] Getting dependencies...
flutter pub get

REM Run on Chrome
echo [4/5] Launching on Chrome...
echo.
flutter run -d chrome --web-browser-flag="--disable-web-security"

REM Restore original pubspec.yaml
echo.
echo [5/5] Restoring pubspec.yaml...
copy pubspec.yaml.backup pubspec.yaml >nul
del pubspec.yaml.backup

echo.
echo ========================================
echo   Cleanup completed!
echo ========================================
