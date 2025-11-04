# Running Panel App on Web (Chrome)

## Quick Start

### Windows:
```cmd
run_web.bat
```

### Mac/Linux:
```bash
chmod +x run_web.sh
./run_web.sh
```

## What it does:

1. ? Automatically backs up your `pubspec.yaml`
2. ? Temporarily disables Firebase (only for web)
3. ? Runs `flutter pub get`
4. ? Launches app on Chrome
5. ? Restores original `pubspec.yaml` when done

## Manual Method:

If you prefer to do it manually:

### Step 1: Comment out Firebase in pubspec.yaml

```yaml
dependencies:
  # Firebase (Comment out for web development)
  # firebase_core: ^2.24.2
  # firebase_messaging: ^14.7.10
  # flutter_local_notifications: ^17.0.0
```

### Step 2: Get dependencies

```bash
flutter pub get
```

### Step 3: Run on Chrome

```bash
flutter run -d chrome --web-browser-flag="--disable-web-security"
```

### Step 4: Restore Firebase (IMPORTANT!)

Uncomment the Firebase dependencies:

```yaml
dependencies:
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^17.0.0
```

```bash
flutter pub get
```

## Important Notes:

?? **Firebase only works on Android/iOS**  
? **For production, always build Android APK**  
?? **Web version is for development/testing UI only**  
?? **Notifications will NOT work on web**

## Production Build (Android):

```bash
flutter build apk --release --split-per-abi
```

---

**Note:** The app is designed for mobile (Android/iOS). Web support is minimal and only for UI testing during development.
