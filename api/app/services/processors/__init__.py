"""
Enrichment processors package - clean, independent implementations
"""

from .celestial_processor import CelestialEnrichmentProcessor
from .satellite_processor import SatelliteEnrichmentProcessor
from .aircraft_processor import AircraftTrackingProcessor
from .weather_processor import WeatherEnrichmentProcessor

__all__ = [
    'CelestialEnrichmentProcessor',
    'SatelliteEnrichmentProcessor',
    'AircraftTrackingProcessor',
    'WeatherEnrichmentProcessor'
]