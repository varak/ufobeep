"""
Username Generation Service - MP13-1
Generates human-readable usernames like 'cosmic-whisper-7823'
"""

import random
import secrets
from typing import List, Tuple


class UsernameGenerator:
    """Generates unique, memorable usernames for UFOBeep users"""
    
    # Cosmic/space themed adjectives (256 total)
    ADJECTIVES = [
        # First 128
        "cosmic", "stellar", "galactic", "lunar", "solar", "orbital",
        "nebular", "astral", "celestial", "ethereal", "starlit", "moonlit",
        "radiant", "luminous", "glowing", "shimmering", "drifting", "floating",
        "distant", "ancient", "mysterious", "enigmatic", "phantom", "spectral",
        "electric", "magnetic", "quantum", "plasma", "fusion", "atomic",
        "binary", "digital", "cyber", "neon", "chrome", "crystal",
        "arctic", "frozen", "blazing", "burning", "searing", "molten",
        "silent", "whispering", "echoing", "resonant", "harmonic", "sonic",
        "temporal", "dimensional", "parallel", "infinite", "eternal", "timeless",
        "hypnotic", "mystic", "arcane", "cryptic", "hidden", "secret",
        "pulsing", "vibrant", "dynamic", "kinetic", "static", "flowing",
        "twilight", "midnight", "dawn", "dusk", "nocturnal", "diurnal",
        "prismatic", "iridescent", "holographic", "translucent", "opaque", "transparent",
        "metallic", "crystalline", "liquid", "gaseous", "solid", "fluid",
        "northern", "southern", "eastern", "western", "polar", "equatorial",
        "ascending", "descending", "rotating", "spinning", "spiraling", "oscillating",
        "ultra", "mega", "micro", "nano", "macro", "mini",
        "alpha", "beta", "gamma", "delta", "omega", "sigma",
        "crimson", "azure", "emerald", "violet", "amber", "obsidian",
        "swift", "rapid", "instant", "gradual", "sudden", "steady",
        "remote", "isolated", "secluded", "abandoned", "forgotten", "lost",
        "primal", "advanced", "primitive", "futuristic", "retro", "modern",
        "vertical", "horizontal", "diagonal", "angular", "curved", "linear",
        # Second 128 to reach 256
        "zero", "prime", "inverse", "reverse", "forward", "backward",
        "inner", "outer", "central", "peripheral", "focused", "scattered",
        "bright", "dark", "faint", "vivid", "pale", "deep",
        "smooth", "rough", "jagged", "sleek", "polished", "raw",
        "fast", "slow", "perpetual", "momentary", "constant", "variable",
        "hot", "cold", "warm", "cool", "thermal", "cryo",
        "stable", "unstable", "volatile", "reactive", "inert", "active",
        "primary", "secondary", "tertiary", "final", "initial", "terminal",
        "vast", "tiny", "immense", "minuscule", "colossal", "compact",
        "strange", "exotic", "alien", "foreign", "familiar", "native",
        "complex", "simple", "pure", "mixed", "hybrid", "singular",
        "double", "triple", "multiple", "single", "unified", "divided",
        "positive", "negative", "neutral", "charged", "balanced", "polar",
        "invisible", "visible", "cloaked", "revealed", "concealed", "exposed",
        "immortal", "mortal", "undying", "finite", "endless", "limited",
        "lucky", "cursed", "blessed", "sacred", "profane", "neutral",
        "peaceful", "violent", "calm", "turbulent", "serene", "chaotic",
        "rare", "common", "unique", "standard", "special", "ordinary",
        "perfect", "flawed", "pristine", "corrupted", "pure", "tainted",
        "sentient", "dormant", "awakened", "sleeping", "conscious", "aware",
        "wild", "tame", "feral", "domestic", "untamed", "controlled",
        "synthetic", "organic", "artificial", "natural", "biomechanical", "hybrid"
    ]
    
    # Space/UFO themed nouns (256 total)
    NOUNS = [
        # First 128
        "whisper", "echo", "signal", "beacon", "pulse", "wave",
        "orbit", "trajectory", "vector", "comet", "meteor", "asteroid", 
        "galaxy", "nebula", "quasar", "pulsar", "supernova", "blackhole",
        "star", "planet", "moon", "satellite", "probe", "vessel",
        "craft", "ship", "scanner", "detector", "observer", "watcher",
        "wanderer", "traveler", "explorer", "navigator", "pilot", "captain",
        "ghost", "phantom", "shadow", "specter", "entity", "being",
        "light", "flash", "glimmer", "spark", "glow", "aura",
        "void", "plasma", "energy", "force", "field", "matrix",
        "code", "cipher", "key", "token", "byte", "node",
        "cluster", "system", "station", "portal", "gateway", "bridge",
        "horizon", "zenith", "nadir", "apex", "core", "nexus",
        "stream", "cascade", "vortex", "tornado", "storm", "tempest",
        "crystal", "prism", "lens", "mirror", "reflection", "image",
        "frequency", "wavelength", "amplitude", "resonance", "vibration", "oscillation",
        "particle", "photon", "electron", "neutron", "proton", "quark",
        "dimension", "realm", "domain", "zone", "sector", "quadrant",
        "colony", "outpost", "fortress", "citadel", "base", "command",
        "engine", "reactor", "generator", "transmitter", "receiver", "amplifier",
        "anomaly", "phenomenon", "distortion", "rift", "breach", "tear",
        "sentinel", "guardian", "keeper", "protector", "defender", "warrior",
        "dream", "vision", "prophecy", "oracle", "mystic", "sage",
        "element", "compound", "molecule", "atom", "ion", "isotope",
        "relay", "junction", "intersection", "crossroads", "hub", "center",
        "fragment", "shard", "piece", "component", "module", "unit",
        # Second 128 to reach 256
        "origin", "source", "root", "seed", "genesis", "birth",
        "destiny", "fate", "fortune", "chance", "luck", "probability",
        "mind", "soul", "spirit", "essence", "consciousness", "awareness",
        "thought", "idea", "concept", "theory", "hypothesis", "principle",
        "truth", "reality", "illusion", "mirage", "hallucination", "projection",
        "memory", "record", "archive", "database", "repository", "vault",
        "network", "grid", "web", "mesh", "lattice", "framework",
        "sequence", "pattern", "cycle", "loop", "spiral", "helix",
        "edge", "boundary", "limit", "threshold", "barrier", "wall",
        "passage", "tunnel", "corridor", "pathway", "route", "trail",
        "chamber", "room", "hall", "vault", "cavern", "cave",
        "tower", "spire", "pyramid", "dome", "sphere", "cube",
        "ring", "disc", "plate", "shield", "armor", "shell",
        "weapon", "tool", "device", "instrument", "apparatus", "mechanism",
        "sensor", "monitor", "gauge", "meter", "indicator", "display",
        "message", "transmission", "broadcast", "communication", "dialogue", "exchange",
        "question", "answer", "riddle", "puzzle", "mystery", "enigma",
        "secret", "revelation", "discovery", "finding", "treasure", "artifact",
        "relic", "remnant", "trace", "footprint", "mark", "sign",
        "symbol", "glyph", "rune", "sigil", "emblem", "icon",
        "map", "chart", "diagram", "blueprint", "schematic", "plan",
        "journey", "voyage", "expedition", "mission", "quest", "adventure",
        "encounter", "meeting", "contact", "interaction", "exchange", "collision",
        "transformation", "evolution", "mutation", "adaptation", "change", "shift",
        "balance", "harmony", "discord", "chaos", "order", "entropy",
        "creation", "destruction", "formation", "dissolution", "assembly", "dispersal",
        "connection", "link", "bond", "tie", "union", "merger"
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