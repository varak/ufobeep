from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, validator


class SensorDataSchema(BaseModel):
    """Sensor data captured from mobile device"""
    utc: datetime
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    azimuth_deg: float = Field(..., ge=0.0, lt=360.0)
    pitch_deg: float = Field(..., ge=-90.0, le=90.0)
    roll_deg: Optional[float] = Field(None, ge=-180.0, le=180.0)
    hfov_deg: Optional[float] = Field(None, gt=0.0, lt=180.0)
    accuracy: Optional[float] = Field(None, gt=0.0)
    altitude: Optional[float] = None

    @validator('azimuth_deg')
    def validate_azimuth(cls, v):
        """Normalize azimuth to 0-360 range"""
        if v < 0:
            return v + 360
        elif v >= 360:
            return v - 360
        return v


class PlaneMatchRequest(BaseModel):
    """Request for plane matching analysis"""
    sensor_data: SensorDataSchema
    photo_path: Optional[str] = None
    description: Optional[str] = None


class PlaneMatchInfo(BaseModel):
    """Information about a matched aircraft"""
    callsign: Optional[str] = None
    icao24: Optional[str] = None
    aircraft_type: Optional[str] = None
    origin: Optional[str] = None
    destination: Optional[str] = None
    altitude: Optional[float] = None  # meters
    velocity: Optional[float] = None  # m/s
    angular_error: float  # degrees
    
    @property
    def display_name(self) -> str:
        """Get a display-friendly name for the aircraft"""
        if self.callsign and self.callsign.strip():
            return self.callsign.strip()
        if self.aircraft_type and self.aircraft_type.strip():
            return self.aircraft_type.strip()
        if self.icao24 and self.icao24.strip():
            return f"Aircraft {self.icao24.strip().upper()}"
        return "Unknown Aircraft"
    
    @property
    def display_route(self) -> str:
        """Get a display-friendly route string"""
        if (self.origin and self.origin.strip() and 
            self.destination and self.destination.strip()):
            return f"{self.origin.strip()} → {self.destination.strip()}"
        return ""


class PlaneMatchResponse(BaseModel):
    """Response from plane matching analysis"""
    is_plane: bool
    matched_flight: Optional[PlaneMatchInfo] = None
    confidence: float = Field(..., ge=0.0, le=1.0)
    reason: str
    timestamp: datetime
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


# OpenSky API Response Models
class OpenSkyState(BaseModel):
    """OpenSky aircraft state vector"""
    icao24: str
    callsign: Optional[str]
    origin_country: str
    time_position: Optional[int]
    last_contact: int
    longitude: Optional[float]
    latitude: Optional[float]
    baro_altitude: Optional[float]
    on_ground: bool
    velocity: Optional[float]
    true_track: Optional[float]
    vertical_rate: Optional[float]
    sensors: Optional[list]
    geo_altitude: Optional[float]
    squawk: Optional[str]
    spi: bool
    position_source: int
    
    @classmethod
    def from_state_vector(cls, state_vector: list):
        """Create OpenSkyState from raw state vector array"""
        return cls(
            icao24=state_vector[0] or "",
            callsign=state_vector[1].strip() if state_vector[1] else None,
            origin_country=state_vector[2] or "",
            time_position=state_vector[3],
            last_contact=state_vector[4] or 0,
            longitude=state_vector[5],
            latitude=state_vector[6],
            baro_altitude=state_vector[7],
            on_ground=bool(state_vector[8]) if state_vector[8] is not None else False,
            velocity=state_vector[9],
            true_track=state_vector[10],
            vertical_rate=state_vector[11],
            sensors=state_vector[12],
            geo_altitude=state_vector[13],
            squawk=state_vector[14],
            spi=bool(state_vector[15]) if state_vector[15] is not None else False,
            position_source=state_vector[16] or 0,
        )


class OpenSkyResponse(BaseModel):
    """OpenSky API response wrapper"""
    time: int
    states: list[OpenSkyState]
    
    @classmethod
    def from_api_response(cls, data: dict):
        """Create OpenSkyResponse from API JSON response"""
        states = []
        if data.get('states'):
            for state_vector in data['states']:
                try:
                    states.append(OpenSkyState.from_state_vector(state_vector))
                except (IndexError, TypeError, ValueError) as e:
                    # Skip malformed state vectors
                    continue
        
        return cls(
            time=data.get('time', 0),
            states=states
        )


# Internal calculation models
class LineOfSight(BaseModel):
    """Line of sight calculation result"""
    bearing_deg: float  # 0-360 degrees from North
    elevation_deg: float  # -90 to +90 degrees from horizon
    distance_km: float
    
    
class PlaneMatchCandidate(BaseModel):
    """A candidate aircraft for matching"""
    aircraft: OpenSkyState
    line_of_sight: LineOfSight
    angular_error: float  # degrees
    confidence: float  # 0.0 to 1.0