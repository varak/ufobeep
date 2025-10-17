#!/usr/bin/env python3
"""
Utility for generating short URLs using the shared Node.js module
"""
import subprocess
import os
import logging
from typing import Optional

logger = logging.getLogger(__name__)

def generate_short_url(sighting_id: str) -> Optional[str]:
    """
    Generate a short URL ID by calling the shared Node.js module.
    
    Args:
        sighting_id: The UUID or identifier to generate a short URL for
        
    Returns:
        4-character short ID (e.g., "4rnb") or None if generation fails
    """
    try:
        # Get the project root directory
        current_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.join(current_dir, "..", "..", "..")
        shared_script = os.path.join(project_root, "shared", "get_short_hash.js")
        
        # Ensure the script exists
        if not os.path.exists(shared_script):
            logger.error(f"Short hash script not found at {shared_script}")
            return None
        
        # Call the Node.js script with the sighting ID
        # Use full path to node for systemd service compatibility
        result = subprocess.run(
            ["/usr/bin/node", shared_script, sighting_id],
            capture_output=True,
            text=True,
            timeout=5  # 5 second timeout
        )
        
        if result.returncode == 0:
            short_id = result.stdout.strip()
            if len(short_id) == 5:  # Expected length (updated to 5 chars)
                logger.debug(f"Generated short URL '{short_id}' for sighting {sighting_id}")
                return short_id
            else:
                logger.warning(f"Unexpected short ID length: '{short_id}' for sighting {sighting_id}")
                return None
        else:
            logger.error(f"Short URL generation failed for {sighting_id}: {result.stderr}")
            return None
            
    except subprocess.TimeoutExpired:
        logger.error(f"Short URL generation timeout for sighting {sighting_id}")
        return None
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