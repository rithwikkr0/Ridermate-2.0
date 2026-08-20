# Google Sign-In Setup Guide — RiderMate 2.0

## Overview

Google Sign-In requires **two** OAuth client IDs:

| Client Type | Purpose |
|---|---|
| **Android** | Authorises the Android app to show the account picker |
| **Web** | Used as `serverClientId` — lets your backend verify the ID token via `google-auth` |

Both are required. If you only register the Android client, the account picker works on-device but the backend cannot verify the token (it will reject it with an "audience mismatch" error).

---

## Step 1 — Get Your SHA-1 Fingerprints

### Debug Keystore (for local testing)
```
SHA-1: E0:A1:14:63:D8:19:EF:8A:5B:D2:6F:ED:D1:40:A3:B4:9E:B1:54:66
```
Located at: `%USERPROFILE%\.android\debug.keystore`

### Release Keystore (`upload-keystore.jks`)
> **⚠️ Not found locally.** If you haven't generated a release keystore yet, run:
> ```powershell
> keytool -genkey -v `
>   -keystore "$env:USERPROFILE\upload-keystore.jks" `
>   -keyalg RSA -keysize 2048 `
>   -validity 10000 `
>   -alias upload `
>   -storepass <your-store-password> `
>   -keypass <your-key-password>
> ```
> Then get its SHA-1:
> ```powershell
> keytool -list -v `
>   -keystore "$env:USERPROFILE\upload-keystore.jks" `
>   -alias upload -storepass <your-store-password>
> ```
> Add the release SHA-1 to Google Cloud Console before publishing to Play Store.

---

## Step 2 — Create/Open a Google Cloud Project

1. Go to [https://console.cloud.google.com/](https://console.cloud.google.com/)
2. In the top bar, click the **project dropdown** (next to "Google Cloud").
3. Click **New Project**.
   - Project name: `RiderMate 2.0`
   - Location: No organisation (leave as-is)
   - Click **Create**.
4. Wait ~10 seconds, then make sure **RiderMate 2.0** is selected in the dropdown.

---

## Step 3 — Enable the Google Sign-In API (People API)

1. In the left sidebar: **APIs & Services → Library**
2. Search for: `People API`
3. Click it → click **Enable**.

---

## Step 4 — Configure OAuth Consent Screen

1. **APIs & Services → OAuth consent screen**
2. Select **External** → click **Create**
3. Fill in:
   - App name: `RiderMate 2.0`
   - User support email: your email
   - Developer contact email: your email
4. Click **Save and Continue** (through Scopes and Test Users — defaults are fine for now).
5. On the Summary page, click **Back to Dashboard**.

---

## Step 5 — Create the Android OAuth Client ID

1. **APIs & Services → Credentials**
2. Click **+ Create Credentials → OAuth client ID**
3. Application type: **Android**
4. Name: `RiderMate Android (Debug)`
5. Package name: `com.ridermate.ridermate`
6. SHA-1 certificate fingerprint: paste the debug SHA-1:
   ```
   E0:A1:14:63:D8:19:EF:8A:5B:D2:6F:ED:D1:40:A3:B4:9E:B1:54:66
   ```
7. Click **Create**.
8. You will see a screen saying "OAuth client created". **Dismiss it** — you don't need to download anything for the Android client.

---

## Step 6 — Create the Web OAuth Client ID ← **⏸ CHECKPOINT**

> **This is the critical one.** `google_sign_in` needs this to issue ID tokens your backend can verify.

1. Click **+ Create Credentials → OAuth client ID** again
2. Application type: **Web application**
3. Name: `RiderMate Web (Backend Token Verification)`
4. **Authorised JavaScript origins** — leave blank for now
5. **Authorised redirect URIs** — leave blank for now
6. Click **Create**
7. A dialog will appear with **Your Client ID** and **Your Client Secret**.
8. **Copy the Client ID** — it will look like:
   ```
   123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com
   ```
9. You don't need the Client Secret — only the Client ID.

---

## ⏸ STOP HERE

**Come back and give me the Web Client ID** from Step 6.

Once you do, I will:
1. Wire it into `flutter/lib/core/config/google_auth_config.dart` (the `serverClientId`)
2. Wire it into the backend's `/api/v1/auth/google` token verification audience check
3. Rebuild the APK and test the full end-to-end flow

---

## After Setup — What Each Part Does

```
Android account picker  →  google_sign_in signs in  →  gets idToken
idToken sent to backend  →  google-auth verifies audience=<WEB_CLIENT_ID>  →  JWT issued
Flutter receives JWT  →  stored in SharedPreferences  →  user lands on home screen
```

The Android client ID only authorises the device to sign in.  
The Web client ID is the **audience** the backend validates the token against.  
They must match or verification fails silently.
