#!/usr/bin/env python3
"""
Working Skyfield celestial calculations that produced real results
"""

from skyfield.api import load, wgs84, utc
from skyfield import almanac
from datetime import datetime

def calculate_celestial_working(lat, lon, timestamp_utc):
    """The working version that showed real values"""
    # Load ephemeris (this is what works)
    ts = load.timescale()
    eph = load('de421.bsp')
    earth = eph['earth']
    sun = eph['sun']
    moon = eph['moon']

    # Convert time (this worked)
    t = ts.from_datetime(timestamp_utc.replace(tzinfo=utc))

    # Observer (this worked)
    observer = earth + wgs84.latlon(lat, lon)

    # Sun calculation (this worked)
    sun_astrometric = observer.at(t).observe(sun)
    sun_apparent = sun_astrometric.apparent()
    sun_alt, sun_az, _ = sun_apparent.altaz()
    sun_alt_deg = float(sun_alt.degrees)
    sun_az_deg = float(sun_az.degrees)

    # Moon calculation (this worked)
    moon_astrometric = observer.at(t).observe(moon)
    moon_apparent = moon_astrometric.apparent()
    moon_alt, moon_az, _ = moon_apparent.altaz()
    moon_alt_deg = float(moon_alt.degrees)
    moon_az_deg = float(moon_az.degrees)

    # Moon phase (this worked)
    phase_fraction = float(almanac.fraction_illuminated(eph, 'moon', t))

    # Phase name mapping (this worked)
    if phase_fraction < 0.06:
        phase_name = "New Moon"
    elif phase_fraction < 0.25:
        phase_name = "Waxing Crescent"
    elif abs(phase_fraction - 0.25) < 0.02:
        phase_name = "First Quarter"
    elif phase_fraction < 0.50:
        phase_name = "Waxing Gibbous"
    elif abs(phase_fraction - 0.50) < 0.02:
        phase_name = "Full Moon"
    elif phase_fraction < 0.75:
        phase_name = "Waning Gibbous"
    elif abs(phase_fraction - 0.75) < 0.02:
        phase_name = "Last Quarter"
    else:
        phase_name = "Waning Crescent"

    # Return working format
    return {
        "sun": {
            "altitude": sun_alt_deg,
            "azimuth": sun_az_deg,
            "is_visible": sun_alt_deg > -6
        },
        "moon": {
            "altitude": moon_alt_deg,
            "azimuth": moon_az_deg,
            "is_visible": moon_alt_deg > 0,
            "phase_name": phase_name,
            "phase_fraction": phase_fraction,
            "illumination_pct": phase_fraction * 100
        }
    }

# Test it
if __name__ == "__main__":
    result = calculate_celestial_working(36.2457, -115.2411, datetime.utcnow())
    print(f"Sun: {result['sun']['altitude']:.1f}° altitude")
    print(f"Moon: {result['moon']['altitude']:.1f}° altitude, {result['moon']['phase_name']}")