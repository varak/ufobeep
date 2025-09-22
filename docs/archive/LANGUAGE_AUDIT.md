# Language Support Audit - Authentication & Startup Screens

## Problem Statement
Critical user-facing screens (startup, login, registration) contain **50+ hardcoded English strings**. International users see English text during their first app experience instead of their native language.

## Affected Screens (Complete Audit)

### Primary Auth Screens
1. **`splash_screen.dart`** - App startup/loading (9 hardcoded strings)
2. **`sign_in_screen.dart`** - Main login page (NEED TO AUDIT)
3. **`firebase_email_auth_screen.dart`** - Email verification (15+ strings)
4. **`firebase_phone_auth_screen.dart`** - Phone verification (20+ strings)
5. **`account_recovery_screen.dart`** - Account recovery (NEED TO AUDIT)
6. **`phone_setup_screen.dart`** - Phone setup flow (NEED TO AUDIT)

### Hardcoded Text Found So Far

#### Splash Screen (9 strings)
- `'Real-time sighting alerts'` - App tagline
- `'Starting up...'` - Loading state
- `'Initialization failed'` - Error state
- `'Initialization Failed'` - Error dialog title
- `'The app failed to initialize properly:'` - Error explanation
- `'Retry'` - Retry button
- `'Continue'` - Continue button
- `'Initializing...'` - Footer loading text
- `'OK'` - Dialog confirmation

#### Email Auth Screen (15+ strings)
**Headers & Labels:**
- `'Email Verification'` - App bar title
- `'Verify Your Email'` - Main header
- `'Email Address'` - Input label
- `'your.email@example.com'` - Placeholder text

**Instructions & Descriptions:**
- `'Add your email address for account recovery and security. We'll send you a secure sign-in link.'`
- `'Check your email and tap the verification link to continue.'`
- `'How Email Verification Works'`
- `'1. We send you a secure sign-in link\n2. Check your email and tap the link\n3. Your email gets verified automatically\n4. No passwords needed!'`
- `'Email verification helps secure your account and enables account recovery if you lose access to your device.'`

**Buttons & Actions:**
- `'Send Verification Email'` / `'Resend Email'`

**Error Messages (6 different Firebase errors):**
- `'Invalid email address. Please check the format.'`
- `'No account found with this email address.'`
- `'Too many attempts. Please try again later.'`
- `'Email link sign-in is not enabled.'`
- `'Email quota exceeded. Please try again tomorrow.'`
- `'Email verification failed. Please try again.'`

**Form Validation:**
- `'Please enter your email address'`
- `'Please enter a valid email address'`
- `'Failed to send email'` / `'Failed to send email. Please try again.'`

#### Phone Auth Screen (20+ strings)
**Headers & Labels:**
- `'Phone Verification'` - App bar title
- `'Verify Your Phone'` / `'Enter Verification Code'` - Dynamic header
- `'Phone Number'` / `'Verification Code'` - Input labels
- `'+1 (555) 123-4567'` - Phone placeholder

**Instructions:**
- `'Add your phone number for account recovery and security'`
- `'Enter the 6-digit code sent to {phoneNumber}'`
- `'We'll send you a verification code via SMS. Standard message rates may apply.'`
- `'Code expires in 60 seconds. Check your messages.'`

**Buttons & Actions:**
- `'Send Verification Code'` / `'Verify Code'`
- `'Resend Code'` / `'Change Phone Number'`

**Success/Status Messages:**
- `'Phone number verified: {phoneNumber}'`
- `'Verification code resent'`

**Form Validation:**
- `'Please enter your phone number'`
- `'Please enter a valid phone number'`
- `'Please enter the 6-digit code'`

**Error Messages (8 different Firebase errors):**
- `'Invalid phone number. Please check the format.'`
- `'Too many attempts. Please try again later.'`
- `'Invalid verification code. Please check and try again.'`
- `'Verification session expired. Please request a new code.'`
- `'SMS quota exceeded. Please try again tomorrow.'`
- `'This phone number is already linked to another account.'`
- `'Verification failed. Please try again.'`
- `'Failed to send verification code. Please try again.'`
- `'Invalid verification code. Please try again.'`
- `'Phone verification failed. Please try again.'`
- `'Failed to resend code. Please try again.'`

## Additional Auth Screens Found (Need Full Audit)
- **`sign_in_screen.dart`** - Main login page (Google sign-in, magic links)
- **`account_recovery_screen.dart`** - Account recovery flow
- **`phone_setup_screen.dart`** - Phone setup flow

## Partial Sign-In Screen Audit (First 100 lines)
**Already found hardcoded text:**
- `'Welcome {username}!'` - Success message
- `'Sign-in failed: {error}'` - Error message
- Magic link and Google auth flows with more hardcoded text

**Estimated additional strings**: 15+ more in remaining sign-in screen content

## Estimated Scope
- **Current count**: 50+ hardcoded strings identified
- **Projected total**: 70+ strings across all auth screens
- **Translation keys needed**: 70+ new entries in app_en.arb
- **Affected screens**: 6 critical user-facing screens

## Implementation Complexity

### High Risk Areas
- **Error message mapping** - Firebase errors need consistent translations
- **Dynamic text** - Messages with variables (phone numbers, emails)
- **Conditional text** - Different messages based on state
- **Form validation** - Input validation messages
- **Success/failure states** - Status messaging

### Language Detection Requirements
- **Phone language detection** before user sets preferences
- **Fallback logic** for unsupported languages
- **Language switching** during auth flow
- **Persistence** across app restarts

## Recommendation
This is a **major internationalization project** requiring:
1. **Complete audit** of remaining auth screens
2. **Comprehensive translation key planning** (70+ keys)
3. **Systematic implementation** with testing
4. **Language detection strategy**
5. **Error handling for translation failures**

**This should be a dedicated sprint/task** to ensure it's done properly without breaking existing functionality.