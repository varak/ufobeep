#!/usr/bin/env python3
"""
Utility for generating short URLs - pure Python implementation
Matches the algorithm from shared/get_short_hash.js
"""
import logging
from typing import Optional

logger = logging.getLogger(__name__)

# Characters safe for short IDs (excludes O,I,L,0,1,o,l,i for clarity)
SAFE_CHARS = '23456789abcdefghjkmnpqrstuvwxyz'

def generate_short_url(sighting_id: str) -> Optional[str]:
    """
    Generate a 5-character clean short ID from input string.
    Python port of the canonical JS implementation.

    Args:
        sighting_id: The UUID or identifier to generate a short URL for

    Returns:
        5-character short ID (e.g., "z4rnb") or None if generation fails
    """
    try:
        if not sighting_id:
            return None

        # Generate hash using the exact algorithm from JS
        hash_val = 0
        for char in sighting_id:
            char_code = ord(char)
            hash_val = ((hash_val << 5) - hash_val) + char_code
            # Convert to 32-bit integer (simulate JS bitwise operations)
            hash_val = hash_val & 0xFFFFFFFF
            if hash_val >= 0x80000000:  # Handle sign
                hash_val -= 0x100000000

        # Convert hash to base-29 using safe characters
        short_id = ''
        num = abs(hash_val)

        for _ in range(5):  # 5 characters
            short_id = SAFE_CHARS[num % len(SAFE_CHARS)] + short_id
            num = num // len(SAFE_CHARS)

        logger.debug(f"Generated short URL '{short_id}' for sighting {sighting_id}")
        return short_id

    except Exception as e:
        logger.error(f"Error generating short URL for {sighting_id}: {e}")
        return None

def test_short_url_generation():
    """Test function to verify short URL generation works"""
    test_id = "40e8a05f-d697-460b-9b10-e8093be7391e"
    expected = "z4rnb"  # Updated to 5-character expected result
    
    result = generate_short_url(test_id)
    if result == expected:
        print(f"✅ Short URL test passed: {test_id} -> {result}")
        return True
    else:
        print(f"❌ Short URL test failed: {test_id} -> {result} (expected {expected})")
        return False

if __name__ == "__main__":
    # Test the function when run directly
    test_short_url_generation()