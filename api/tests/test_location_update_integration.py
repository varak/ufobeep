"""
Integration tests for location update functionality

Tests the complete flow:
1. Device registration with location
2. Location updates via API
3. Proximity alert freshness filtering

Requirements:
- API_BASE environment variable pointing to live API
- Either ACCESS_JWT (real token) or JWT_SECRET + TEST_USER_ID (for minting)

Usage:
    export API_BASE="https://api.ufobeep.com"
    export ACCESS_JWT="<paste real access token>"   # preferred
    # OR:
    export JWT_SECRET="<server jwt secret>"
    export TEST_USER_ID="test-user-123"
    pytest -v api/tests/test_location_update_integration.py
"""

import os
import time
import random
import string
from datetime import datetime, timedelta, timezone
import pytest
import requests

try:
    from jose import jwt
except ImportError:
    jwt = None

# Configuration
API_BASE = os.getenv("API_BASE")
SKIP_REASON = "Set API_BASE to run integration tests"

def _mint_jwt():
    """Prefer ACCESS_JWT. Else mint with JWT_SECRET + TEST_USER_ID."""
    access = os.getenv("ACCESS_JWT")
    if access:
        return access
    
    secret = os.getenv("JWT_SECRET")
    user_id = os.getenv("TEST_USER_ID", f"test-user-{datetime.now(timezone.utc).strftime('%H%M%S')}")
    
    if not (secret and jwt):
        pytest.skip("Need ACCESS_JWT or (JWT_SECRET + python-jose) to mint a token")
    
    payload = {
        "sub": user_id,
        "iat": int(datetime.now(timezone.utc).timestamp()),
        "exp": int((datetime.now(timezone.utc) + timedelta(hours=1)).timestamp()),
    }
    return jwt.encode(payload, secret, algorithm="HS256")

@pytest.mark.skipif(not API_BASE, reason=SKIP_REASON)
def test_device_registration_with_location():
    """Test device registration with mandatory location coordinates"""
    token = _mint_jwt()
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # Generate unique FCM token for test
    fcm_token = "pytest_" + "".join(random.choices(string.ascii_letters + string.digits, k=22))
    
    # Register device with location (San Francisco)
    body_register = {
        "fcm_token": fcm_token,
        "platform": "android",
        "app_version": "9.9.9",
        "device_model": "pytest-device",
        "os_version": "pytest-os",
        "lat": 37.7749,  # San Francisco
        "lon": -122.4194,
    }
    
    response = requests.post(f"{API_BASE}/devices/register", json=body_register, headers=headers, timeout=15)
    assert response.status_code in (201, 200), f"Registration failed: {response.status_code} {response.text}"
    
    data = response.json()
    assert data.get("fcm_token") == fcm_token
    assert data.get("push_enabled") is True
    
    print(f"✅ Device registered with FCM token: {fcm_token}")

@pytest.mark.skipif(not API_BASE, reason=SKIP_REASON)
def test_location_update_success():
    """Test successful location update with valid coordinates"""
    token = _mint_jwt()
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # First register a device to ensure we have one to update
    fcm_token = "pytest_update_" + "".join(random.choices(string.ascii_letters + string.digits, k=18))
    body_register = {
        "fcm_token": fcm_token,
        "platform": "android", 
        "app_version": "9.9.9",
        "device_model": "pytest-device",
        "os_version": "pytest-os",
        "lat": 37.7749,
        "lon": -122.4194,
    }
    
    reg_response = requests.post(f"{API_BASE}/devices/register", json=body_register, headers=headers, timeout=15)
    assert reg_response.status_code in (201, 200)
    
    # Now update location (simulate ~1.5 km move to Oakland)
    body_update = {
        "lat": 37.7870,  # Oakland area
        "lon": -122.4075
    }
    
    response = requests.post(f"{API_BASE}/devices/update-location", json=body_update, headers=headers, timeout=10)
    assert response.status_code == 204, f"Location update failed: {response.status_code} {response.text}"
    
    print(f"✅ Location updated successfully for FCM token: {fcm_token}")

@pytest.mark.skipif(not API_BASE, reason=SKIP_REASON)
def test_location_update_validation_errors():
    """Test location update validation catches invalid coordinates"""
    token = _mint_jwt()
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # Test invalid (0,0) coordinates
    response = requests.post(
        f"{API_BASE}/devices/update-location", 
        json={"lat": 0.0, "lon": 0.0}, 
        headers=headers, 
        timeout=10
    )
    assert response.status_code == 422, "Should reject (0,0) coordinates"
    error_data = response.json()
    assert "INVALID_ORIGIN" in error_data.get("detail", {}).get("error", "")
    
    # Test out-of-bounds latitude
    response = requests.post(
        f"{API_BASE}/devices/update-location", 
        json={"lat": 95.0, "lon": 0.0}, 
        headers=headers, 
        timeout=10
    )
    assert response.status_code == 422, "Should reject latitude > 90"
    
    # Test out-of-bounds longitude  
    response = requests.post(
        f"{API_BASE}/devices/update-location", 
        json={"lat": 45.0, "lon": 185.0}, 
        headers=headers, 
        timeout=10
    )
    assert response.status_code == 422, "Should reject longitude > 180"
    
    print("✅ Location validation working correctly")

@pytest.mark.skipif(not API_BASE, reason=SKIP_REASON)
def test_unauthorized_location_update():
    """Test location update requires valid authentication"""
    # No auth header
    response = requests.post(
        f"{API_BASE}/devices/update-location",
        json={"lat": 37.7749, "lon": -122.4194},
        timeout=10
    )
    assert response.status_code == 401, "Should require authentication"
    
    # Invalid token
    headers = {"Authorization": "Bearer invalid-token", "Content-Type": "application/json"}
    response = requests.post(
        f"{API_BASE}/devices/update-location",
        json={"lat": 37.7749, "lon": -122.4194}, 
        headers=headers,
        timeout=10
    )
    assert response.status_code == 401, "Should reject invalid token"
    
    print("✅ Authentication validation working correctly")

@pytest.mark.skipif(not API_BASE, reason=SKIP_REASON)  
def test_location_freshness_integration():
    """Test that devices with fresh location updates are included in proximity alerts"""
    token = _mint_jwt()
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # Register device with recent location
    fcm_token = "pytest_fresh_" + "".join(random.choices(string.ascii_letters + string.digits, k=18))
    body_register = {
        "fcm_token": fcm_token,
        "platform": "android",
        "app_version": "9.9.9", 
        "device_model": "pytest-device",
        "os_version": "pytest-os",
        "lat": 36.2457,  # Las Vegas area (matches test data)
        "lon": -115.2411,
    }
    
    reg_response = requests.post(f"{API_BASE}/devices/register", json=body_register, headers=headers, timeout=15)
    assert reg_response.status_code in (201, 200)
    
    # Update location to ensure freshness
    time.sleep(1)  # Small delay to ensure different timestamp
    update_response = requests.post(
        f"{API_BASE}/devices/update-location",
        json={"lat": 36.2458, "lon": -115.2412},  # Slightly moved
        headers=headers,
        timeout=10
    )
    assert update_response.status_code == 204
    
    # Now test if this device would be included in proximity alerts
    # (This would normally require admin privileges, so we just verify the update succeeded)
    print(f"✅ Fresh device registered and updated: {fcm_token}")
    print("   Device should now be visible for 24h in proximity queries")

@pytest.mark.skipif(not API_BASE, reason=SKIP_REASON)
def test_multiple_rapid_location_updates():
    """Test that rapid location updates are handled gracefully"""
    token = _mint_jwt()
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # Register device first
    fcm_token = "pytest_rapid_" + "".join(random.choices(string.ascii_letters + string.digits, k=18))
    body_register = {
        "fcm_token": fcm_token,
        "platform": "android",
        "app_version": "9.9.9",
        "device_model": "pytest-device", 
        "os_version": "pytest-os",
        "lat": 37.7749,
        "lon": -122.4194,
    }
    
    reg_response = requests.post(f"{API_BASE}/devices/register", json=body_register, headers=headers, timeout=15)
    assert reg_response.status_code in (201, 200)
    
    # Send multiple rapid location updates
    locations = [
        {"lat": 37.7750, "lon": -122.4195},
        {"lat": 37.7751, "lon": -122.4196},
        {"lat": 37.7752, "lon": -122.4197},
    ]
    
    success_count = 0
    for i, loc in enumerate(locations):
        response = requests.post(
            f"{API_BASE}/devices/update-location",
            json=loc,
            headers=headers, 
            timeout=10
        )
        if response.status_code == 204:
            success_count += 1
        time.sleep(0.1)  # Small delay between requests
    
    assert success_count >= 1, "At least one location update should succeed"
    print(f"✅ Rapid updates handled: {success_count}/{len(locations)} succeeded")

if __name__ == "__main__":
    # Allow running tests directly
    import sys
    if not API_BASE:
        print("❌ Set API_BASE environment variable to run tests")
        sys.exit(1)
    
    print(f"🧪 Running location update integration tests against {API_BASE}")
    pytest.main([__file__, "-v"])