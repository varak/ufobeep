"""
Base classes for enrichment processors
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from typing import Optional, Dict, Any


@dataclass
class EnrichmentContext:
    """Context for enrichment processing"""
    sighting_id: str
    latitude: float
    longitude: float
    altitude: float
    timestamp: datetime
    azimuth_deg: float
    pitch_deg: float
    category: str
    title: str
    description: str


@dataclass
class EnrichmentResult:
    """Result from enrichment processing"""
    processor_name: str
    success: bool
    data: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    processing_time_ms: Optional[int] = None
    confidence_score: Optional[float] = None
    metadata: Optional[Dict[str, Any]] = None


class EnrichmentProcessor(ABC):
    """Abstract base class for enrichment processors"""

    @property
    @abstractmethod
    def name(self) -> str:
        """Name of the processor"""
        pass

    @property
    @abstractmethod
    def timeout_seconds(self) -> int:
        """Timeout for processing in seconds"""
        pass

    @property
    @abstractmethod
    def priority(self) -> int:
        """Processing priority (lower numbers = higher priority)"""
        pass

    @abstractmethod
    async def is_available(self) -> bool:
        """Check if processor is available (API keys, services, etc.)"""
        pass

    @abstractmethod
    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Process enrichment for the given context"""
        pass