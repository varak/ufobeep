from __future__ import annotations
from typing import List, Dict, Any
import asyncpg
import uuid
import json
from datetime import datetime

from .mufon_authenticated_client import fetch_authenticated_reports
from .nuforc_client import fetch_recent as fetch_nuforc, to_alert_dict as nuforc_to_alert

class DateTimeEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super().default(obj)

# Map MUFON authenticated report to alert_events format
def mufon_auth_to_alert_event(report: Dict[str, Any]) -> Dict[str, Any]:
    """Convert MUFON authenticated report to alert_events format"""
    event_id = str(uuid.uuid4())
    
    # Handle the two timestamps:
    # - Date/Time of Event -> created_at (when sighting occurred)
    # - Date Submitted -> ingested_at (handled by NOW() in SQL)
    occurred_at = report.get("date_time_of_event")  # The actual sighting time
    
    return {
        "event_id": event_id,
        "source": "mufon_auth",
        "source_id": report.get("mufon_case_number") or report.get("case_id"),
        "ingestion_hash": f"mufon_auth_{report.get('case_id', event_id)}",
        "occurred_at": occurred_at,  # When the sighting happened
        "description": report.get("short_description", ""),
        "latitude": report.get("latitude"),
        "longitude": report.get("longitude"),
        "weather_condition": "Clear",  # Default
        "shape": report.get("shape", "").lower() if report.get("shape") else None,
        "duration": report.get("duration"),
        "external_url": report.get("external_url"),
        "raw": report
    }

# Convert NUFORC to alert_events format 
def nuforc_to_alert_event(report: Dict[str, Any]) -> Dict[str, Any]:
    """Convert NUFORC report to alert_events format"""
    event_id = str(uuid.uuid4())
    
    original_alert = nuforc_to_alert(report)
    
    return {
        "event_id": event_id,
        "source": "nuforc", 
        "source_id": original_alert.get("source_id"),
        "ingestion_hash": original_alert.get("ingestion_hash"),
        "occurred_at": original_alert.get("occurred_at"),
        "description": original_alert.get("title", ""),
        "latitude": original_alert.get("latitude"),
        "longitude": original_alert.get("longitude"),
        "weather_condition": "Clear",
        "shape": original_alert.get("shape"),
        "duration": original_alert.get("duration"),
        "external_url": original_alert.get("external_url"),
        "raw": original_alert.get("raw")
    }

INSERT_ALERT_EVENT = """
INSERT INTO alert_events
  (event_id, source, source_id, ingestion_hash, ingested_at,
   created_at, description, latitude, longitude, weather_condition, shape, duration, external_url, raw)
VALUES
  ($1, $2, $3, $4, NOW(),
   $5, $6, $7, $8, $9, $10, $11, $12, $13::jsonb)
ON CONFLICT (source, source_id) DO NOTHING
RETURNING event_id;
"""

INSERT_ALERT_EVENT_BY_HASH = """
INSERT INTO alert_events
  (event_id, source, source_id, ingestion_hash, ingested_at,
   created_at, description, latitude, longitude, weather_condition, shape, duration, external_url, raw)
VALUES
  ($1, $2, $3, $4, NOW(),
   $5, $6, $7, $8, $9, $10, $11, $12, $13::jsonb)
ON CONFLICT (ingestion_hash) DO NOTHING
RETURNING event_id;
"""

async def _upsert_alert_events(pool: asyncpg.Pool, events: List[Dict[str, Any]]) -> int:
    """Insert alert events into alert_events table"""
    if not events:
        return 0
        
    async with pool.acquire() as conn:
        inserted = 0
        async with conn.transaction():
            for event in events:
                # Use source+source_id if available, otherwise use ingestion_hash
                sql = INSERT_ALERT_EVENT if event.get("source_id") else INSERT_ALERT_EVENT_BY_HASH
                
                raw_data = event.get("raw")
                raw_json = json.dumps(raw_data, cls=DateTimeEncoder) if raw_data else None
                
                result = await conn.fetch(
                    sql,
                    event.get("event_id"),
                    event["source"], 
                    event.get("source_id"),
                    event["ingestion_hash"],
                    event.get("occurred_at"),
                    event.get("description"),
                    event.get("latitude"),
                    event.get("longitude"), 
                    event.get("weather_condition", "Clear"),
                    event.get("shape"),
                    event.get("duration"),
                    event.get("external_url"),
                    raw_json
                )
                
                if result:  # If we got a result back, it was inserted
                    inserted += 1
                    
        return inserted

async def ingest_all_feeds(pool: asyncpg.Pool) -> dict:
    """Ingest from all feed sources into alert_events table"""
    # Fetch from authenticated MUFON (enhanced descriptions + media)
    mufon_reports = await fetch_authenticated_reports(limit=30)
    
    # Fetch from NUFORC  
    nuforc_reports = await fetch_nuforc()
    
    # Convert to alert_events format
    mufon_events = [mufon_auth_to_alert_event(r) for r in mufon_reports]
    nuforc_events = [nuforc_to_alert_event(r) for r in nuforc_reports]
    
    # Insert
    mufon_inserted = await _upsert_alert_events(pool, mufon_events) 
    nuforc_inserted = await _upsert_alert_events(pool, nuforc_events)
    
    return {
        "mufon_auth": mufon_inserted,
        "nuforc": nuforc_inserted, 
        "total": mufon_inserted + nuforc_inserted
    }

# For MUFON-only endpoint
async def ingest_mufon(pool: asyncpg.Pool) -> int:
    """Ingest authenticated MUFON reports only"""
    mufon_reports = await fetch_authenticated_reports(limit=30)
    mufon_events = [mufon_auth_to_alert_event(r) for r in mufon_reports]
    return await _upsert_alert_events(pool, mufon_events)