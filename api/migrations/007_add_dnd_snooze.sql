-- Migration 007: DND (Do Not Disturb) and Snooze support
-- Adds device-level global snooze and follow-level mute/snooze

-- Ensure preferences JSONB exists on devices (if missing)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='devices' AND column_name='preferences'
  ) THEN
    ALTER TABLE devices ADD COLUMN preferences JSONB NOT NULL DEFAULT '{}'::jsonb;
  END IF;
END$$;

-- Add device-level snooze_until timestamp
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='devices' AND column_name='snooze_until'
  ) THEN
    ALTER TABLE devices ADD COLUMN snooze_until TIMESTAMPTZ NULL;
    CREATE INDEX IF NOT EXISTS idx_devices_snooze_until ON devices(snooze_until);
    COMMENT ON COLUMN devices.snooze_until IS 'Global snooze until timestamp; when in the future, suppress notifications for this device';
  END IF;
END$$;

-- Add follow-level mute and snooze
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='follows' AND column_name='mute'
  ) THEN
    ALTER TABLE follows ADD COLUMN mute BOOLEAN NOT NULL DEFAULT false;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='follows' AND column_name='snooze_until'
  ) THEN
    ALTER TABLE follows ADD COLUMN snooze_until TIMESTAMPTZ NULL;
    CREATE INDEX IF NOT EXISTS idx_follows_snooze_until ON follows(snooze_until);
  END IF;
END$$;

COMMENT ON TABLE follows IS 'User follows for alert notifications with per-alert mute/snooze';
