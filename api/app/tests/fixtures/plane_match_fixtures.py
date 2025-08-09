"""
Test fixtures for plane matching feature.
Provides synthetic data for testing in different scenarios.
"""

import json
from datetime import datetime, timezone
from typing import Dict, List, Any

from ...schemas.plane_match import SensorDataSchema, OpenSkyState


class PlaneMatchTestFixtures:
    """Test fixtures for plane matching scenarios"""
    
    # Test locations
    LOCATIONS = {
        # Near San Francisco International Airport (SFO) - high air traffic
        "sfo_area": {
            "name": "San Francisco Airport Area",
            "latitude": 37.6213,
            "longitude": -122.3790,
            "description": "High traffic area near major international airport",
        },
        
        # Rural area in Nevada - low air traffic  
        "nevada_rural": {
            "name": "Rural Nevada",
            "latitude": 39.1637,
            "longitude": -117.0021,
            "description": "Remote desert area with minimal air traffic",
        },
        
        # Los Angeles area - medium air traffic with varied altitudes
        "lax_area": {
            "name": "Los Angeles Area", 
            "latitude": 34.0522,
            "longitude": -118.2437,
            "description": "Urban area with moderate air traffic",
        }
    }
    
    @classmethod
    def get_test_sensor_data(
        self,
        location: str = "sfo_area",
        azimuth: float = 45.0,
        pitch: float = 30.0,
        timestamp: datetime = None
    ) -> SensorDataSchema:
        """Generate sensor data for specified location and pointing direction"""
        
        if timestamp is None:
            timestamp = datetime.now(timezone.utc)
            
        loc = self.LOCATIONS[location]
        
        return SensorDataSchema(
            utc=timestamp,
            latitude=loc["latitude"],
            longitude=loc["longitude"],
            azimuth_deg=azimuth,
            pitch_deg=pitch,
            roll_deg=2.1,
            hfov_deg=66.0,
            accuracy=3.5,
            altitude=150.0  # Approximate ground elevation
        )
    
    @classmethod
    def get_mock_opensky_response(self, scenario: str) -> Dict[str, Any]:
        """Get mock OpenSky API response for different test scenarios"""
        
        base_time = int(datetime.now(timezone.utc).timestamp())
        
        scenarios = {
            # High traffic scenario - multiple aircraft
            "high_traffic": {
                "time": base_time,
                "states": [
                    # United Airlines flight - high altitude, matching user's view direction
                    ["ac82ec", "UAL1234 ", "United States", base_time-10, base_time-5, 
                     -122.3200, 37.6800, 10668.0, False, 254.8, 45.2, 0.0, None, 11582.4, "2451", False, 0],
                    
                    # Southwest flight - medium altitude, different direction  
                    ["a9c4b1", "SWA567  ", "United States", base_time-15, base_time-8,
                     -122.4100, 37.6500, 7620.0, False, 198.3, 120.5, -2.1, None, 8230.2, "1200", False, 0],
                     
                    # Private aircraft - low altitude, close to user view
                    ["a1b2c3", "N123AB  ", "United States", base_time-5, base_time-2,
                     -122.3600, 37.6400, 1524.0, False, 145.2, 48.8, 1.3, None, 1676.4, "1200", False, 0],
                     
                    # Cargo flight - very high altitude
                    ["abc123", "FDX9876 ", "United States", base_time-20, base_time-12,
                     -122.3950, 37.6150, 12497.0, False, 412.3, 225.7, 0.0, None, 13106.4, "2000", False, 0],
                ]
            },
            
            # Low traffic scenario - single distant aircraft
            "low_traffic": {
                "time": base_time,
                "states": [
                    # Single aircraft - far from user's view direction
                    ["xyz789", "N456CD  ", "United States", base_time-30, base_time-25,
                     -117.1000, 39.2000, 9144.0, False, 287.5, 180.0, 0.0, None, 9753.6, "1200", False, 0],
                ]
            },
            
            # No aircraft scenario
            "no_aircraft": {
                "time": base_time,
                "states": []
            },
            
            # Perfect match scenario - aircraft exactly where user is looking
            "perfect_match": {
                "time": base_time,
                "states": [
                    # Aircraft positioned exactly in user's line of sight
                    ["perfect", "TEST123 ", "United States", base_time-5, base_time-2,
                     -122.3100, 37.6400, 8000.0, False, 200.0, 45.0, 0.0, None, 8534.4, "1200", False, 0],
                ]
            },
            
            # Edge case - aircraft on ground 
            "ground_aircraft": {
                "time": base_time,
                "states": [
                    # Aircraft on ground at airport
                    ["ground1", "DAL456  ", "United States", base_time-10, base_time-5,
                     -122.3790, 37.6213, 0.0, True, 0.0, 270.0, 0.0, None, 45.7, "1200", False, 0],
                ]
            },
            
            # Multiple close matches - test confidence scoring
            "multiple_candidates": {
                "time": base_time,
                "states": [
                    # Very close match - high confidence expected
                    ["close1", "AAL789  ", "United States", base_time-5, base_time-2,
                     -122.3150, 37.6350, 9144.0, False, 180.2, 44.8, 0.0, None, 9600.5, "1200", False, 0],
                     
                    # Decent match - medium confidence
                    ["close2", "VIR100  ", "United Kingdom", base_time-8, base_time-3,
                     -122.3250, 37.6450, 10668.0, False, 195.7, 47.2, 0.0, None, 11200.3, "2000", False, 0],
                     
                    # Poor match - low confidence  
                    ["far1", "BAW200   ", "United Kingdom", base_time-12, base_time-7,
                     -122.3400, 37.6200, 11582.4, False, 156.3, 52.1, 0.0, None, 12100.8, "2451", False, 0],
                ]
            }
        }
        
        return scenarios.get(scenario, scenarios["no_aircraft"])
    
    @classmethod
    def get_test_scenarios(self) -> List[Dict[str, Any]]:
        """Get comprehensive test scenarios for automated testing"""
        
        return [
            {
                "name": "High Traffic Airport Area - Perfect Match",
                "description": "User at SFO area looking at aircraft with perfect alignment",
                "sensor_data": self.get_test_sensor_data("sfo_area", azimuth=45.0, pitch=30.0),
                "opensky_response": self.get_mock_opensky_response("perfect_match"),
                "expected_result": {
                    "is_plane": True,
                    "confidence_min": 0.8,
                    "should_have_callsign": True,
                },
            },
            
            {
                "name": "Rural Area - No Aircraft",
                "description": "User in remote Nevada with no air traffic",
                "sensor_data": self.get_test_sensor_data("nevada_rural", azimuth=90.0, pitch=45.0),
                "opensky_response": self.get_mock_opensky_response("no_aircraft"),
                "expected_result": {
                    "is_plane": False,
                    "confidence_min": 0.0,
                    "should_have_callsign": False,
                },
            },
            
            {
                "name": "LA Area - Multiple Candidates",
                "description": "Urban area with multiple aircraft, test confidence ranking",
                "sensor_data": self.get_test_sensor_data("lax_area", azimuth=45.0, pitch=30.0),
                "opensky_response": self.get_mock_opensky_response("multiple_candidates"),
                "expected_result": {
                    "is_plane": True,
                    "confidence_min": 0.6,
                    "should_have_callsign": True,
                    "expected_callsign_prefix": "AAL",  # Should pick closest match
                },
            },
            
            {
                "name": "Airport Area - Ground Aircraft",
                "description": "Aircraft on ground should not match sky objects",
                "sensor_data": self.get_test_sensor_data("sfo_area", azimuth=270.0, pitch=20.0),
                "opensky_response": self.get_mock_opensky_response("ground_aircraft"),
                "expected_result": {
                    "is_plane": False,  # Ground aircraft shouldn't match sky objects
                    "confidence_min": 0.0,
                    "should_have_callsign": False,
                },
            },
            
            {
                "name": "High Traffic - Poor Angular Alignment", 
                "description": "Multiple aircraft but none aligned with user's view",
                "sensor_data": self.get_test_sensor_data("sfo_area", azimuth=0.0, pitch=10.0),  # Looking north, low pitch
                "opensky_response": self.get_mock_opensky_response("high_traffic"),
                "expected_result": {
                    "is_plane": False,  # No aircraft should be within tolerance
                    "confidence_min": 0.0,
                    "should_have_callsign": False,
                },
            },
            
            {
                "name": "Edge Case - Very High Pitch",
                "description": "User looking straight up (zenith)",
                "sensor_data": self.get_test_sensor_data("sfo_area", azimuth=180.0, pitch=85.0),
                "opensky_response": self.get_mock_opensky_response("high_traffic"),
                "expected_result": {
                    "is_plane": False,  # Unlikely to have aircraft at such high angle
                    "confidence_min": 0.0,
                    "should_have_callsign": False,
                },
            },
        ]
    
    @classmethod
    def save_fixtures_to_file(self, filepath: str):
        """Save all test fixtures to JSON file for use in tests"""
        
        fixtures = {
            "locations": self.LOCATIONS,
            "scenarios": self.get_test_scenarios(),
            "opensky_responses": {
                scenario: self.get_mock_opensky_response(scenario)
                for scenario in ["high_traffic", "low_traffic", "no_aircraft", 
                               "perfect_match", "ground_aircraft", "multiple_candidates"]
            }
        }
        
        # Convert datetime objects to ISO strings for JSON serialization
        def datetime_handler(obj):
            if isinstance(obj, datetime):
                return obj.isoformat()
            raise TypeError(f"Object of type {type(obj)} is not JSON serializable")
        
        with open(filepath, 'w') as f:
            json.dump(fixtures, f, indent=2, default=datetime_handler)


# Convenience functions for direct import
def get_sfo_sensor_data() -> SensorDataSchema:
    """Quick access to SFO area sensor data"""
    return PlaneMatchTestFixtures.get_test_sensor_data("sfo_area")

def get_perfect_match_scenario() -> Dict[str, Any]:
    """Quick access to perfect match test scenario"""
    fixtures = PlaneMatchTestFixtures()
    return {
        "sensor_data": fixtures.get_test_sensor_data("sfo_area", 45.0, 30.0),
        "opensky_response": fixtures.get_mock_opensky_response("perfect_match")
    }

def get_no_aircraft_scenario() -> Dict[str, Any]:
    """Quick access to no aircraft test scenario"""
    fixtures = PlaneMatchTestFixtures()
    return {
        "sensor_data": fixtures.get_test_sensor_data("nevada_rural", 90.0, 45.0),
        "opensky_response": fixtures.get_mock_opensky_response("no_aircraft")
    }


if __name__ == "__main__":
    # Generate test fixtures file
    fixtures = PlaneMatchTestFixtures()
    fixtures.save_fixtures_to_file("plane_match_test_fixtures.json")
    print("Test fixtures saved to plane_match_test_fixtures.json")