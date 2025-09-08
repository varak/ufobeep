"""
DND/Quiet Hours utility functions with cross-midnight handling
"""
from datetime import datetime, time
from typing import Optional
import pytz
try:
    import sentry_sdk
except ImportError:
    sentry_sdk = None

def is_in_quiet_window(
    now: datetime,
    quiet_start: Optional[str],
    quiet_end: Optional[str], 
    timezone_str: Optional[str] = None
) -> bool:
    """
    Check if current time falls within user's quiet hours window.
    Handles cross-midnight scenarios (e.g. 22:00 - 06:00).
    
    Args:
        now: Current datetime (UTC)
        quiet_start: Start time in HH:MM format (e.g. "22:00")
        quiet_end: End time in HH:MM format (e.g. "06:00") 
        timezone_str: User's timezone (e.g. "America/New_York")
        
    Returns:
        True if within quiet window, False otherwise
    """
    if not quiet_start or not quiet_end:
        return False
        
    try:
        # Parse time strings
        start_time = time.fromisoformat(quiet_start)
        end_time = time.fromisoformat(quiet_end)
        
        # Convert to user's timezone
        if timezone_str:
            try:
                user_tz = pytz.timezone(timezone_str)
                local_now = now.astimezone(user_tz)
            except:
                # Fallback to UTC if timezone is invalid
                local_now = now
                if sentry_sdk:
                    sentry_sdk.add_breadcrumb(
                        message=f"Invalid timezone: {timezone_str}",
                        level="warning"
                    )
        else:
            local_now = now
            
        current_time = local_now.time()
        
        # Handle cross-midnight case (e.g. 22:00 - 06:00)
        if start_time > end_time:
            # Quiet window crosses midnight
            return current_time >= start_time or current_time <= end_time
        else:
            # Normal window within same day
            return start_time <= current_time <= end_time
            
    except (ValueError, TypeError) as e:
        if sentry_sdk:
            sentry_sdk.add_breadcrumb(
                message=f"DND time parsing error: {e}",
                level="error",
                data={
                    "quiet_start": quiet_start,
                    "quiet_end": quiet_end,
                    "timezone": timezone_str
                }
            )
        # Fail safe - don't filter if we can't parse
        return False

def should_override_quiet_hours(
    witness_count: int, 
    emergency_threshold: int = 3
) -> bool:
    """
    Determine if emergency override should bypass quiet hours.
    
    Args:
        witness_count: Number of witnesses reporting the sighting
        emergency_threshold: Minimum witnesses needed for override
        
    Returns:
        True if should override quiet hours, False otherwise
    """
    return witness_count >= emergency_threshold

def is_dnd_active(dnd_until: Optional[datetime], now: datetime) -> bool:
    """
    Check if Do Not Disturb is currently active.
    
    Args:
        dnd_until: DND expiry time (None if not set)
        now: Current datetime
        
    Returns:
        True if DND is active, False otherwise
    """
    if not dnd_until:
        return False
        
    return now < dnd_until