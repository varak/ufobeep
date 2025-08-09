"""
Unit tests for plane matching functionality using synthetic fixtures.
"""

import pytest
from unittest.mock import AsyncMock, patch
from datetime import datetime, timezone

from ..services.plane_match_service import PlaneMatchService
from ..schemas.plane_match import SensorDataSchema, OpenSkyResponse
from .fixtures.plane_match_fixtures import PlaneMatchTestFixtures


class TestPlaneMatchService:
    """Test plane matching service with synthetic data"""
    
    @pytest.fixture
    def plane_match_service(self):
        """Create a plane match service instance"""
        return PlaneMatchService()
    
    @pytest.fixture
    def mock_opensky_client(self):
        """Mock HTTP client for OpenSky API"""
        return AsyncMock()
    
    @pytest.mark.asyncio
    async def test_perfect_match_scenario(self, plane_match_service, mock_opensky_client):
        """Test perfect aircraft match scenario"""
        
        # Get test fixtures
        fixtures = PlaneMatchTestFixtures()
        sensor_data = fixtures.get_test_sensor_data("sfo_area", azimuth=45.0, pitch=30.0)
        mock_response = fixtures.get_mock_opensky_response("perfect_match")
        
        # Mock the HTTP client response
        mock_opensky_client.get.return_value.json.return_value = mock_response
        mock_opensky_client.get.return_value.raise_for_status = AsyncMock()
        
        # Patch the service's client
        with patch.object(plane_match_service, 'client', mock_opensky_client):
            with patch.object(plane_match_service, '_ensure_authenticated', AsyncMock()):
                result = await plane_match_service.match_plane(sensor_data)
        
        # Verify results
        assert result.is_plane == True
        assert result.confidence > 0.7  # High confidence expected
        assert result.matched_flight is not None
        assert result.matched_flight.callsign == "TEST123"
        assert "TEST123" in result.reason
    
    @pytest.mark.asyncio
    async def test_no_aircraft_scenario(self, plane_match_service, mock_opensky_client):
        """Test scenario with no aircraft in area"""
        
        # Get test fixtures
        fixtures = PlaneMatchTestFixtures()
        sensor_data = fixtures.get_test_sensor_data("nevada_rural", azimuth=90.0, pitch=45.0)
        mock_response = fixtures.get_mock_opensky_response("no_aircraft")
        
        # Mock the HTTP client response
        mock_opensky_client.get.return_value.json.return_value = mock_response
        mock_opensky_client.get.return_value.raise_for_status = AsyncMock()
        
        # Patch the service's client
        with patch.object(plane_match_service, 'client', mock_opensky_client):
            with patch.object(plane_match_service, '_ensure_authenticated', AsyncMock()):
                result = await plane_match_service.match_plane(sensor_data)
        
        # Verify results
        assert result.is_plane == False
        assert result.confidence == 0.0
        assert result.matched_flight is None
        assert "No aircraft found" in result.reason
    
    @pytest.mark.asyncio
    async def test_multiple_candidates_scenario(self, plane_match_service, mock_opensky_client):
        """Test scenario with multiple aircraft candidates"""
        
        # Get test fixtures
        fixtures = PlaneMatchTestFixtures()
        sensor_data = fixtures.get_test_sensor_data("lax_area", azimuth=45.0, pitch=30.0)
        mock_response = fixtures.get_mock_opensky_response("multiple_candidates")
        
        # Mock the HTTP client response
        mock_opensky_client.get.return_value.json.return_value = mock_response
        mock_opensky_client.get.return_value.raise_for_status = AsyncMock()
        
        # Patch the service's client
        with patch.object(plane_match_service, 'client', mock_opensky_client):
            with patch.object(plane_match_service, '_ensure_authenticated', AsyncMock()):
                result = await plane_match_service.match_plane(sensor_data)
        
        # Verify results - should pick the best match (AAL789 with lowest angular error)
        assert result.is_plane == True
        assert result.confidence > 0.5
        assert result.matched_flight is not None
        assert result.matched_flight.callsign == "AAL789"
        assert result.matched_flight.angular_error < 5.0  # Should be within tolerance
    
    @pytest.mark.asyncio
    async def test_ground_aircraft_ignored(self, plane_match_service, mock_opensky_client):
        """Test that aircraft on ground are not considered matches"""
        
        # Get test fixtures
        fixtures = PlaneMatchTestFixtures()
        sensor_data = fixtures.get_test_sensor_data("sfo_area", azimuth=270.0, pitch=20.0)
        mock_response = fixtures.get_mock_opensky_response("ground_aircraft")
        
        # Mock the HTTP client response
        mock_opensky_client.get.return_value.json.return_value = mock_response
        mock_opensky_client.get.return_value.raise_for_status = AsyncMock()
        
        # Patch the service's client
        with patch.object(plane_match_service, 'client', mock_opensky_client):
            with patch.object(plane_match_service, '_ensure_authenticated', AsyncMock()):
                result = await plane_match_service.match_plane(sensor_data)
        
        # Ground aircraft should be filtered out
        assert result.is_plane == False
        assert result.confidence == 0.0
    
    def test_angular_error_calculation(self, plane_match_service):
        """Test angular error calculation between device and aircraft"""
        
        # Test perfect alignment (0° error)
        error = plane_match_service._calculate_angular_error(
            device_azimuth=45.0,
            device_pitch=30.0,
            aircraft_bearing=45.0,
            aircraft_elevation=30.0
        )
        assert abs(error) < 0.1  # Should be very close to 0
        
        # Test 90° difference in azimuth
        error = plane_match_service._calculate_angular_error(
            device_azimuth=0.0,
            device_pitch=0.0,
            aircraft_bearing=90.0,
            aircraft_elevation=0.0
        )
        assert abs(error - 90.0) < 1.0  # Should be close to 90°
    
    def test_confidence_calculation(self, plane_match_service):
        """Test confidence scoring for aircraft matches"""
        
        # High confidence: low angular error, good distance, good altitude
        confidence = plane_match_service._calculate_confidence(
            angular_error=0.5,
            distance_km=20.0,
            altitude=9000.0
        )
        assert confidence > 0.8
        
        # Low confidence: high angular error
        confidence = plane_match_service._calculate_confidence(
            angular_error=4.0,
            distance_km=20.0, 
            altitude=9000.0
        )
        assert confidence < 0.3
        
        # Medium confidence: decent match but very close (could be bird)
        confidence = plane_match_service._calculate_confidence(
            angular_error=1.0,
            distance_km=0.5,
            altitude=500.0
        )
        assert 0.3 < confidence < 0.7
    
    def test_bbox_calculation(self, plane_match_service):
        """Test bounding box calculation for API queries"""
        
        bbox = plane_match_service._calculate_bbox(
            lat=37.7749,
            lon=-122.4194,
            radius_km=50.0
        )
        
        # Verify bbox covers approximately correct area
        lat_range = bbox['lat_max'] - bbox['lat_min']
        lon_range = bbox['lon_max'] - bbox['lon_min']
        
        assert 0.8 < lat_range < 1.2  # Roughly 1° for 50km radius
        assert 1.0 < lon_range < 1.5  # Slightly wider due to longitude scaling
    
    def test_time_quantization(self, plane_match_service):
        """Test timestamp quantization for caching"""
        
        # Mock settings
        with patch('..services.plane_match_service.settings') as mock_settings:
            mock_settings.plane_match_time_quantization = 5
            
            test_time = datetime(2024, 1, 1, 12, 0, 7, 500000, timezone.utc)  # 12:00:07.5
            quantized = plane_match_service._quantize_timestamp(test_time)
            
            # Should round down to nearest 5-second boundary
            expected = int(datetime(2024, 1, 1, 12, 0, 5, tzinfo=timezone.utc).timestamp())
            assert quantized == expected


class TestPlaneMatchFixtures:
    """Test the test fixtures themselves"""
    
    def test_sensor_data_generation(self):
        """Test synthetic sensor data generation"""
        
        fixtures = PlaneMatchTestFixtures()
        sensor_data = fixtures.get_test_sensor_data("sfo_area", azimuth=45.0, pitch=30.0)
        
        assert isinstance(sensor_data, SensorDataSchema)
        assert sensor_data.azimuth_deg == 45.0
        assert sensor_data.pitch_deg == 30.0
        assert sensor_data.latitude == fixtures.LOCATIONS["sfo_area"]["latitude"]
        assert sensor_data.longitude == fixtures.LOCATIONS["sfo_area"]["longitude"]
    
    def test_opensky_response_parsing(self):
        """Test OpenSky response format compatibility"""
        
        fixtures = PlaneMatchTestFixtures()
        mock_response = fixtures.get_mock_opensky_response("high_traffic")
        
        # Should be able to parse with OpenSkyResponse
        opensky_response = OpenSkyResponse.from_api_response(mock_response)
        
        assert len(opensky_response.states) > 0
        assert all(state.icao24 for state in opensky_response.states)
    
    def test_comprehensive_scenarios(self):
        """Test all predefined test scenarios"""
        
        fixtures = PlaneMatchTestFixtures()
        scenarios = fixtures.get_test_scenarios()
        
        assert len(scenarios) >= 5  # Should have multiple test cases
        
        for scenario in scenarios:
            assert "name" in scenario
            assert "sensor_data" in scenario
            assert "opensky_response" in scenario
            assert "expected_result" in scenario
            
            # Validate sensor data
            sensor_data = scenario["sensor_data"]
            assert isinstance(sensor_data, SensorDataSchema)
            
            # Validate expected results structure
            expected = scenario["expected_result"]
            assert "is_plane" in expected
            assert "confidence_min" in expected
            assert "should_have_callsign" in expected


if __name__ == "__main__":
    # Run a quick test
    fixtures = PlaneMatchTestFixtures()
    
    print("Testing fixture generation...")
    sensor_data = fixtures.get_test_sensor_data("sfo_area")
    print(f"Generated sensor data: {sensor_data}")
    
    opensky_response = fixtures.get_mock_opensky_response("perfect_match")
    print(f"Generated OpenSky response with {len(opensky_response['states'])} aircraft")
    
    scenarios = fixtures.get_test_scenarios()
    print(f"Generated {len(scenarios)} test scenarios")
    
    print("All fixtures working correctly!")