#!/bin/bash

echo "========================================"
echo "  Running Flutter App on Chrome"
echo "  (Without Firebase - Web Only)"
echo "========================================"
echo ""

# Backup original pubspec.yaml
echo "[1/5] Backing up pubspec.yaml..."
cp pubspec.yaml pubspec.yaml.backup

# Comment out Firebase dependencies
echo "[2/5] Temporarily disabling Firebase..."
sed -i.tmp 's/^  firebase_core:/  # firebase_core:/' pubspec.yaml
sed -i.tmp 's/^  firebase_messaging:/  # firebase_messaging:/' pubspec.yaml
sed -i.tmp 's/^  flutter_local_notifications:/  # flutter_local_notifications:/' pubspec.yaml
rm pubspec.yaml.tmp 2>/dev/null

# Run flutter pub get
echo "[3/5] Getting dependencies..."
flutter pub get

# Run on Chrome
echo "[4/5] Launching on Chrome..."
echo ""
flutter run -d chrome --web-browser-flag="--disable-web-security"

# Restore original pubspec.yaml
echo ""
echo "[5/5] Restoring pubspec.yaml..."
cp pubspec.yaml.backup pubspec.yaml
rm pubspec.yaml.backup

echo ""
echo "========================================"
echo "  Cleanup completed!"
echo "========================================"
