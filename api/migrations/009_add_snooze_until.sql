-- Migration 009: Add snooze_until column to devices table
-- Allows users to temporarily snooze notifications until a specific time

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='devices' AND column_name='snooze_until'
  ) THEN
    ALTER TABLE devices ADD COLUMN snooze_until TIMESTAMP WITH TIME ZONE DEFAULT NULL;
    CREATE INDEX IF NOT EXISTS idx_devices_snooze_until ON devices(snooze_until);
    COMMENT ON COLUMN devices.snooze_until IS 'Temporary notification snooze until this timestamp (NULL if not snoozed)';
  END IF;
END$$;