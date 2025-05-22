# Firebase Authentication Setup for MediMatch

This guide will help you set up Firebase Authentication with Google Sign-In and Email/Password authentication for the MediMatch app.

## Prerequisites

- Flutter SDK (version 3.32.0 or higher)
- Dart SDK (version 3.7.2 or higher)
- Firebase account
- Google account

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
4. Enter the SHA-1 signing certificate (required for Google Sign-In)
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
3. Enable the authentication methods you want to use:

   ### Google Sign-In
   1. Click on "Google" in the "Sign-in method" tab
   2. Enable Google authentication and provide your support email
   3. Click "Save"

   ### Email/Password Authentication
   1. Click on "Email/Password" in the "Sign-in method" tab
   2. Enable Email/Password authentication
   3. Optionally enable "Email link (passwordless sign-in)" if you want to allow users to sign in without a password
   4. Click "Save"

## Step 5: Update iOS Configuration

1. Open the `ios/Runner/Info.plist` file
2. Add the following configuration for Google Sign-In:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

3. Replace `YOUR-REVERSED-CLIENT-ID` with the value from your `GoogleService-Info.plist` file

## Step 6: Test Authentication

1. Run your app on a device or emulator
2. Try signing in with Google and/or email/password
3. Check the Firebase Console to see if the user was created
4. Test the password reset functionality if you're using email/password authentication

## Troubleshooting

### Common Issues:

1. **SHA-1 Certificate Fingerprint**: If Google Sign-In fails on Android, make sure you've added the correct SHA-1 fingerprint to your Firebase project.

2. **URL Scheme**: If Google Sign-In fails on iOS, make sure you've added the correct URL scheme to your Info.plist file.

3. **Dependencies**: Make sure all dependencies are correctly added to your pubspec.yaml file and that you've run `flutter pub get`.

4. **Firebase Initialization**: Make sure Firebase is initialized before using any Firebase services.

5. **Google Services Plugin**: Make sure the Google Services plugin is applied in your Android build.gradle files.

6. **Email Format**: Make sure email addresses are in a valid format when using email/password authentication.

7. **Password Strength**: Firebase requires passwords to be at least 6 characters long. Make sure your password validation matches Firebase's requirements.

8. **Email Verification**: If you're using email verification, make sure to check if the user's email is verified before allowing access to protected resources.

## Additional Resources

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Flutter Firebase Authentication Package](https://pub.dev/packages/firebase_auth)
- [Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/auth/overview)

If you encounter any issues, check the Flutter and Firebase documentation or reach out for help.
