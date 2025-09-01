# Authentication Token Persistence Fix

## Problem Summary
Users could successfully log in with Google OAuth or Magic Link authentication, but when the app was closed and reopened, they were forced to log in again. The profile page showed "You are not logged in" despite tokens being present.

## Root Cause Analysis

The issue was caused by **dual Dio HTTP client instances** creating authentication header confusion:

### The Bug
```dart
// In ApiClient class
static final Dio dio = Dio(...);        // Line 33 - Static instance
late final Dio _dio;                     // Line 76 - Instance variable

// Auth token was set on static instance
static void setBearer(String access) {
  dio.options.headers['Authorization'] = 'Bearer $access';  // ✅ Set here
}

// But /me calls used the instance variable
Future<void> fetchMe() async {
  final res = await _dio.get('/me');     // ❌ No auth header here
}
```

### Additional Issues
1. **Wrong endpoint path**: AuthRepository called `/me` instead of `/users/me`
2. **Wrong response parsing**: Expected direct user data instead of `{user: {...}}`

## The Fix

### 1. Eliminate Dual Dio Instances
- **Removed** instance `_dio` variable completely
- **Updated all methods** to use static `ApiClient.dio`
- **Simplified architecture** to single HTTP client

### 2. Fix Endpoint and Response Parsing
```dart
// Before
final res = await _dio.get('/me');
_currentUser = UserModel.fromJson(res.data);

// After  
final res = await _dio.get('/users/me');
final userData = res.data['user'] as Map<String, dynamic>;
_currentUser = UserModel.fromJson(userData);
```

### 3. SecureStorage Implementation
Created new `SecureStorage` class with proper Android configuration:
```dart
static const _aOpts = AndroidOptions(
  encryptedSharedPreferences: true,  // Avoid keystore issues
  resetOnError: true,
);
```

## Implementation Details

### Files Modified
1. **`services/api_client.dart`**
   - Removed instance `_dio` variable and `_initializeDio()` method
   - Updated all HTTP calls to use `ApiClient.dio`
   - Simplified dispose method

2. **`services/auth_repository.dart`**
   - Fixed `fetchMe()` to call `/users/me` endpoint
   - Updated response parsing for correct JSON structure
   - Integrated with new SecureStorage system

3. **`services/secure_storage.dart`** (New)
   - Centralized token storage with Android encryption
   - Comprehensive logging for debugging

### API Endpoint Fix
The `/users/me` endpoint was also fixed to handle JWT tokens correctly:
```python
# Fixed JWT token parsing
user_id = payload.get("sub") or payload.get("user_id")
```

## Testing Results

### Before Fix
```
[Bootstrap] Starting session load
[Bootstrap] /me validation failed: DioException [bad response]: 404
[Bootstrap] Complete - ready=true, user=none
```

### After Fix  
```
[Bootstrap] Starting session load
[Bootstrap] Tokens found - validating with /me
[Bootstrap] Session restored successfully - user: astral.matrix.2804
[Bootstrap] Complete - ready=true, user=astral.matrix.2804
```

## Key Learnings

1. **Single HTTP Client**: Never maintain multiple Dio instances for the same API
2. **Proper Authorization**: Always verify auth headers are set on the correct client
3. **Endpoint Consistency**: Ensure mobile app calls match actual API paths
4. **Response Structure**: Parse JSON responses according to actual API format
5. **Android Storage**: Use `encryptedSharedPreferences` for reliability

## Token Flow (Fixed)

1. **Login**: Google/Magic Link → Backend returns JWT tokens
2. **Storage**: Tokens saved to `SecureStorage` with encryption
3. **Auth Header**: `ApiClient.setBearer()` sets `Authorization` header on static Dio
4. **Bootstrap**: `fetchMe()` calls `/users/me` with auth header
5. **Profile**: Shows authenticated state with real user data

## Deployment
- **Commit**: `7b23b0e6` - Fix dual Dio instance bug and wrong /me endpoint path
- **Tested**: Moto device - token persistence working
- **Status**: ✅ **RESOLVED**

## Prevention
- Always use single HTTP client per API
- Verify endpoint paths match backend routes  
- Test token persistence across app restarts
- Monitor authentication logs for validation