#!/usr/bin/env python3
import sys
sys.path.append('/home/mike/D/ufobeep/api/feeds')
from import_via_alerts import extract_location_from_description

long_desc = """round orb Metalic blackish at 6:31pm central 9/1/25 Quincy Illinois traveling from south to north above the tree line and below the cloud deck. This lasted a few seconds then became out of view. speed was about 50 mph it seemed. VERY straight line it floated a few hundred feet above the trees, dark in color as the sun was setting to the west of this object. I saw the other side from my vantage point which was dark metallic in nature. It was like in other people's videos you see, round orb moving fast above trees. Definitely was not a bird, nor a drone or balloon. This sphere flew very straight maintaining the same altitude."""

location_field = "round orb traveling south to north observed in very straight line"

result = extract_location_from_description(long_desc, location_field)
print(f"Extracted location: '{result}'")