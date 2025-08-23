-- Migration 004: Add Firebase Authentication Support (Fixed)
-- Adds Firebase UID column to existing UUID-based users table
-- Date: 2025-08-23

BEGIN;

-- Add Firebase UID column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(128) UNIQUE;

-- Create index for Firebase UID lookups (will be the new primary lookup)
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);

-- Add migration tracking
CREATE TABLE IF NOT EXISTS firebase_migration_log (
    id SERIAL PRIMARY KEY,
    user_uuid UUID,
    firebase_uid VARCHAR(128),
    username VARCHAR(50),
    migrated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    migration_type VARCHAR(50) DEFAULT 'uuid_to_firebase'
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
INSERT INTO firebase_migration_log (user_uuid, firebase_uid, username)
SELECT id, firebase_uid, username 
FROM users 
WHERE firebase_uid IS NOT NULL
ON CONFLICT DO NOTHING;

-- Update sightings table to reference Firebase UID
-- Check if sightings table exists and add firebase_uid column
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sightings') THEN
        ALTER TABLE sightings ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(128);
        
        -- Try to migrate sightings if there's a user reference
        IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'sightings' AND column_name = 'user_id') THEN
            UPDATE sightings 
            SET firebase_uid = users.firebase_uid
            FROM users 
            WHERE sightings.user_id = users.id
            AND sightings.firebase_uid IS NULL;
        END IF;
        
        CREATE INDEX IF NOT EXISTS idx_sightings_firebase_uid ON sightings(firebase_uid);
    END IF;
END $$;

-- Update alerts table similarly if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'alerts') THEN
        ALTER TABLE alerts ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(128);
        
        -- Try to migrate alerts if there's a user reference
        IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'user_id') THEN
            UPDATE alerts 
            SET firebase_uid = users.firebase_uid
            FROM users 
            WHERE alerts.user_id = users.id
            AND alerts.firebase_uid IS NULL;
        END IF;
        
        CREATE INDEX IF NOT EXISTS idx_alerts_firebase_uid ON alerts(firebase_uid);
    END IF;
END $$;

-- Clean up the temporary function
DROP FUNCTION IF EXISTS generate_migration_uid();

-- Verify migration results
SELECT 
    'Migration Results:' as status,
    COUNT(*) as total_users,
    COUNT(firebase_uid) as users_with_firebase_uid,
    COUNT(email) as users_with_email,
    COUNT(phone) as users_with_phone
FROM users;

COMMIT;

-- Success message
SELECT 'Firebase Auth migration completed successfully!' as result;