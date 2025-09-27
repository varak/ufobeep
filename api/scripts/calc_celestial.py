#!/usr/bin/env python3
"""
Quick Celestial Calculator

Computes Sun/Moon altitude, azimuth, and Moon illumination using Skyfield.
Falls back to a simplified Sun calculation if the ephemeris cannot be downloaded.

Usage:
  python api/scripts/calc_celestial.py --lat 36.2457 --lon -115.2411 --time 2025-09-26T07:00:00Z

Notes:
  - On first run, Skyfield will download 'de421.bsp' (~10MB). If your
    environment blocks network access, pre-download on the server by running:
      python -c "from skyfield.api import load; load('de421.bsp')"
"""
from __future__ import annotations

import argparse
import sys
from datetime import datetime, timezone


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Compute celestial data for a place/time")
    p.add_argument("--lat", type=float, required=True, help="Latitude in degrees")
    p.add_argument("--lon", type=float, required=True, help="Longitude in degrees")
    p.add_argument(
        "--time",
        type=str,
        default=datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        help="Timestamp in ISO 8601 (UTC), e.g. 2025-09-26T07:00:00Z",
    )
    return p.parse_args()


def compute_with_skyfield(lat: float, lon: float, when: datetime) -> dict:
    import sys
    print(f"CELESTIAL DEBUG: Called with timestamp: {when}", file=sys.stderr)
    print(f"CELESTIAL DEBUG: Location: {lat}, {lon}", file=sys.stderr)
    print(f"CELESTIAL DEBUG: Current UTC: {datetime.utcnow()}", file=sys.stderr)

    from skyfield.api import load, wgs84
    from skyfield import almanac

    ts = load.timescale()
    eph = load("de421.bsp")
    earth, sun, moon = eph["earth"], eph["sun"], eph["moon"]

    # Load planets
    mercury, venus, mars, jupiter, saturn, uranus, neptune = (
        eph["mercury"], eph["venus"], eph["mars"], eph["jupiter barycenter"],
        eph["saturn barycenter"], eph["uranus barycenter"], eph["neptune barycenter"]
    )

    t = ts.from_datetime(when)
    observer = earth + wgs84.latlon(lat, lon)

    sun_app = observer.at(t).observe(sun).apparent()
    moon_app = observer.at(t).observe(moon).apparent()

    sun_alt, sun_az, _ = sun_app.altaz()
    moon_alt, moon_az, _ = moon_app.altaz()
    k = float(almanac.fraction_illuminated(eph, "moon", t))

    # Calculate planets
    planets = []
    planet_objects = [
        ("Mercury", mercury),
        ("Venus", venus),
        ("Mars", mars),
        ("Jupiter", jupiter),
        ("Saturn", saturn),
        ("Uranus", uranus),
        ("Neptune", neptune)
    ]

    for planet_name, planet_obj in planet_objects:
        try:
            planet_app = observer.at(t).observe(planet_obj).apparent()
            planet_alt, planet_az, _ = planet_app.altaz()

            if planet_alt.degrees > 5:  # Above 5° horizon
                planets.append({
                    "name": planet_name,
                    "altitude": float(planet_alt.degrees),
                    "azimuth": float(planet_az.degrees),
                    "magnitude": None  # Would need additional calculation
                })
        except Exception as e:
            print(f"Error calculating {planet_name}: {e}", file=sys.stderr)

    # Calculate bright stars using skyfield's star catalog
    bright_stars = []
    try:
        from skyfield.data import hipparcos
        from skyfield.api import Star

        # Load Hipparcos star catalog
        with load.open(hipparcos.URL) as f:
            df = hipparcos.load_dataframe(f)

        # Filter to brightest stars visible to naked eye
        bright_catalog = df[df['magnitude'] < 2.5]

        for hip_id, star_data in bright_catalog.iterrows():
            try:
                # Create star object from catalog data
                star = Star(
                    ra_hours=star_data['ra_hours'],
                    dec_degrees=star_data['dec_degrees']
                )

                # Calculate position for observer
                astrometric = observer.at(t).observe(star)
                apparent = astrometric.apparent()
                alt, az, distance = apparent.altaz()

                # Only include stars above horizon
                if alt.degrees > 10:
                    bright_stars.append({
                        "name": f"HIP {hip_id}",  # Use Hipparcos ID for now
                        "altitude": float(alt.degrees),
                        "azimuth": float(az.degrees),
                        "magnitude": float(star_data['magnitude'])
                    })

            except Exception as e:
                print(f"Error calculating star HIP {hip_id}: {e}", file=sys.stderr)
                continue

    except Exception as e:
        print(f"Star catalog loading failed: {e}", file=sys.stderr)

    # Simple twilight classification
    sun_alt_deg = float(sun_alt.degrees)
    if sun_alt_deg > 0:
        twilight = "day"
    elif sun_alt_deg > -6:
        twilight = "civil_twilight"
    elif sun_alt_deg > -12:
        twilight = "nautical_twilight"
    elif sun_alt_deg > -18:
        twilight = "astronomical_twilight"
    else:
        twilight = "night"

    return {
        "sun": {
            "altitude": float(sun_alt.degrees),
            "azimuth": float(sun_az.degrees),
            "is_visible": sun_alt_deg > -6,
        },
        "moon": {
            "altitude": float(moon_alt.degrees),
            "azimuth": float(moon_az.degrees),
            "is_visible": float(moon_alt.degrees) > 0,
            "illumination_pct": k * 100.0,
        },
        "visible_planets": planets,
        "bright_stars_visible": bright_stars,
        "summary": {"twilight": twilight},
    }


def compute_sun_simplified(lat: float, lon: float, when: datetime) -> dict:
    """Very rough solar position for fallback when ephemeris isn't reachable."""
    import math

    # Day of year
    n = when.timetuple().tm_yday
    # Equation of time and declination approximations
    B = math.radians(360 * (n - 81) / 364)
    EoT = 9.87 * math.sin(2 * B) - 7.53 * math.cos(B) - 1.5 * math.sin(B)  # minutes
    decl = math.radians(23.45 * math.sin(math.radians(360 * (284 + n) / 365)))

    # Solar time
    offset_min = (lon * 4) + EoT  # minutes from UTC
    local_solar_time = (when.hour * 60 + when.minute + when.second / 60 + offset_min) / 60.0
    hour_angle = math.radians(15 * (local_solar_time - 12))

    lat_r = math.radians(lat)
    sin_alt = math.sin(lat_r) * math.sin(decl) + math.cos(lat_r) * math.cos(decl) * math.cos(hour_angle)
    alt = math.degrees(math.asin(max(-1, min(1, sin_alt))))

    y = -math.sin(hour_angle)
    x = math.tan(decl) * math.cos(lat_r) - math.sin(lat_r) * math.cos(hour_angle)
    az = (math.degrees(math.atan2(y, x)) + 180) % 360

    return {
        "sun": {
            "altitude": alt,
            "azimuth": az,
            "is_visible": alt > -6,
        },
        "moon": {"altitude": None, "azimuth": None, "is_visible": False},
        "summary": {"twilight": "day" if alt > 0 else ("civil_twilight" if alt > -6 else "night")},
    }


def main():
    args = parse_args()
    when = datetime.fromisoformat(args.time.replace("Z", "+00:00"))

    try:
        data = compute_with_skyfield(args.lat, args.lon, when)
        method = "skyfield"
    except Exception as e:
        print(f"Skyfield precise computation failed: {e}")
        print("Falling back to simplified solar position (no moon/planets)")
        data = compute_sun_simplified(args.lat, args.lon, when)
        method = "simplified"

    import json
    print(f"\nMethod: {method}", file=sys.stderr)
    print("Input:", {"lat": args.lat, "lon": args.lon, "time": when.isoformat()}, file=sys.stderr)
    print("Result:", file=sys.stderr)

    # Output clean JSON to stdout for subprocess consumption
    print(json.dumps(data))


if __name__ == "__main__":
    main()

