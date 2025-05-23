# OAuth 2.0 Client ID Setup Instructions

## The Problem
You're getting "Error 401: invalid_client" because the OAuth client ID in the code is not a real, valid OAuth client ID from Google Cloud Console.

## Solution: Create OAuth 2.0 Client ID

### Step 1: Go to Google Cloud Console
1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project `medimatch-f446c` (or create it if it doesn't exist)

### Step 2: Enable Google Sign-In API
1. Go to "APIs & Services" > "Library"
2. Search for "Google Sign-In API" or "Google+ API"
3. Click on it and click "Enable"

### Step 3: Create OAuth 2.0 Client ID
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client ID"
3. If prompted, configure the OAuth consent screen first:
   - Choose "External" user type
   - Fill in the required fields (App name: "MediMatch", User support email, etc.)
   - Add your email as a developer email
   - Save and continue through the steps

### Step 4: Configure OAuth Client ID
1. Select "Web application" as the application type
2. Give it a name like "MediMatch Web Client"
3. Add Authorized JavaScript origins:
   - `http://localhost:8080` (for development)
   - `http://localhost:3000` (alternative dev port)
   - `https://medimatch-f446c.web.app` (for production)
   - `https://medimatch-f446c.firebaseapp.com` (Firebase hosting)
4. Add Authorized redirect URIs:
   - `http://localhost:8080/__/auth/handler`
   - `http://localhost:3000/__/auth/handler`
   - `https://medimatch-f446c.web.app/__/auth/handler`
   - `https://medimatch-f446c.firebaseapp.com/__/auth/handler`
5. Click "Create"

### Step 5: Copy the OAuth Client ID
1. After creation, you'll see a popup with your OAuth client ID
2. It will look like: `123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com`
3. Copy this entire string

### Step 6: Update Your Code
Once you have the real OAuth client ID, update these files:

#### Update web/index.html
Replace line 24 with:
```html
<meta name="google-signin-client_id" content="YOUR_REAL_OAUTH_CLIENT_ID.apps.googleusercontent.com">
```

#### Update lib/services/firebase_service.dart
Replace line 16 with:
```dart
clientId: kIsWeb ? 'YOUR_REAL_OAUTH_CLIENT_ID.apps.googleusercontent.com' : null,
```

### Step 7: Test the Authentication
1. Save the files
2. Run `flutter run -d chrome`
3. Try the Google Sign-in again

## Important Notes:
- The OAuth client ID must be a real one from Google Cloud Console
- Make sure to add all the correct authorized origins and redirect URIs
- The OAuth consent screen must be configured before creating the client ID
- For production, you'll need to verify your domain

## Alternative: Use Firebase Auth Domain
If you want to use Firebase's built-in OAuth handling, you can also:
1. Remove the clientId from GoogleSignIn (set it to null)
2. Let Firebase handle the OAuth flow automatically
3. Make sure your Firebase project has Google Sign-in enabled

Let me know the OAuth client ID you get from Google Cloud Console, and I'll update the code for you!
