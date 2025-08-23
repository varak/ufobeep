-- Migration 004: Add Firebase Authentication Support
-- Adds Firebase UID column and migrates from device ID system
-- Date: 2025-08-23

BEGIN;

-- Add Firebase UID column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(128) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE;

-- Create index for Firebase UID lookups (will be the new primary lookup)
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);

-- Add migration tracking
CREATE TABLE IF NOT EXISTS firebase_migration_log (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(255),
    firebase_uid VARCHAR(128),
    username VARCHAR(50),
    migrated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    migration_type VARCHAR(50) DEFAULT 'device_to_firebase'
);

-- Create a temporary function to generate Firebase-compatible UIDs for migration
-- This mimics Firebase UID format (28 character alphanumeric)
CREATE OR REPLACE FUNCTION generate_migration_uid() RETURNS VARCHAR(28) AS $$
DECLARE
    chars VARCHAR(62) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result VARCHAR(28) := '';
    i INTEGER;
BEGIN
    FOR i IN 1..28 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Migrate existing users to have Firebase UIDs
-- This ensures existing users can continue using the app seamlessly
UPDATE users 
SET firebase_uid = generate_migration_uid()
WHERE firebase_uid IS NULL;

-- Log the migration for tracking
INSERT INTO firebase_migration_log (device_id, firebase_uid, username)
SELECT device_id, firebase_uid, username 
FROM users 
WHERE firebase_uid IS NOT NULL
ON CONFLICT DO NOTHING;

-- Update any existing sightings to reference Firebase UID
-- Add firebase_uid column to sightings if it doesn't exist
ALTER TABLE sightings ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(128);

-- Migrate sightings to use Firebase UID
UPDATE sightings 
SET firebase_uid = users.firebase_uid
FROM users 
WHERE sightings.device_id = users.device_id
AND sightings.firebase_uid IS NULL;

-- Create index for sightings Firebase UID lookups
CREATE INDEX IF NOT EXISTS idx_sightings_firebase_uid ON sightings(firebase_uid);

-- Update alerts table similarly
ALTER TABLE alerts ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(128);

UPDATE alerts 
SET firebase_uid = users.firebase_uid
FROM users 
WHERE alerts.device_id = users.device_id
AND alerts.firebase_uid IS NULL;

CREATE INDEX IF NOT EXISTS idx_alerts_firebase_uid ON alerts(firebase_uid);

-- Update any other tables that reference users
-- Add similar updates for other user-related tables as needed

-- Create view for backwards compatibility during transition
CREATE OR REPLACE VIEW users_with_device_compat AS
SELECT 
    id,
    firebase_uid,
    device_id,
    username,
    email,
    phone_number,
    display_name,
    alert_range_km,
    units_metric,
    preferred_language,
    email_verified,
    phone_verified,
    created_at,
    last_active,
    is_verified
FROM users;

-- Add constraint to ensure either device_id or firebase_uid exists
-- (During transition period, then we'll make firebase_uid NOT NULL)
ALTER TABLE users ADD CONSTRAINT users_has_identifier 
CHECK (device_id IS NOT NULL OR firebase_uid IS NOT NULL);

-- Clean up the temporary function
DROP FUNCTION IF EXISTS generate_migration_uid();

COMMIT;

-- Post-migration notes:
-- 1. All existing users now have firebase_uid assigned
-- 2. New registrations should use Firebase Auth and set firebase_uid
-- 3. API endpoints should gradually transition to use firebase_uid
-- 4. Once fully migrated, device_id column can be made nullable or removed
-- 5. firebase_uid should become NOT NULL after full migration