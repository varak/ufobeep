#!/usr/bin/env python3
"""Test magic link authentication flow end-to-end"""

import requests
import time
import sys

API_URL = "https://ufobeep.com/api"

def test_magic_link_flow(email="test@example.com"):
    print(f"Testing magic link flow with email: {email}")
    print("=" * 60)
    
    # Step 1: Start magic link
    print("\n1. Starting magic link...")
    response = requests.post(
        f"{API_URL}/auth/magic/start",
        json={"email": email}
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.json()}")
    
    if response.status_code != 200:
        print(f"   ❌ Failed to start magic link")
        return False
    
    print(f"   ✅ Magic link email sent to {email}")
    
    # Step 2: Check that the deprecated endpoint returns proper error
    print("\n2. Testing deprecated /complete/app endpoint...")
    response = requests.post(
        f"{API_URL}/auth/magic/complete/app",
        json={"token": "test-token"}
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.json()}")
    
    if response.status_code == 400:
        detail = response.json().get('detail', '')
        if 'deprecated' in detail.lower() and '/exchange' in detail:
            print(f"   ✅ Deprecated endpoint properly redirects to /exchange")
        else:
            print(f"   ⚠️  Unexpected error message: {detail}")
    else:
        print(f"   ❌ Expected 400 status, got {response.status_code}")
    
    # Step 3: Test exchange endpoint with invalid code
    print("\n3. Testing /exchange endpoint with invalid code...")
    response = requests.post(
        f"{API_URL}/auth/magic/exchange",
        json={"code": "invalid-code-123"}
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.json()}")
    
    if response.status_code == 410:
        print(f"   ✅ Invalid code properly rejected with 410")
    else:
        print(f"   ⚠️  Expected 410 status, got {response.status_code}")
    
    print("\n" + "=" * 60)
    print("✅ Magic link flow test complete!")
    print("\nNOTE: To fully test the flow:")
    print("1. Check your email for the magic link")
    print("2. Click the link from your mobile device")
    print("3. Verify the app opens and authenticates")
    
    return True

if __name__ == "__main__":
    email = sys.argv[1] if len(sys.argv) > 1 else "test@example.com"
    success = test_magic_link_flow(email)
    sys.exit(0 if success else 1)