# Google Authentication Test Guide

## What We Fixed

1. **Updated Firebase Service Configuration**
   - Added proper OAuth client ID for web platform: `811543386253-3dbae7c2a9913d44f7aac4.apps.googleusercontent.com`
   - This matches the Firebase project configuration

2. **Updated Web Configuration**
   - Added the Google Sign-in client ID meta tag to `web/index.html`
   - This enables Google Sign-in for web platform

3. **Updated Android Configuration**
   - Fixed `google-services.json` with correct Firebase project data
   - Updated project ID from `medimatch-app` to `medimatch-f446c`
   - Updated all OAuth client IDs to match the Firebase project

## Testing Steps

### 1. Clean and Rebuild
```bash
flutter clean
flutter pub get
```

### 2. Test on Web
```bash
flutter run -d chrome
```

### 3. Test on Android
```bash
flutter run -d android
```

### 4. Test Google Sign-In Flow
1. Open the app
2. Click on "Sign in with Google" button
3. You should see the Google account selection popup
4. Select an account and complete the sign-in process
5. You should be redirected to the home screen

## Expected Behavior

- **Before Fix**: "The OAuth client was not found. Error 401: invalid_client"
- **After Fix**: Google account selection popup appears and authentication succeeds

## Additional Configuration Needed

If you still encounter issues, you may need to:

### 1. Configure OAuth Client in Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project `medimatch-f446c`
3. Go to "APIs & Services" > "Credentials"
4. Create OAuth 2.0 Client ID for Web application
5. Add authorized origins:
   - `http://localhost:8080` (for development)
   - `https://medimatch-f446c.firebaseapp.com`
   - `https://medimatch-f446c.web.app`

### 2. Add SHA-1 Fingerprints for Android
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 fingerprint and add it to Firebase Console > Project Settings > Your apps > Android app

### 3. Enable Google Sign-In API
1. Go to Google Cloud Console
2. APIs & Services > Library
3. Search for "Google Sign-In API"
4. Enable it

## Troubleshooting

### Common Issues:
1. **Web**: Make sure the OAuth client ID is correctly set in both `web/index.html` and `firebase_service.dart`
2. **Android**: Ensure SHA-1 fingerprints are added to Firebase Console
3. **iOS**: Make sure the URL scheme is correctly configured in `Info.plist`

### Debug Steps:
1. Check browser console for JavaScript errors
2. Check Flutter debug console for authentication errors
3. Verify Firebase project settings match the configuration files
