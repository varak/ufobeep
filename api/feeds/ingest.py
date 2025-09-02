"""
MUFON ingestion entry point for the feeds router.
Uses the unified sightings table - single source of truth.
"""
import asyncpg
from .ingest_sightings import ingest_mufon_sightings


async def ingest_mufon(pool: asyncpg.Pool, days_back: int = 2) -> int:
    """Ingest MUFON reports into the unified sightings table."""
    return await ingest_mufon_sightings(pool, days_back)