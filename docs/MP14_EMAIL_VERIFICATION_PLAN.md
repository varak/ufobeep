# MP14: Email Verification & Account Recovery Plan

## Overview
Add email verification to enable username persistence across app reinstalls and device changes.

## Implementation Locations

### 1. Database Changes
**Location:** `/home/mike/D/ufobeep/api/migrations/004_add_email_verification.sql`
```sql
ALTER TABLE users 
ADD COLUMN email_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN verification_token VARCHAR(64),
ADD COLUMN verification_sent_at TIMESTAMP,
ADD COLUMN recovery_token VARCHAR(64),
ADD COLUMN recovery_expires_at TIMESTAMP;

CREATE INDEX idx_users_verification_token ON users(verification_token);
CREATE INDEX idx_users_recovery_token ON users(recovery_token);
CREATE INDEX idx_users_email_verified ON users(email, email_verified);
```

### 2. Email Service
**Location:** `/home/mike/D/ufobeep/api/app/services/email_service.py`
```python
class EmailVerificationService:
    async def send_verification_email(self, email: str, username: str, token: str):
        # Send email with verification link
        # https://ufobeep.com/verify?token={token}
    
    async def send_recovery_email(self, email: str, username: str, token: str):
        # Send account recovery email
        # https://ufobeep.com/recover?token={token}
```

### 3. API Endpoints
**Location:** `/home/mike/D/ufobeep/api/app/routers/users.py`

#### 3a. Send Verification Email
```python
@router.post("/send-verification")
async def send_verification_email(request: dict):
    """Send verification email to user"""
    email = request.get("email")
    user_id = request.get("user_id")
    # Generate token, save to DB, send email
```

#### 3b. Verify Email
```python
@router.post("/verify-email")
async def verify_email(request: dict):
    """Verify email with token"""
    token = request.get("token")
    # Mark email as verified, return success
```

#### 3c. Account Recovery (Reinstall Flow)
```python
@router.post("/recover-account")
async def recover_account(request: dict):
    """Recover username by email"""
    email = request.get("email")
    device_id = request.get("device_id")
    # If email verified, return username and link device
```

### 4. Mobile App Changes

#### 4a. Registration Screen Enhancement
**Location:** `/home/mike/D/ufobeep/app/lib/screens/profile/user_registration_screen.dart`
```dart
// Add after successful registration
if (email != null && email.isNotEmpty) {
  await userService.sendVerificationEmail(email);
  showSnackBar("Verification email sent to $email");
}
```

#### 4b. New Recovery Screen
**Location:** `/home/mike/D/ufobeep/app/lib/screens/auth/account_recovery_screen.dart`
```dart
class AccountRecoveryScreen extends StatefulWidget {
  // Email input field
  // "Recover Account" button
  // Calls /recover-account endpoint
  // On success: logs in with recovered username
}
```

#### 4c. Splash Screen Update
**Location:** `/home/mike/D/ufobeep/app/lib/screens/splash/splash_screen.dart`
```dart
// Add recovery option for unregistered devices
if (!isRegistered) {
  // Show both options:
  // 1. "New User" → Registration
  // 2. "I have an account" → Recovery
}
```

### 5. User Service Updates
**Location:** `/home/mike/D/ufobeep/app/lib/services/user_service.dart`
```dart
Future<bool> sendVerificationEmail(String email) async {
  // Call /send-verification endpoint
}

Future<RecoveryResult> recoverAccount(String email, String deviceId) async {
  // Call /recover-account endpoint
  // If successful, save username and user_id locally
}
```

## User Flows

### Flow 1: New User Registration with Email
1. User registers with username + email
2. App sends verification email automatically
3. User clicks link in email
4. Email marked as verified
5. Username now recoverable

### Flow 2: App Reinstall Recovery
1. User reinstalls app
2. Splash screen shows "I have an account" option
3. User enters verified email
4. System returns their username
5. Device linked to existing account
6. All previous data accessible

### Flow 3: New Device Login
1. User installs on new device
2. Enters verified email
3. Gets their username
4. Same account across devices

## Implementation Priority

### Phase 1: Basic Verification (2-3 hours)
- [ ] Database schema changes
- [ ] Send verification endpoint
- [ ] Verify email endpoint
- [ ] Basic email templates

### Phase 2: Account Recovery (2-3 hours)
- [ ] Recovery endpoint
- [ ] Recovery screen in app
- [ ] Update splash screen logic
- [ ] Test reinstall flow

### Phase 3: Cross-Device Sync (1-2 hours)
- [ ] Link multiple devices to same user
- [ ] Device management endpoints
- [ ] Show active devices in profile

## Configuration Required

### Email Provider Options
1. **SendGrid** (Recommended)
   - Free tier: 100 emails/day
   - Add to `.env`: `SENDGRID_API_KEY=xxx`

2. **AWS SES** (Most scalable)
   - $0.10 per 1000 emails
   - Add to `.env`: `AWS_ACCESS_KEY=xxx`

3. **Resend** (Simplest)
   - Free tier: 100 emails/day
   - Add to `.env`: `RESEND_API_KEY=xxx`

## Security Considerations

1. **Token Generation**
   - Use cryptographically secure random tokens
   - Expire after 24 hours
   - One-time use only

2. **Rate Limiting**
   - Max 3 verification emails per hour
   - Max 5 recovery attempts per hour

3. **Email Validation**
   - Validate email format
   - Check for disposable emails
   - Prevent spam accounts

## Testing Plan

### Test Cases
1. ✅ Register with email → receive verification
2. ✅ Click verification link → email verified
3. ✅ Uninstall app → reinstall → recover account
4. ✅ Wrong email → appropriate error
5. ✅ Expired token → request new one
6. ✅ Multiple devices → same account

## Benefits
- **Username persistence** across reinstalls
- **Cross-device sync** for same user
- **Account recovery** if device lost
- **Better user retention** (no lost accounts)
- **Email list** for future features
- **Verified identity** for moderation

## Metrics to Track
- Verification email open rate
- Verification completion rate
- Account recovery success rate
- Users with verified emails
- Cross-device usage

## Future Enhancements
- Password-based login
- Social login (Google/Apple)
- Two-factor authentication
- Email notifications for alerts
- Weekly digest emails
- Account deletion (GDPR)