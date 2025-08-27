# Database models for UFOBeep API

from .sighting import (
    Base, User, Device, Sighting, SightingComment, SightingReaction, 
    WitnessConfirmation, SightingEnrichment, Alert, MediaFile,
    SightingCategory, SightingClassification, PetStatus, SightingStatus,
    AlertLevel, MediaType, DevicePlatform, PushProvider
)
from .magic_link import MagicLink, MagicLinkAttempt

__all__ = [
    'Base', 'User', 'Device', 'Sighting', 'SightingComment', 'SightingReaction',
    'WitnessConfirmation', 'SightingEnrichment', 'Alert', 'MediaFile',
    'MagicLink', 'MagicLinkAttempt',
    'SightingCategory', 'SightingClassification', 'PetStatus', 'SightingStatus',
    'AlertLevel', 'MediaType', 'DevicePlatform', 'PushProvider'
]