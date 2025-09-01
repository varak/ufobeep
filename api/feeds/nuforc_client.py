from __future__ import annotations
import os
import re
import csv
import io
import hashlib
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional, Dict, Any

import httpx
from bs4 import BeautifulSoup  # fallback HTML parsing if CSV not available

# You can point these to an official or mirrored CSV/JSON if you have one.
# By default, we attempt to parse the classic NUFORC HTML "Recent Reports" page.
NUFORC_URL = os.getenv("NUFORC_FEED_URL", "https://nuforc.org/fe/Latest.html")
USER_AGENT = os.getenv("FEEDS_USER_AGENT", "UFOBeep/feeds (respectful crawler)")

@dataclass
class NuforcRow:
    occurred_at: Optional[datetime]
    reported_at: Optional[datetime]
    city: Optional[str]
    state: Optional[str]
    country: Optional[str]
    shape: Optional[str]
    duration: Optional[str]
    summary: Optional[str]
    detail_url: Optional[str]

def _clean(x: Optional[str]) -> Optional[str]:
    if not x: return None
    return re.sub(r"\s+", " ", x).strip() or None

def _parse_dt(s: Optional[str], fmts=("%m/%d/%Y %H:%M", "%m/%d/%Y", "%Y-%m-%d")) -> Optional[datetime]:
    s = (s or "").strip()
    for f in fmts:
        try:
            return datetime.strptime(s, f)
        except ValueError:
            continue
    try:
        return datetime.fromisoformat(s)
    except Exception:
        return None

def _hash_for(row: NuforcRow) -> str:
    parts = [
        row.occurred_at.isoformat() if row.occurred_at else "",
        (row.city or "").lower(),
        (row.state or "").lower(),
        (row.country or "").lower(),
        (row.summary or "").lower(),
    ]
    return hashlib.sha256("|".join(parts).encode()).hexdigest()

async def fetch_recent(timeout: float = 20.0) -> List[NuforcRow]:
    async with httpx.AsyncClient(timeout=timeout, headers={"User-Agent": USER_AGENT}) as client:
        r = await client.get(NUFORC_URL)
        r.raise_for_status()
        soup = BeautifulSoup(r.text, "html.parser")

    # Heuristics based on NUFORC "Latest" layout: table rows with columns:
    # Date/Time, City, State, Country, Shape, Duration, Summary, Posted, ...
    table = soup.find("table")
    if not table:
        return []

    rows: List[NuforcRow] = []
    for tr in table.find_all("tr"):
        tds = tr.find_all(["td", "th"])
        if len(tds) < 7:
            continue
        cols = [td.get_text(" ", strip=True) for td in tds]
        links = [a for td in tds for a in td.find_all("a", href=True)]

        occurred_at = _parse_dt(cols[0] if len(cols) > 0 else None)
        city = _clean(cols[1] if len(cols) > 1 else None)
        state = _clean(cols[2] if len(cols) > 2 else None)
        country = _clean(cols[3] if len(cols) > 3 else None)
        shape = _clean(cols[4] if len(cols) > 4 else None)
        duration = _clean(cols[5] if len(cols) > 5 else None)
        summary = _clean(cols[6] if len(cols) > 6 else None)
        posted = _parse_dt(cols[7] if len(cols) > 7 else None)

        detail_url = None
        if links:
            # take the last link if available
            detail_url = links[-1]["href"]

        rows.append(NuforcRow(
            occurred_at=occurred_at,
            reported_at=posted,
            city=city, state=state, country=country,
            shape=shape, duration=duration, summary=summary,
            detail_url=detail_url
        ))
    return rows

def to_alert_dict(row: NuforcRow) -> Dict[str, Any]:
    h = _hash_for(row)
    return {
        "source": "nuforc",
        "source_id": None,  # NUFORC often lacks stable numeric IDs on list pages
        "ingestion_hash": h,
        "ingested_at": datetime.utcnow().isoformat(),
        "occurred_at": (row.occurred_at.isoformat() if row.occurred_at else None),
        "title": row.summary or "NUFORC report",
        "summary": row.summary,
        "city": row.city,
        "state": row.state,
        "country": row.country,
        "shape": row.shape,
        "duration": row.duration,
        "external_url": row.detail_url,
        "raw": {
            "reported_at": row.reported_at.isoformat() if row.reported_at else None,
            "detail_url": row.detail_url,
        },
    }
