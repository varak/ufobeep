-- file: migrations/002_devices.sql
-- Create devices table for FCM push notifications

CREATE TABLE IF NOT EXISTS devices (
  device_id TEXT PRIMARY KEY,
  fcm_token TEXT NOT NULL,
  platform TEXT CHECK (platform IN ('android','ios')) NOT NULL DEFAULT 'android',
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  geohash TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_devices_geohash ON devices(geohash);
CREATE INDEX IF NOT EXISTS idx_devices_updated_at ON devices(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_devices_platform ON devices(platform);

-- Comment for context
COMMENT ON TABLE devices IS 'FCM device tokens for push notifications with optional location data';
COMMENT ON COLUMN devices.device_id IS 'Unique device identifier from anonymous beep service';
COMMENT ON COLUMN devices.fcm_token IS 'Firebase Cloud Messaging token for push notifications';
COMMENT ON COLUMN devices.geohash IS '7-character geohash for proximity queries';