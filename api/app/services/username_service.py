"""
Username Generation Service - MP13-1
Generates human-readable usernames like 'cosmic-whisper-7823'
"""

import random
import secrets
from typing import List, Tuple


class UsernameGenerator:
    """Generates unique, memorable usernames for UFOBeep users"""
    
    # Cosmic/space themed adjectives
    ADJECTIVES = [
        "cosmic", "stellar", "galactic", "lunar", "solar", "orbital",
        "nebular", "astral", "celestial", "ethereal", "starlit", "moonlit",
        "radiant", "luminous", "glowing", "shimmering", "drifting", "floating",
        "distant", "ancient", "mysterious", "enigmatic", "phantom", "spectral",
        "electric", "magnetic", "quantum", "plasma", "fusion", "atomic",
        "binary", "digital", "cyber", "neon", "chrome", "crystal",
        "arctic", "frozen", "blazing", "burning", "searing", "molten",
        "silent", "whispering", "echoing", "resonant", "harmonic", "sonic"
    ]
    
    # Space/UFO themed nouns
    NOUNS = [
        "whisper", "echo", "signal", "beacon", "pulse", "wave",
        "orbit", "trajectory", "vector", "comet", "meteor", "asteroid", 
        "galaxy", "nebula", "quasar", "pulsar", "supernova", "blackhole",
        "star", "planet", "moon", "satellite", "probe", "vessel",
        "craft", "ship", "scanner", "detector", "observer", "watcher",
        "wanderer", "traveler", "explorer", "navigator", "pilot", "captain",
        "ghost", "phantom", "shadow", "specter", "entity", "being",
        "light", "flash", "glimmer", "spark", "glow", "aura",
        "void", "plasma", "energy", "force", "field", "matrix",
        "code", "cipher", "key", "token", "byte", "node"
    ]
    
    @classmethod
    def generate(cls, num_suffix_digits: int = 4) -> str:
        """
        Generate a username like 'cosmic.whisper.7823'
        
        Args:
            num_suffix_digits: Number of random digits to append (default 4)
            
        Returns:
            Generated username string
        """
        adjective = random.choice(cls.ADJECTIVES)
        noun = random.choice(cls.NOUNS)
        
        # Generate cryptographically secure random number
        max_num = 10 ** num_suffix_digits - 1
        suffix = secrets.randbelow(max_num)
        suffix_str = str(suffix).zfill(num_suffix_digits)
        
        return f"{adjective}.{noun}.{suffix_str}"
    
    @classmethod
    def generate_multiple(cls, count: int = 5, num_suffix_digits: int = 4) -> List[str]:
        """Generate multiple username options"""
        return [cls.generate(num_suffix_digits) for _ in range(count)]
    
    @classmethod
    def is_valid_username(cls, username: str) -> Tuple[bool, str]:
        """
        Validate a username format
        
        Returns:
            (is_valid, error_message)
        """
        if not username:
            return False, "Username cannot be empty"
        
        if len(username) < 5:
            return False, "Username too short"
        
        if len(username) > 50:
            return False, "Username too long (max 50 characters)"
        
        # Check basic format: word.word.digits
        parts = username.split('.')
        if len(parts) != 3:
            return False, "Username must have format: adjective.noun.number"
        
        adjective, noun, number = parts
        
        # Check parts are not empty
        if not all([adjective, noun, number]):
            return False, "All parts (adjective.noun.number) must be non-empty"
        
        # Check number part is digits only
        if not number.isdigit():
            return False, "Number suffix must contain only digits"
        
        # Check for valid characters (alphanumeric and dots only)
        allowed_chars = set('abcdefghijklmnopqrstuvwxyz0123456789.')
        if not all(c in allowed_chars for c in username.lower()):
            return False, "Username can only contain letters, numbers, and dots"
        
        return True, ""


# Example usage and testing
if __name__ == "__main__":
    # Generate some example usernames
    print("Generated usernames:")
    for _ in range(10):
        username = UsernameGenerator.generate()
        print(f"  {username}")
    
    print("\nMultiple options:")
    options = UsernameGenerator.generate_multiple(5)
    for i, username in enumerate(options, 1):
        print(f"  {i}. {username}")
    
    print("\nValidation tests:")
    test_cases = [
        "cosmic.whisper.7823",  # valid
        "stellar.probe.1234",   # valid
        "cosmic.whisper",       # invalid - no number
        "cosmic.whisper.7823.extra",  # invalid - too many parts
        "cosmic_whisper_7823",  # invalid - underscores
        "cosmic.whisper.abc",   # invalid - non-numeric suffix
        "",                     # invalid - empty
        "a.b.1",               # valid but short
        "cosmic-whisper-7823", # invalid - hyphens
    ]
    
    for test_username in test_cases:
        is_valid, error = UsernameGenerator.is_valid_username(test_username)
        status = "✓" if is_valid else "✗"
        print(f"  {status} '{test_username}' - {error if error else 'valid'}")