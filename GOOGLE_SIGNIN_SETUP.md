# Setting Up Google Sign-In for Firebase

This guide will help you properly set up Google Sign-In for your Firebase project. The current implementation is showing an error because the OAuth client ID is not properly configured.

## Error: "The OAuth client was not found. Error 401: invalid_client"

This error occurs when:
1. The OAuth client ID is incorrect or doesn't exist
2. The OAuth client ID is not properly configured in the Firebase Console
3. The web application is not properly registered as an authorized domain

## Steps to Fix Google Sign-In

### 1. Get the Correct OAuth Client ID

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (medimatch-f446c)
3. Go to "Authentication" in the left sidebar
4. Click on the "Sign-in method" tab
5. Make sure "Google" is enabled as a sign-in provider
6. If not enabled, click on "Google" and toggle the switch to enable it
7. Save your changes

### 2. Create a Web Application OAuth Client ID

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (it should be the same project that's linked to your Firebase project)
3. Go to "APIs & Services" > "Credentials"
4. Click on "Create Credentials" > "OAuth client ID"
5. Select "Web application" as the application type
6. Give it a name (e.g., "MediMatch Web")
7. Add authorized JavaScript origins:
   - Add `http://localhost:8080` for local development
   - Add `https://medimatch-f446c.firebaseapp.com` for production
   - Add `https://medimatch-f446c.web.app` for production
8. Add authorized redirect URIs:
   - Add `http://localhost:8080` for local development
   - Add `https://medimatch-f446c.firebaseapp.com/__/auth/handler` for production
   - Add `https://medimatch-f446c.web.app/__/auth/handler` for production
9. Click "Create"
10. Copy the generated OAuth client ID (it will look like `123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com`)

### 3. Update Your Code

#### Update web/index.html

```html
<!-- Google Sign-in -->
<meta name="google-signin-client_id" content="YOUR_COPIED_OAUTH_CLIENT_ID.apps.googleusercontent.com">
```

Replace `YOUR_COPIED_OAUTH_CLIENT_ID.apps.googleusercontent.com` with the OAuth client ID you copied.

#### Update lib/services/firebase_service.dart

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: kIsWeb ? 'YOUR_COPIED_OAUTH_CLIENT_ID.apps.googleusercontent.com' : null,
  scopes: ['email', 'profile'],
);
```

Replace `YOUR_COPIED_OAUTH_CLIENT_ID.apps.googleusercontent.com` with the OAuth client ID you copied.

### 4. Additional Configuration for Android and iOS

#### For Android:

1. In the Firebase Console, go to Project settings > Your apps > Android app
2. Make sure you've added your SHA-1 and SHA-256 certificate fingerprints
3. You can get these by running:
   ```
   cd android
   ./gradlew signingReport
   ```

#### For iOS:

1. In the Firebase Console, go to Project settings > Your apps > iOS app
2. Make sure your Bundle ID is correctly configured
3. Download the updated GoogleService-Info.plist file
4. Replace the existing file in your project

### 5. Test Your Implementation

1. Run your app
2. Try signing in with Google
3. You should now be able to select a Google account and sign in successfully

## Troubleshooting

If you're still having issues:

1. Make sure the OAuth client ID is correct and matches exactly what's in the Google Cloud Console
2. Verify that the authorized domains include the domain you're testing from
3. Check the Firebase Authentication logs for any errors
4. Make sure you've enabled the Google Sign-In API in the Google Cloud Console
5. Try clearing your browser cache and cookies
6. Check the browser console for any JavaScript errors

## References

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Setting up OAuth 2.0](https://support.google.com/cloud/answer/6158849)
