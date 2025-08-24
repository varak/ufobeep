# UFOBeep Secrets Management

## Overview
This document describes how secrets are managed for the UFOBeep application to ensure security and prevent accidental exposure.

## Secrets Location

All sensitive credentials are stored **outside the repository** at:
```
/home/ufobeep/.secrets/
```

This directory contains:
- `firebase-service-account.json` - Firebase Admin SDK service account
- Apple `.p8` keys (if/when needed for Apple Sign-In)
- Any other sensitive credentials

**Permissions:** All files in `.secrets/` have `600` permissions (owner read-only).

## What's Safe to Keep in Repository

The following files are **safe** to keep in the repository:
- `google-services.json` - Android Firebase config (contains public keys only)
- `GoogleService-Info.plist` - iOS Firebase config (contains public keys only)  
- `.env.example` - Template files with placeholder values
- Configuration files with non-sensitive settings

## Git Protection

The repository has multiple layers of protection against accidentally committing secrets:

### 1. .gitignore
The following patterns are ignored:
```
firebase-service-account-*.json
ufobeep-service-account.json
*.p8
api/secrets/
app/secrets/
*.keystore
*.jks
.env
.env.*
```

### 2. git-secrets Pre-commit Hooks
Pre-commit hooks scan for and block commits containing:
- AWS credentials
- Private keys (BEGIN PRIVATE KEY)
- Apple .p8 files
- Firebase service account patterns

### 3. History Cleaned
Git history has been purged of all previously committed secrets using `git-filter-repo`.

## Server Configuration

The API service reads Firebase credentials from environment variables:
```bash
GOOGLE_APPLICATION_CREDENTIALS=/home/ufobeep/.secrets/firebase-service-account.json
FIREBASE_SERVICE_ACCOUNT_KEY=/home/ufobeep/.secrets/firebase-service-account.json
```

These are configured in:
- `/etc/systemd/system/ufobeep-api.service` - Main service file
- `/home/ufobeep/ufobeep/.env` - Environment file (for local development)

## Key Rotation Procedures

### Firebase Service Account
1. Go to Google Cloud Console → IAM & Admin → Service Accounts
2. Find the UFOBeep service account
3. Delete the compromised key
4. Create a new JSON key
5. Save to `/home/ufobeep/.secrets/firebase-service-account.json`
6. Set permissions: `chmod 600 /home/ufobeep/.secrets/firebase-service-account.json`
7. Restart API: `sudo systemctl restart ufobeep-api`

### Apple Sign-In Keys (.p8)
1. Go to Apple Developer Portal → Keys
2. Revoke the compromised key
3. Create a new Sign in with Apple key
4. Download the `.p8` file
5. Save to `/home/ufobeep/.secrets/AuthKey_XXXXX.p8`
6. Update Firebase Console with new key ID
7. Set permissions: `chmod 600 /home/ufobeep/.secrets/*.p8`
8. Restart API if needed

## Testing Authentication

To verify Firebase authentication is working:
```bash
# Test the health endpoint
curl https://api.ufobeep.com/healthz

# Test Firebase auth (requires valid Firebase ID token)
curl -i https://api.ufobeep.com/users/auth/firebase \
  -H "Authorization: Bearer <FIREBASE_ID_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## Security Checklist

- [ ] No secrets in git history: `git ls-files | grep -E "(firebase-service|\.p8|\.keystore)"`
- [ ] Secrets directory has correct permissions: `ls -la /home/ufobeep/.secrets/`
- [ ] API service uses correct path: `sudo systemctl show ufobeep-api -p Environment`
- [ ] git-secrets hooks installed: `~/.local/bin/git-secrets --list`
- [ ] .gitignore includes all secret patterns

## Emergency Response

If a secret is accidentally committed:
1. Immediately rotate the exposed key
2. Remove from git history: `git filter-repo --path <filename> --invert-paths --force`
3. Force push to all remotes
4. Audit access logs for any unauthorized use
5. Update this documentation with lessons learned