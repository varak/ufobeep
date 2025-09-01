-- 20250901_add_feed_fields_corrected.sql
ALTER TABLE sightings
  ADD COLUMN IF NOT EXISTS source TEXT,
  ADD COLUMN IF NOT EXISTS source_id TEXT,
  ADD COLUMN IF NOT EXISTS ingestion_hash TEXT,
  ADD COLUMN IF NOT EXISTS ingested_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS raw JSONB,
  ADD COLUMN IF NOT EXISTS external_url TEXT,
  ADD COLUMN IF NOT EXISTS shape TEXT,
  ADD COLUMN IF NOT EXISTS duration TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE c.relkind='i' AND c.relname='idx_sightings_source_sourceid_unique'
  ) THEN
    EXECUTE 'CREATE UNIQUE INDEX idx_sightings_source_sourceid_unique ON sightings (source, source_id)';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE c.relkind='i' AND c.relname='idx_sightings_ingestion_hash_unique'
  ) THEN
    EXECUTE 'CREATE UNIQUE INDEX idx_sightings_ingestion_hash_unique ON sightings (ingestion_hash)';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE c.relkind='i' AND c.relname='idx_sightings_created_at'
  ) THEN
    EXECUTE 'CREATE INDEX idx_sightings_created_at ON sightings (created_at)';
  END IF;
END$$;