"""
Catalog service for satellite and airline metadata lookups
Loads and caches SATCAT and airlines database on startup for instant lookups
"""
import csv
import os
from typing import Dict, Optional
import logging

logger = logging.getLogger(__name__)

class CatalogService:
    """Singleton service for satellite and airline catalog lookups"""

    _instance = None
    _satcat: Dict[int, Dict] = {}
    _airlines: Dict[str, str] = {}
    _initialized = False

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def initialize(self):
        """Load catalog files on startup"""
        if self._initialized:
            return

        try:
            self._load_satcat()
            self._load_airlines()
            self._initialized = True
            logger.info(f"📚 Catalogs loaded: {len(self._satcat)} satellites, {len(self._airlines)} airlines")
        except Exception as e:
            logger.error(f"Failed to load catalogs: {e}")

    def _load_satcat(self):
        """Load satellite catalog from SATCAT CSV"""
        # Determine path based on environment
        if os.path.exists('/home/ufobeep/ufobeep'):
            satcat_path = '/home/ufobeep/ufobeep/api/data/satcat.csv'
        else:
            satcat_path = '/home/mike/D/ufobeep/api/data/satcat.csv'

        if not os.path.exists(satcat_path):
            logger.warning(f"SATCAT file not found: {satcat_path}")
            return

        with open(satcat_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                try:
                    norad_id = int(row['NORAD_CAT_ID'])
                    self._satcat[norad_id] = {
                        'name': row['OBJECT_NAME'],
                        'owner': row['OWNER'],
                        'launch_date': row['LAUNCH_DATE'],
                        'object_type': row['OBJECT_TYPE'],  # PAY=Payload, R/B=Rocket Body, DEB=Debris
                        'country': self._decode_country(row['OWNER']),
                    }
                except (ValueError, KeyError):
                    continue

    def _load_airlines(self):
        """Load airline codes from OpenFlights database"""
        # Determine path based on environment
        if os.path.exists('/home/ufobeep/ufobeep'):
            airlines_path = '/home/ufobeep/ufobeep/api/data/airlines.dat'
        else:
            airlines_path = '/home/mike/D/ufobeep/api/data/airlines.dat'

        if not os.path.exists(airlines_path):
            logger.warning(f"Airlines file not found: {airlines_path}")
            return

        # Format: ID,Name,Alias,IATA,ICAO,Callsign,Country,Active
        with open(airlines_path, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            for row in reader:
                try:
                    if len(row) < 5:
                        continue
                    icao_code = row[4].strip()  # Column 4 is ICAO code
                    airline_name = row[1].strip().strip('"')
                    if icao_code and icao_code != '-' and airline_name:
                        self._airlines[icao_code] = airline_name
                except (IndexError, ValueError):
                    continue

    def _decode_country(self, owner_code: str) -> str:
        """Decode country/owner codes to readable names"""
        owner_map = {
            'US': 'USA',
            'CIS': 'Russia',
            'PRC': 'China',
            'ESA': 'Europe',
            'ISS': 'International',
            'EUME': 'Europe',
            'INDO': 'Indonesia',
            'JASO': 'Japan',
            'FRIT': 'France/Italy',
        }
        return owner_map.get(owner_code, owner_code)

    def get_satellite_info(self, norad_id: int) -> Optional[Dict]:
        """Get satellite metadata by NORAD ID"""
        return self._satcat.get(norad_id)

    def get_airline_name(self, callsign: str) -> Optional[str]:
        """Extract airline from callsign (first 3 letters)"""
        if not callsign or len(callsign) < 3:
            return None

        # Private aircraft start with N, G, etc. (country registration)
        if callsign[0] in ['N', 'G', 'D', 'F', 'C']:
            return None  # Private aircraft, no airline

        # Extract ICAO code (first 3 letters)
        icao_code = callsign[:3].upper()
        return self._airlines.get(icao_code)

# Global instance
catalog_service = CatalogService()
