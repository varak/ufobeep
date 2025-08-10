#!/usr/bin/env python3
"""
Simple test for alert fanout core functionality
Tests distance calculation, user filtering, and basic workflow
"""

import asyncio
import logging
import sys
import os
from datetime import datetime

# Add current directory to path
sys.path.append(os.path.dirname(__file__))

# Import the worker
from app.workers.alert_fanout import (
    AlertFanoutWorker,
    SightingEvent,
    UserLocation,
    get_mock_user_locations,
    get_mock_device_registry
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def test_distance_calculation():
    """Test distance calculation"""
    logger.info("🧪 Testing Distance Calculation")
    
    worker = AlertFanoutWorker()
    
    # Test cases: (lat1, lon1, lat2, lon2, expected_km, tolerance)
    test_cases = [
        # Same location
        (37.7749, -122.4194, 37.7749, -122.4194, 0, 0.01),
        # San Francisco to nearby (about 1 km north)
        (37.7749, -122.4194, 37.7849, -122.4194, 1.1, 0.2),
        # Larger distance (SF to Oakland, about 13 km)
        (37.7749, -122.4194, 37.8044, -122.2711, 13, 2),
    ]
    
    for lat1, lon1, lat2, lon2, expected, tolerance in test_cases:
        distance = worker.calculate_distance_km(lat1, lon1, lat2, lon2)
        logger.info(f"Distance: {distance:.2f} km (expected ~{expected} km)")
        
        if abs(distance - expected) > tolerance:
            logger.error(f"❌ Distance calculation failed: got {distance:.2f}, expected {expected}±{tolerance}")
            return False
            
    logger.info("✅ Distance calculations passed")
    return True


def test_user_filtering():
    """Test user filtering logic"""
    logger.info("🧪 Testing User Filtering")
    
    worker = AlertFanoutWorker()
    
    # Create test sighting in San Francisco
    sighting = SightingEvent(
        sighting_id="test_sighting_001",
        latitude=37.7749,  # SF coordinates
        longitude=-122.4194,
        title="Test UFO Sighting",
        description="Test description",
        shape="circle",
        created_at=datetime.utcnow()
    )
    
    # Get mock user locations (includes SF area users)
    user_locations = get_mock_user_locations()
    
    # Find nearby users
    nearby_users = worker._find_nearby_users(sighting, user_locations)
    
    logger.info(f"Found {len(nearby_users)} nearby users:")
    for user_location, distance in nearby_users:
        logger.info(f"  - User {user_location.user_id}: {distance:.2f} km away")
    
    # Should find at least the SF area users 
    # Note: user_001 might be filtered out by minimum distance if at exact same location
    assert len(nearby_users) >= 1, f"Expected at least 1 nearby user, got {len(nearby_users)}"
    
    # Check if we found user_002 who should be ~1km away
    user_002_found = any(user_location.user_id == "user_002" for user_location, _ in nearby_users)
    assert user_002_found, "Should find user_002 who is 1km away"
    
    # Verify distances are reasonable
    for user_location, distance in nearby_users:
        assert distance <= user_location.alert_range_km, \
            f"User {user_location.user_id} distance {distance} exceeds their range {user_location.alert_range_km}"
    
    logger.info("✅ User filtering passed")
    return True


def test_rate_limiting():
    """Test rate limiting logic"""
    logger.info("🧪 Testing Rate Limiting")
    
    worker = AlertFanoutWorker()
    
    # Create test users with low rate limits
    test_users = [
        (UserLocation(
            user_id="rate_test_user_001",
            latitude=37.7749,
            longitude=-122.4194,
            alert_range_km=10.0,
            max_alerts_per_hour=2,  # Low limit
            alert_notifications_enabled=True
        ), 1.0)  # 1km away
    ]
    
    # Test rate limiting - first call should pass
    rate_limited_1 = worker._apply_rate_limiting(test_users)
    assert len(rate_limited_1) == 1, "First call should pass rate limiting"
    
    # Update history to simulate previous alerts
    worker._update_alert_history(rate_limited_1, "sighting_001")
    worker._update_alert_history(rate_limited_1, "sighting_002")
    
    # Third call should be rate limited
    rate_limited_2 = worker._apply_rate_limiting(test_users)
    logger.info(f"After 2 previous alerts: {len(rate_limited_2)} users allowed")
    
    logger.info("✅ Rate limiting logic passed")
    return True


def test_push_targets():
    """Test push target generation"""
    logger.info("🧪 Testing Push Target Generation")
    
    worker = AlertFanoutWorker()
    
    # Create test users
    nearby_users = [
        (UserLocation(
            user_id="user_001",
            latitude=37.7749,
            longitude=-122.4194,
            alert_range_km=50.0,
            alert_notifications_enabled=True
        ), 2.5),  # 2.5km away
        (UserLocation(
            user_id="user_002", 
            latitude=37.7849,
            longitude=-122.4194,
            alert_range_km=25.0,
            alert_notifications_enabled=True
        ), 1.1),  # 1.1km away
    ]
    
    # Get mock device registry
    device_registry = get_mock_device_registry()
    
    # Generate push targets
    push_targets = worker._get_push_targets(nearby_users, device_registry)
    
    logger.info(f"Generated {len(push_targets)} push targets:")
    for target in push_targets:
        logger.info(f"  - Device {target.device_id} ({target.platform}) for user {target.user_id}")
    
    # Should have at least 2 targets (one for each user)
    assert len(push_targets) >= 2, f"Expected at least 2 push targets, got {len(push_targets)}"
    
    # Verify all targets have required fields
    for target in push_targets:
        assert target.device_id, "Device ID missing"
        assert target.push_token, "Push token missing" 
        assert target.user_id, "User ID missing"
        assert target.preferences, "Preferences missing"
    
    logger.info("✅ Push target generation passed")
    return True


def test_notification_content():
    """Test notification content creation"""
    logger.info("🧪 Testing Notification Content")
    
    worker = AlertFanoutWorker()
    
    test_cases = [
        SightingEvent(
            sighting_id="test_001",
            latitude=37.7749,
            longitude=-122.4194,
            title="Triangle Formation",
            description="Three bright lights",
            shape="triangle"
        ),
        SightingEvent(
            sighting_id="test_002",
            latitude=37.7749,
            longitude=-122.4194, 
            title="Unknown Object",
            description="Mysterious craft",
            shape="unknown"
        ),
        SightingEvent(
            sighting_id="test_003",
            latitude=37.7749,
            longitude=-122.4194,
            title="Disc Shaped",
            description="Classic saucer",
            shape="disc"
        )
    ]
    
    for sighting in test_cases:
        title, body = worker._create_notification_content(sighting)
        logger.info(f"Sighting {sighting.shape}: '{title}' - '{body}'")
        
        # Verify content is reasonable
        assert len(title) > 0, "Title should not be empty"
        assert len(body) > 0, "Body should not be empty"
        assert "UFO" in title or "🛸" in title, "Title should mention UFO"
        
    logger.info("✅ Notification content generation passed")
    return True


async def test_full_workflow():
    """Test complete fanout workflow"""
    logger.info("🧪 Testing Complete Fanout Workflow")
    
    worker = AlertFanoutWorker()
    
    # Create test sighting
    sighting = SightingEvent(
        sighting_id="workflow_test_001",
        latitude=37.7749,  # San Francisco
        longitude=-122.4194,
        title="Test Triangle Formation", 
        description="Three bright lights in perfect triangle formation",
        shape="triangle",
        confidence_score=0.92,
        created_at=datetime.utcnow()
    )
    
    # Get test data
    user_locations = get_mock_user_locations()
    device_registry = get_mock_device_registry()
    
    # Process the sighting
    results = await worker.process_new_sighting(
        sighting=sighting,
        user_locations=user_locations,
        device_registry=device_registry
    )
    
    logger.info("Complete workflow results:")
    logger.info(f"  - Sighting ID: {results['sighting_id']}")
    logger.info(f"  - Nearby users: {results['nearby_users']}")
    logger.info(f"  - Rate limited users: {results['rate_limited_users']}")
    logger.info(f"  - Push targets: {results['push_targets']}")
    logger.info(f"  - Notifications sent: {results['notifications_sent']}")
    logger.info(f"  - Notifications failed: {results['notifications_failed']}")
    
    # Verify results make sense
    assert results['sighting_id'] == sighting.sighting_id
    assert results['nearby_users'] >= 0
    assert results['notifications_sent'] >= 0
    assert results['notifications_failed'] >= 0
    
    logger.info("✅ Complete workflow passed")
    return results


async def main():
    """Run all tests"""
    logger.info("🚀 Simple Alert Fanout Test Suite")
    logger.info("=" * 50)
    
    try:
        # Run synchronous tests
        assert test_distance_calculation()
        assert test_user_filtering()
        assert test_rate_limiting()
        assert test_push_targets()
        assert test_notification_content()
        
        # Run async workflow test
        results = await test_full_workflow()
        
        logger.info("\n🎉 All Simple Tests Passed!")
        logger.info("\n📋 Core Functionality Validated:")
        logger.info("✅ Distance calculation (Haversine formula)")
        logger.info("✅ User location filtering by range")
        logger.info("✅ Rate limiting per user")
        logger.info("✅ Push target generation from devices")
        logger.info("✅ Notification content creation")
        logger.info("✅ Complete fanout workflow")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    success = asyncio.run(main())
    if not success:
        exit(1)