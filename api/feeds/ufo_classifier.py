#!/usr/bin/env python3
"""
UFO Classification System for MUFON cases
Analyzes descriptions to classify UFO types
"""
import re
from typing import Optional, List, Dict

class UFOClassifier:
    """Classifies UFOs based on description text"""
    
    def __init__(self):
        # UFO type patterns based on description keywords
        self.classification_patterns = {
            "triangle": [
                r"triangl\w+",
                r"three.*light",
                r"delta.*shape",
                r"arrow.*shape",
                r"three.*corner",
                r"v.*shaped?",
            ],
            "disc": [
                r"disc\w*",
                r"saucer",
                r"round.*craft",
                r"circular.*object",
                r"disk\w*",
                r"plate.*shaped?",
            ],
            "sphere": [
                r"sphere\w*",
                r"ball.*shaped?",
                r"orb\w*",
                r"round.*ball",
                r"spherical",
                r"globe.*shaped?",
            ],
            "cigar": [
                r"cigar\w*",
                r"cylinder\w*",
                r"tube.*shaped?",
                r"elongated.*object",
                r"capsule.*shaped?",
                r"oblong.*craft",
            ],
            "light": [
                r"bright.*light",
                r"single.*light",
                r"white.*light",
                r"glowing.*light",
                r"beam.*light",
                r"flash\w*.*light",
            ],
            "formation": [
                r"multiple.*object",
                r"several.*light",
                r"formation.*",
                r"group.*object",
                r"fleet.*",
                r"many.*light",
                r"\d+.*object",
                r"array.*light",
            ],
            "boomerang": [
                r"boomerang",
                r"v.*wing",
                r"crescent",
                r"banana.*shaped?",
                r"chevron",
            ],
            "rectangle": [
                r"rectangl\w+",
                r"square.*craft",
                r"box.*shaped?",
                r"cubic",
                r"rectangular.*object",
            ],
            "diamond": [
                r"diamond.*shaped?",
                r"rhomb\w+",
                r"kite.*shaped?",
            ],
        }
        
        # Shape keywords that help determine primary classification
        self.shape_indicators = {
            "metallic": ["metallic", "shiny", "chrome", "silver", "reflective"],
            "glowing": ["glowing", "luminous", "radiant", "illuminated"],
            "silent": ["silent", "no sound", "quiet", "noiseless"],
            "fast": ["fast", "rapid", "quick", "speed", "accelerated"],
            "hovering": ["hovering", "stationary", "motionless", "suspended"],
        }
    
    def classify(self, description: str, title: str = "") -> Dict[str, any]:
        """
        Classify UFO based on description and title
        Returns classification with confidence score
        """
        if not description and not title:
            return {"type": "unknown", "confidence": 0.0, "keywords": []}
        
        # Combine title and description for analysis
        text = f"{title} {description}".lower()
        
        # Score each classification type
        type_scores = {}
        matched_keywords = {}
        
        for ufo_type, patterns in self.classification_patterns.items():
            score = 0
            keywords = []
            
            for pattern in patterns:
                matches = re.findall(pattern, text, re.IGNORECASE)
                if matches:
                    score += len(matches) * 2  # Weight for exact pattern matches
                    keywords.extend(matches)
            
            # Bonus points for multiple keyword variations
            if score > 0:
                type_scores[ufo_type] = score
                matched_keywords[ufo_type] = keywords
        
        # If no strong classification, try fallback analysis
        if not type_scores:
            return self._fallback_classification(text)
        
        # Find best classification
        best_type = max(type_scores.keys(), key=lambda k: type_scores[k])
        max_score = type_scores[best_type]
        
        # Calculate confidence (0.0 to 1.0)
        confidence = min(max_score / 10.0, 1.0)  # Normalize to 0-1
        
        # Add shape characteristics
        characteristics = self._extract_characteristics(text)
        
        return {
            "type": best_type,
            "confidence": confidence,
            "keywords": matched_keywords.get(best_type, []),
            "characteristics": characteristics,
            "all_scores": type_scores
        }
    
    def _fallback_classification(self, text: str) -> Dict[str, any]:
        """Fallback classification for unclear descriptions"""
        
        # Look for basic shape words
        if any(word in text for word in ["round", "circular", "ball"]):
            return {"type": "sphere", "confidence": 0.3, "keywords": ["round"], "characteristics": []}
        
        if any(word in text for word in ["light", "glow", "bright"]):
            return {"type": "light", "confidence": 0.4, "keywords": ["light"], "characteristics": []}
        
        if any(word in text for word in ["object", "craft", "ufo"]):
            return {"type": "unknown", "confidence": 0.2, "keywords": ["object"], "characteristics": []}
        
        return {"type": "unknown", "confidence": 0.0, "keywords": [], "characteristics": []}
    
    def _extract_characteristics(self, text: str) -> List[str]:
        """Extract UFO characteristics from description"""
        characteristics = []
        
        for char_type, keywords in self.shape_indicators.items():
            if any(keyword in text for keyword in keywords):
                characteristics.append(char_type)
        
        return characteristics

def classify_mufon_cases(cases_file: str = "mufon_working_results.json") -> None:
    """Classify all MUFON cases and add classification data"""
    import json
    from pathlib import Path
    
    classifier = UFOClassifier()
    
    # Load MUFON cases
    data_file = Path(cases_file)
    if not data_file.exists():
        print(f"❌ File {cases_file} not found")
        return
    
    with open(data_file) as f:
        data = json.load(f)
    
    print(f"🔍 Classifying {len(data['cases'])} MUFON cases...")
    
    classified_cases = []
    classification_stats = {}
    
    for case in data['cases']:
        # Classify the case
        title = case.get('Short_Description', '')
        description = case.get('Long_Description', '')
        
        classification = classifier.classify(description, title)
        
        # Add classification to case data
        case['UFO_Classification'] = classification
        classified_cases.append(case)
        
        # Update stats
        ufo_type = classification['type']
        if ufo_type not in classification_stats:
            classification_stats[ufo_type] = 0
        classification_stats[ufo_type] += 1
        
        print(f"  - Case #{case.get('Case_Number')}: {ufo_type} "
              f"({classification['confidence']:.2f}) - {title[:40]}")
    
    # Save classified results
    classified_data = {
        **data,
        "cases": classified_cases,
        "classification_stats": classification_stats
    }
    
    output_file = Path("mufon_classified_results.json")
    with open(output_file, "w") as f:
        json.dump(classified_data, f, indent=2)
    
    print(f"\n📊 Classification Results:")
    for ufo_type, count in sorted(classification_stats.items()):
        percentage = (count / len(classified_cases)) * 100
        print(f"  {ufo_type}: {count} cases ({percentage:.1f}%)")
    
    print(f"\n✅ Saved classified results to {output_file}")

if __name__ == "__main__":
    classify_mufon_cases()