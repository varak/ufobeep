# GitHub Secrets Configuration

This file documents all the required GitHub secrets for the CI/CD pipelines.

## Repository Secrets

### API Deployment (VPS)
- `VPS_HOST` - Your VPS IP address or domain
- `VPS_USER` - SSH username for VPS
- `VPS_SSH_KEY` - Private SSH key for VPS access (base64 encoded)
- `VPS_PORT` - SSH port (default: 22)
- `API_DOMAIN` - API domain (e.g., api.ufobeep.com)

### Docker Registry
- `GITHUB_TOKEN` - Automatically provided by GitHub Actions (for ghcr.io)

### Android Build
- `ANDROID_KEYSTORE` - Android keystore file (base64 encoded)
- `KEYSTORE_PASSWORD` - Keystore password
- `KEY_ALIAS` - Key alias name
- `KEY_PASSWORD` - Key password
- `GOOGLE_PLAY_SERVICE_ACCOUNT` - Google Play Console service account JSON

### iOS Build
- `BUILD_CERTIFICATE_BASE64` - iOS distribution certificate (.p12, base64 encoded)
- `P12_PASSWORD` - Certificate password
- `BUILD_PROVISION_PROFILE_BASE64` - Provisioning profile (base64 encoded)
- `KEYCHAIN_PASSWORD` - Temporary keychain password (any secure string)
- `APP_STORE_CONNECT_API_KEY_ID` - App Store Connect API Key ID
- `APP_STORE_CONNECT_ISSUER_ID` - App Store Connect Issuer ID
- `APP_STORE_CONNECT_API_KEY` - App Store Connect API Key content

### Vercel Deployment
- `VERCEL_TOKEN` - Vercel API token
- `VERCEL_ORG_ID` - Vercel organization ID
- `VERCEL_PROJECT_ID` - Vercel project ID

### Environment Variables
- `API_BASE_URL` - Production API URL (e.g., https://api.ufobeep.com)
- `SITE_URL` - Production site URL (e.g., https://ufobeep.com)
- `MATRIX_BASE_URL` - Matrix server URL (e.g., https://matrix.org)

### Optional Services
- `SLACK_WEBHOOK` - Slack webhook URL for notifications
- `CLOUDFLARE_ZONE_ID` - Cloudflare zone ID (if using Cloudflare)
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token

## Environment Secrets (Vercel)

Set these in Vercel dashboard:
- `@api_base_url` - API base URL
- `@site_url` - Site URL
- `@matrix_base_url` - Matrix base URL

## How to Encode Files as Base64

### Linux/Mac:
```bash
# Encode file
base64 -i yourfile.p12 -o encoded.txt

# Or inline
cat yourfile.p12 | base64
```

### Windows (PowerShell):
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("yourfile.p12"))
```

## Setting Secrets via GitHub CLI

```bash
# Install GitHub CLI
# https://cli.github.com/

# Login
gh auth login

# Set a secret
gh secret set SECRET_NAME --body "secret_value"

# Set from file
gh secret set ANDROID_KEYSTORE < keystore.base64

# List secrets
gh secret list
```

## Security Best Practices

1. **Rotate secrets regularly** - Change passwords and keys every 90 days
2. **Use least privilege** - Only grant necessary permissions
3. **Audit access** - Review who has access to secrets
4. **Use environment-specific secrets** - Different keys for dev/staging/prod
5. **Never commit secrets** - Always use GitHub Secrets or environment variables
6. **Enable 2FA** - On all service accounts and admin access