# Firebase Setup Guide for MediMatch

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter a project name (e.g., "MediMatch")
4. Choose whether to enable Google Analytics (recommended)
5. Accept the terms and click "Create project"
6. Wait for the project to be created, then click "Continue"

## Step 2: Register Android App

1. In the Firebase Console, click the Android icon to add an Android app
2. Enter the package name: `com.example.medimatch`
3. Enter an app nickname (optional, e.g., "MediMatch Android")
4. Enter the SHA-1 signing certificate (optional for now, but required for Google Sign-In)
   - You can get this by running `cd android && ./gradlew signingReport` in your project directory
5. Click "Register app"
6. Download the `google-services.json` file
7. Place the file in the `android/app` directory of your Flutter project
8. Click "Next" and follow the remaining steps in the Firebase Console

## Step 3: Register iOS App

1. In the Firebase Console, click the iOS icon to add an iOS app
2. Enter the bundle ID: `com.example.medimatch`
3. Enter an app nickname (optional, e.g., "MediMatch iOS")
4. Enter the App Store ID (optional)
5. Click "Register app"
6. Download the `GoogleService-Info.plist` file
7. Place the file in the `ios/Runner` directory of your Flutter project
8. Click "Next" and follow the remaining steps in the Firebase Console

## Step 4: Enable Authentication

1. In the Firebase Console, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Click on "Google" in the "Sign-in method" tab
4. Enable Google authentication and provide your support email
5. Click "Save"

## Step 5: Configure Google Sign-In

### Android Configuration

1. Make sure your `google-services.json` file is in the `android/app` directory
2. Ensure your `android/app/build.gradle` file has the Google Services plugin applied
3. Verify that the `minSdkVersion` is set to at least 21

### iOS Configuration

1. Make sure your `GoogleService-Info.plist` file is in the `ios/Runner` directory
2. Open your Xcode project: `open ios/Runner.xcworkspace`
3. Add the `GoogleService-Info.plist` file to your Runner target
4. Update your `Info.plist` to include the Google Sign-In URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace REVERSED_CLIENT_ID with the value from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

## Step 6: Test Authentication

1. Run your app on a device or emulator
2. Try signing in with Google
3. Check the Firebase Console to see if the user was created

## Troubleshooting

### Common Issues:

1. **SHA-1 Certificate Fingerprint**: If Google Sign-In fails on Android, make sure you've added the correct SHA-1 fingerprint to your Firebase project.

2. **URL Scheme**: If Google Sign-In fails on iOS, make sure you've added the correct URL scheme to your Info.plist file.

3. **Dependencies**: Make sure all dependencies are correctly added to your pubspec.yaml file and that you've run `flutter pub get`.

4. **Firebase Initialization**: Make sure Firebase is initialized before using any Firebase services.

5. **Google Services Plugin**: Make sure the Google Services plugin is applied in your Android build.gradle files.

If you encounter any issues, check the Flutter and Firebase documentation or reach out for help.
