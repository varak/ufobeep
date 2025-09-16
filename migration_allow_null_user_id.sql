-- Allow anonymous devices by making user_id nullable
-- This enables devices to register without authentication for proximity alerts

-- Drop foreign key constraint first
ALTER TABLE devices DROP CONSTRAINT IF EXISTS devices_user_id_fkey;

-- Make user_id nullable
ALTER TABLE devices ALTER COLUMN user_id DROP NOT NULL;

-- Re-add foreign key constraint but allow nulls
ALTER TABLE devices
ADD CONSTRAINT devices_user_id_fkey
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Update unique constraint to handle anonymous devices
-- Drop existing constraint
DROP INDEX IF EXISTS uq_devices_user_token_valid;

-- Create new constraint that handles null user_id for anonymous devices
CREATE UNIQUE INDEX uq_devices_user_token_valid
ON devices (user_id, push_token)
WHERE token_status = 'valid' AND user_id IS NOT NULL;

-- Add constraint for anonymous devices (device_id must be unique for anonymous devices)
CREATE UNIQUE INDEX uq_devices_anonymous_device_id
ON devices (device_id)
WHERE user_id IS NULL AND token_status = 'valid';

-- Add comment for documentation
COMMENT ON COLUMN devices.user_id IS 'User ID - null for anonymous devices that only receive proximity alerts';