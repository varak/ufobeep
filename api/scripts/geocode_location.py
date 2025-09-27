#!/usr/bin/env python3
"""
Reverse geocoding script for UFOBeep
Converts latitude/longitude coordinates to location names using OpenWeather Geocoding API
"""
import sys
import json
import argparse
import requests
import os
from datetime import datetime

def parse_args():
    parser = argparse.ArgumentParser(description='Reverse geocode coordinates to location name')
    parser.add_argument('--lat', type=float, required=True, help='Latitude')
    parser.add_argument('--lon', type=float, required=True, help='Longitude')
    return parser.parse_args()

def reverse_geocode(latitude: float, longitude: float) -> dict:
    """Use OpenWeather Geocoding API for reverse geocoding"""

    # Get API key from environment
    api_key = os.getenv('OPENWEATHER_API_KEY')
    if not api_key:
        raise Exception("OPENWEATHER_API_KEY environment variable not set")

    print(f"GEOCODING DEBUG: Reverse geocoding {latitude}, {longitude}", file=sys.stderr)

    # OpenWeather reverse geocoding endpoint
    base_url = "http://api.openweathermap.org/geo/1.0/reverse"

    params = {
        'lat': latitude,
        'lon': longitude,
        'limit': 1,
        'appid': api_key
    }

    try:
        response = requests.get(base_url, params=params, timeout=10)

        if response.status_code != 200:
            raise Exception(f"OpenWeather API error: {response.status_code} - {response.text}")

        data = response.json()

        if not data or len(data) == 0:
            raise Exception("No location data found for coordinates")

        location_info = data[0]  # Take the first result

        # Extract location components
        city = location_info.get('name', '')
        state = location_info.get('state', '')
        country = location_info.get('country', '')

        # Format location name based on country
        if country == 'US' and state:
            # For US locations, use "City, State" format
            location_name = f"{city}, {state}" if city else state
            formatted_address = f"{city}, {state}, United States" if city else f"{state}, United States"
        elif city and country:
            # For international locations, use "City, Country" format
            location_name = f"{city}, {country}"
            formatted_address = f"{city}, {country}"
        elif country:
            # Fallback to just country
            location_name = country
            formatted_address = country
        else:
            raise Exception("Insufficient location data returned")

        return {
            "location_name": location_name,
            "formatted_address": formatted_address,
            "display_name": formatted_address,
            "city": city,
            "state": state,
            "country": country,
            "latitude": latitude,
            "longitude": longitude,
            "source": "openweather_geocoding"
        }

    except requests.RequestException as e:
        raise Exception(f"Geocoding API request failed: {e}")

def main():
    args = parse_args()

    print(f"GEOCODING DEBUG: Called with coordinates: {args.lat}, {args.lon}", file=sys.stderr)
    print(f"GEOCODING DEBUG: Current UTC: {datetime.utcnow()}", file=sys.stderr)

    try:
        data = reverse_geocode(args.lat, args.lon)
        print(f"Method: openweather", file=sys.stderr)
        print("Input:", {"lat": args.lat, "lon": args.lon}, file=sys.stderr)
        print("Result:", file=sys.stderr)

        # Output clean JSON to stdout for subprocess consumption
        print(json.dumps(data))

    except Exception as e:
        print(f"GEOCODING ERROR: {e}", file=sys.stderr)
        # Output empty result on error
        print(json.dumps({
            "location_name": "Unknown Location",
            "formatted_address": "Unknown Location",
            "error": str(e)
        }))

if __name__ == "__main__":
    main()