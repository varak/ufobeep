from __future__ import annotations
from typing import List, Dict, Any
import asyncpg

from .mufon_client import fetch_last20 as fetch_mufon, to_alert_dict as mufon_to_alert
from .nuforc_client import fetch_recent as fetch_nuforc, to_alert_dict as nuforc_to_alert

INSERT_BY_KEY = """
INSERT INTO alerts
  (source, source_id, ingestion_hash, ingested_at,
   occurred_at, title, summary, city, state, country, shape, duration, external_url, raw)
VALUES
  ($1, $2, $3, NOW(),
   $4, $5, $6, $7, $8, $9, $10, $11, $12, $13::jsonb)
ON CONFLICT (source, source_id) DO NOTHING;
"""

INSERT_BY_HASH = """
INSERT INTO alerts
  (source, source_id, ingestion_hash, ingested_at,
   occurred_at, title, summary, city, state, country, shape, duration, external_url, raw)
VALUES
  ($1, $2, $3, NOW(),
   $4, $5, $6, $7, $8, $9, $10, $11, $12, $13::jsonb)
ON CONFLICT (ingestion_hash) DO NOTHING;
"""

async def _upsert_many(pool: asyncpg.Pool, rows: List[Dict[str, Any]]) -> int:
    if not rows: return 0
    async with pool.acquire() as conn:
        inserted = 0
        async with conn.transaction():
            for r in rows:
                # prefer (source, source_id) path if available
                sql = INSERT_BY_KEY if r.get("source_id") else INSERT_BY_HASH
                res = await conn.execute(
                    sql,
                    r["source"], r.get("source_id"), r["ingestion_hash"],
                    r.get("occurred_at"), r.get("title"), r.get("summary"), r.get("city"),
                    r.get("state"), r.get("country"), r.get("shape"), r.get("duration"),
                    r.get("external_url"), r.get("raw"),
                )
                if res and res.startswith("INSERT"):
                    inserted += 1
        return inserted

async def ingest_all_feeds(pool: asyncpg.Pool) -> dict:
    # Fetch
    mufon_rows = await fetch_mufon()
    nuforc_rows = await fetch_nuforc()

    # Normalize
    mufon_alerts = [mufon_to_alert(r) for r in mufon_rows]
    nuforc_alerts = [nuforc_to_alert(r) for r in nuforc_rows]

    # Upsert
    mufon_inserted = await _upsert_many(pool, mufon_alerts)
    nuforc_inserted = await _upsert_many(pool, nuforc_alerts)

    return {"mufon": mufon_inserted, "nuforc": nuforc_inserted, "total": mufon_inserted + nuforc_inserted}
