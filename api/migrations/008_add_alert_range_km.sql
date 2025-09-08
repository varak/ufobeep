-- Migration 008: Add alert_range_km column to devices table
-- Allows users to set their preferred proximity alert range

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='devices' AND column_name='alert_range_km'
  ) THEN
    ALTER TABLE devices ADD COLUMN alert_range_km DOUBLE PRECISION DEFAULT 10.0;
    CREATE INDEX IF NOT EXISTS idx_devices_alert_range ON devices(alert_range_km);
    COMMENT ON COLUMN devices.alert_range_km IS 'User preferred alert range in kilometers (1.0-100.0)';
  END IF;
END$$;