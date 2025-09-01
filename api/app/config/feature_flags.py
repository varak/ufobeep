"""
Feature flags for UFOBeep API - controls rollout of new features
"""
import os
from typing import Dict, Any

class FeatureFlags:
    def __init__(self):
        # DND/Quiet Hours server-side filtering (default OFF for safe rollout)
        self.dnd_server_filtering = self._get_bool_env("DND_SERVER_FILTERING", False)
        
        # Canary cohort devices for testing new features
        self.canary_device_ids = set(self._get_env("CANARY_DEVICE_IDS", "").split(","))
        
    def _get_bool_env(self, key: str, default: bool = False) -> bool:
        """Get boolean environment variable with safe defaults"""
        return os.getenv(key, str(default)).lower() in ('true', '1', 'yes', 'on')
    
    def _get_env(self, key: str, default: str = "") -> str:
        """Get string environment variable with default"""
        return os.getenv(key, default).strip()
    
    def is_canary_device(self, device_id: str) -> bool:
        """Check if device is in canary cohort"""
        return device_id in self.canary_device_ids
    
    def to_dict(self) -> Dict[str, Any]:
        """Export feature flags for debugging/monitoring"""
        return {
            "dnd_server_filtering": self.dnd_server_filtering,
            "canary_device_count": len(self.canary_device_ids),
        }

# Global instance
feature_flags = FeatureFlags()