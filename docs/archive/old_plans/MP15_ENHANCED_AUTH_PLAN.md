# MP15: Enhanced Authentication System
**Email Magic Links + Optional Password Login**

## Overview
Upgrade authentication to support both magic link login (passwordless) and traditional password login, giving users flexibility while maintaining security.

## Core Features

### 1. Magic Link Login
- User enters email address
- Receives secure login link via email  
- Click link → instant authentication
- No password required

### 2. Social Login (Primary for new users)
- **Google Sign-In:** One-click account creation/login
- **Apple Sign-In:** Required for iOS App Store
- Auto-generates cosmic username from social profile
- Links to existing account if email matches

### 3. Optional Password Upgrade
- After any login method, show "Secure your account" option
- User can set password or continue passwordless
- Supports multiple authentication methods simultaneously

### 4. Multi-Method Login Support
- **Fastest:** Social login (Google/Apple) → one-click
- **Traditional:** Email + password → direct login
- **Secure:** Email → magic link → login
- **Recovery:** Magic link always works as backup

## Database Changes

### Schema Updates
```sql
-- /home/mike/D/ufobeep/api/migrations/005_enhanced_auth.sql
ALTER TABLE users 
ADD COLUMN password_hash VARCHAR(255),
ADD COLUMN magic_link_token VARCHAR(64),
ADD COLUMN magic_link_expires_at TIMESTAMP,
ADD COLUMN google_id VARCHAR(255),
ADD COLUMN apple_id VARCHAR(255),
ADD COLUMN social_profile_data JSON,
ADD COLUMN last_login_at TIMESTAMP,
ADD COLUMN login_methods JSON DEFAULT '["magic_link"]',
ADD COLUMN preferred_login_method VARCHAR(20) DEFAULT 'magic_link';

CREATE INDEX idx_users_magic_link_token ON users(magic_link_token);
CREATE INDEX idx_users_password_hash ON users(email, password_hash);
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_users_apple_id ON users(apple_id);
```

## API Endpoints

### 1. Magic Link Request
```python
# /home/mike/D/ufobeep/api/app/routers/auth.py
@router.post("/request-magic-link")
async def request_magic_link(request: dict):
    """Send magic link to user's email"""
    email = request.get("email")
    # Generate secure token, save to DB, send email
    # Link: https://ufobeep.com/auth/magic?token=xxx
    return {"success": True, "message": "Magic link sent"}
```

### 2. Magic Link Login
```python
@router.get("/magic-login")
async def magic_login(token: str):
    """Authenticate user via magic link token"""
    # Validate token, check expiry
    # Return JWT + user data
    # Mark token as used (one-time)
    return {"jwt": "xxx", "user": {...}}
```

### 3. Password Login
```python
@router.post("/login")
async def login(request: dict):
    """Traditional email + password login"""
    email = request.get("email")
    password = request.get("password")
    # Validate credentials, return JWT
    return {"jwt": "xxx", "user": {...}}
```

### 4. Set Password
```python
@router.post("/set-password")
async def set_password(request: dict):
    """Set password for authenticated user"""
    # Requires valid JWT
    # Hash password, save to DB
    # Add 'password' to login_methods array
    return {"success": True}
```

### 5. Social Login (Google)
```python
@router.post("/auth/google")
async def google_login(request: dict):
    """Authenticate with Google OAuth token"""
    google_token = request.get("token")
    # Verify token with Google
    # Extract email, name, google_id
    # Check if user exists (by email or google_id)
    # If new: create user with auto-generated username
    # If existing: link Google account
    # Return JWT + user data
    return {"jwt": "xxx", "user": {...}, "is_new_user": False}
```

### 6. Social Login (Apple) 
```python
@router.post("/auth/apple")
async def apple_login(request: dict):
    """Authenticate with Apple Sign-In token"""
    apple_token = request.get("token")
    apple_id = request.get("user_id")
    # Verify token with Apple
    # Similar flow to Google
    # Handle Apple's privacy features (hide email)
    return {"jwt": "xxx", "user": {...}, "is_new_user": False}
```

## Mobile App Changes

### 1. Enhanced Login Screen
**Location:** `/home/mike/D/ufobeep/app/lib/screens/auth/login_screen.dart`
```dart
class LoginScreen extends StatefulWidget {
  // Social login buttons (primary)
  // - "Continue with Google" button
  // - "Continue with Apple" button (iOS only)
  // "Or use email" expandable section
  // - Email input field
  // - "Send Magic Link" button
  // - "Or login with password" expandable section
  // - Password field (if user has password set)
  // - "Login" button
}
```

### 2. Magic Link Handler  
**Location:** `/home/mike/D/ufobeep/app/lib/services/deep_link_service.dart`
```dart
// Handle https://ufobeep.com/auth/magic?token=xxx
// Extract token, call magic-login API
// Save JWT, navigate to main app
```

### 3. Social Login Services
**Location:** `/home/mike/D/ufobeep/app/lib/services/social_auth_service.dart`
```dart
class SocialAuthService {
  Future<GoogleSignInResult> signInWithGoogle() async {
    // Google Sign-In OAuth flow
    // Return user data + token
  }
  
  Future<AppleSignInResult> signInWithApple() async {
    // Apple Sign-In OAuth flow (iOS only)
    // Handle privacy features
  }
}
```

### 4. Account Security Screen
**Location:** `/home/mike/D/ufobeep/app/lib/screens/auth/account_security_screen.dart`
```dart
class AccountSecurityScreen extends StatefulWidget {
  // Shows after any first login
  // "Secure your account" header with current login methods
  // Options:
  // - Add password protection
  // - Link Google account (if not already)
  // - Link Apple account (if not already)
  // - Set up 2FA (future)
  // "I'm good for now" skip option
}
```

## Email Templates

### Magic Link Email
```html
<h2>🛸 Login to UFOBeep</h2>
<p>Hi {{username}},</p>
<p>Click the button below to securely login to your account:</p>
<a href="{{magic_link}}" style="background: #6366f1; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none;">
  Login to UFOBeep
</a>
<p><small>This link expires in 15 minutes and can only be used once.</small></p>
```

## User Experience Flow

### New User (Recommended: Social)
1. **Social Login:** Click "Continue with Google" → Google OAuth
2. **Auto Account:** Email/name extracted → Username auto-generated (e.g., "cosmic-whisper-7823")
3. **Welcome:** Account created instantly → Show security options
4. **Security:** "Add password?" OR "Link Apple?" OR "Continue as-is"

### New User (Email Alternative)
1. **Email:** Enter email → Username generated → Magic link sent
2. **Login:** Click link → Welcome → Security options prompt
3. **Choice:** Add social/password OR continue magic-link only

### Returning User (Social Priority)
1. **Social:** Click Google/Apple → Instant login (fastest)
2. **Password:** Email + password → Direct login (fast) 
3. **Magic Link:** Email → Click link → Login (secure backup)

### Account Linking
1. **Started with email:** Can add Google/Apple later
2. **Started with Google:** Can add Apple/password later  
3. **All methods:** Link to same cosmic username
4. **Flexibility:** Use any method, same account

### Account Recovery
1. **Forgot everything:** Magic link always works (sent to email)
2. **Lost device:** Social login works on new device
3. **Lost social:** Password or magic link backup
4. **Ultimate backup:** Contact support with verification

## Security Features

### Magic Link Security
- **Expiry:** 15 minutes (short-lived)
- **One-time use:** Token invalidated after use
- **Secure tokens:** Cryptographically random
- **Rate limiting:** Max 3 magic links per hour

### Password Security  
- **Hashing:** bcrypt with salt
- **Strength:** Minimum 8 characters
- **Rate limiting:** Max 5 login attempts per 15 minutes
- **Optional 2FA:** Future enhancement

### Session Management
- **JWT tokens:** 24 hour expiry with refresh
- **Device tracking:** Remember login method preference
- **Logout:** Invalidate all sessions option

## Implementation Priority

### Phase 1: Social Login Foundation (6-8 hours)
- [ ] Database migration for social auth fields
- [ ] Google OAuth integration (API + mobile)
- [ ] Apple Sign-In integration (iOS)
- [ ] Auto username generation from social profiles
- [ ] Account linking logic (email matching)

### Phase 2: Enhanced Login Screen (4-5 hours)
- [ ] New login UI with social buttons primary
- [ ] Google/Apple Sign-In widgets
- [ ] Fallback to email/magic link options
- [ ] Account security screen after first login

### Phase 3: Multi-Method Support (3-4 hours)  
- [ ] Password login API endpoints
- [ ] Magic link system (builds on MP14)
- [ ] JWT token management with multiple auth methods
- [ ] Account method preferences

### Phase 4: UX Polish (2-3 hours)
- [ ] Login method preferences and management
- [ ] Better error messages and loading states
- [ ] Account security recommendations
- [ ] Cross-device login experience

## Benefits

### User Experience
- **One-click registration** with Google/Apple (zero friction)
- **Familiar social login** most users expect
- **Multiple backup options** (email, password, magic link)
- **Never locked out** (magic link always works)
- **Cross-device seamless** with social accounts

### Security
- **Phishing resistant** (magic links are one-time)
- **No password reuse** issues initially
- **Email as second factor** for magic links
- **Progressive security** (upgrade when ready)

### Development
- **Builds on MP14** email verification system
- **Backward compatible** with existing usernames
- **Flexible architecture** for future auth methods

## Configuration Required

### Environment Variables
```bash
# Social login credentials
GOOGLE_CLIENT_ID=xxx
GOOGLE_CLIENT_SECRET=xxx
APPLE_TEAM_ID=xxx
APPLE_KEY_ID=xxx
APPLE_PRIVATE_KEY=xxx

# Magic link settings
MAGIC_LINK_EXPIRY_MINUTES=15
MAGIC_LINK_RATE_LIMIT_PER_HOUR=3

# JWT settings  
JWT_SECRET_KEY=xxx
JWT_EXPIRY_HOURS=24

# Password requirements
MIN_PASSWORD_LENGTH=8
REQUIRE_PASSWORD_SYMBOLS=false
```

### Email Provider
- Uses existing PostfixEmailService from MP14
- New template: `magic_link_login.html`
- Rate limiting to prevent abuse

## Testing Plan

### Test Scenarios
1. ✅ Google Sign-In → auto account creation → username generated
2. ✅ Apple Sign-In → auto account creation (iOS)
3. ✅ Existing email + Google → links to existing account
4. ✅ Social login → add password → both methods work
5. ✅ Request magic link → receive email → click → login
6. ✅ Magic link expires → shows error → request new one
7. ✅ Password login → direct access (faster)
8. ✅ Forgot password → magic link → reset password
9. ✅ Rate limiting → prevents magic link spam
10. ✅ Invalid tokens → proper error handling
11. ✅ Cross-device → same account, different devices

## Future Enhancements (MP16+)
- Two-factor authentication (SMS/TOTP)
- Biometric login (fingerprint/FaceID)
- Enterprise SSO support (SAML, OIDC)
- Advanced session management
- Social login expansion (Facebook, Twitter, etc.)
- Passwordless hardware keys (WebAuthn)