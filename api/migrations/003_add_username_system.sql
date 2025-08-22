-- Migration 003: Username System Implementation - MP13-1
-- Creates anonymous users for existing device IDs and enables username-based identification

-- Step 1: Create anonymous users for existing device IDs that don't have users
-- This handles the case where we have sightings with device_id but no user
INSERT INTO users (id, username, email, password_hash, display_name, alert_range_km, min_alert_level, 
                   push_notifications, email_notifications, share_location, public_profile, 
                   preferred_language, units_metric, is_active, is_verified, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    'legacy.' || replace(device_id, '-', '.') as username,  -- Convert device IDs to username format
    NULL as email,
    NULL as password_hash,  -- Anonymous user
    NULL as display_name,
    50.0 as alert_range_km,  -- Default
    'low' as min_alert_level,  -- Default
    true as push_notifications,
    false as email_notifications,
    true as share_location,
    false as public_profile,
    'en' as preferred_language,
    true as units_metric,
    true as is_active,
    false as is_verified,
    COALESCE(MIN(created_at), NOW()) as created_at,  -- Use earliest sighting timestamp
    NOW() as updated_at
FROM sightings 
WHERE device_id IS NOT NULL 
  AND device_id != ''
  AND reporter_id IS NULL  -- Only for sightings without users
GROUP BY device_id
ON CONFLICT (username) DO NOTHING;  -- Skip if username already exists

-- Step 2: Update sightings to link to the newly created users based on device_id
UPDATE sightings 
SET reporter_id = users.id
FROM users 
WHERE sightings.device_id IS NOT NULL 
  AND sightings.device_id != ''
  AND sightings.reporter_id IS NULL
  AND users.username = 'legacy.' || replace(sightings.device_id, '-', '.');

-- Step 3: Create index for efficient username lookups (if not exists)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_username ON users(username);

-- Step 4: Create a function to generate new usernames (for API use)
CREATE OR REPLACE FUNCTION generate_unique_username()
RETURNS TEXT AS $$
DECLARE
    adjectives TEXT[] := ARRAY[
        'cosmic', 'stellar', 'galactic', 'lunar', 'solar', 'orbital',
        'nebular', 'astral', 'celestial', 'ethereal', 'starlit', 'moonlit',
        'radiant', 'luminous', 'glowing', 'shimmering', 'drifting', 'floating',
        'distant', 'ancient', 'mysterious', 'enigmatic', 'phantom', 'spectral',
        'electric', 'magnetic', 'quantum', 'plasma', 'fusion', 'atomic',
        'binary', 'digital', 'cyber', 'neon', 'chrome', 'crystal',
        'arctic', 'frozen', 'blazing', 'burning', 'searing', 'molten',
        'silent', 'whispering', 'echoing', 'resonant', 'harmonic', 'sonic'
    ];
    
    nouns TEXT[] := ARRAY[
        'whisper', 'echo', 'signal', 'beacon', 'pulse', 'wave',
        'orbit', 'trajectory', 'vector', 'comet', 'meteor', 'asteroid', 
        'galaxy', 'nebula', 'quasar', 'pulsar', 'supernova', 'blackhole',
        'star', 'planet', 'moon', 'satellite', 'probe', 'vessel',
        'craft', 'ship', 'scanner', 'detector', 'observer', 'watcher',
        'wanderer', 'traveler', 'explorer', 'navigator', 'pilot', 'captain',
        'ghost', 'phantom', 'shadow', 'specter', 'entity', 'being',
        'light', 'flash', 'glimmer', 'spark', 'glow', 'aura',
        'void', 'plasma', 'energy', 'force', 'field', 'matrix',
        'code', 'cipher', 'key', 'token', 'byte', 'node'
    ];
    
    username_candidate TEXT;
    attempt_count INTEGER := 0;
    max_attempts INTEGER := 100;
BEGIN
    LOOP
        -- Generate a candidate username
        username_candidate := 
            adjectives[1 + floor(random() * array_length(adjectives, 1))::int] || '.' ||
            nouns[1 + floor(random() * array_length(nouns, 1))::int] || '.' ||
            lpad(floor(random() * 10000)::text, 4, '0');
        
        -- Check if this username is available
        IF NOT EXISTS (SELECT 1 FROM users WHERE username = username_candidate) THEN
            RETURN username_candidate;
        END IF;
        
        attempt_count := attempt_count + 1;
        IF attempt_count >= max_attempts THEN
            RAISE EXCEPTION 'Unable to generate unique username after % attempts', max_attempts;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Step 5: Add a helper function to get or create user by device ID
CREATE OR REPLACE FUNCTION get_or_create_user_by_device_id(device_id_param TEXT)
RETURNS UUID AS $$
DECLARE
    user_uuid UUID;
    generated_username TEXT;
BEGIN
    -- First try to find existing user by device ID pattern
    SELECT id INTO user_uuid 
    FROM users 
    WHERE username = 'legacy.' || replace(device_id_param, '-', '.');
    
    IF user_uuid IS NOT NULL THEN
        RETURN user_uuid;
    END IF;
    
    -- If not found, create a new user with generated username
    generated_username := generate_unique_username();
    
    INSERT INTO users (
        id, username, email, password_hash, display_name, 
        alert_range_km, min_alert_level, push_notifications, 
        email_notifications, share_location, public_profile, 
        preferred_language, units_metric, is_active, is_verified, 
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(), generated_username, NULL, NULL, NULL,
        50.0, 'low', true, false, true, false, 'en', true, true, false,
        NOW(), NOW()
    ) RETURNING id INTO user_uuid;
    
    RETURN user_uuid;
END;
$$ LANGUAGE plpgsql;

-- Step 6: Add comments for documentation
COMMENT ON FUNCTION generate_unique_username() IS 'Generates unique cosmic-themed usernames like cosmic.whisper.7823 for MP13-1';
COMMENT ON FUNCTION get_or_create_user_by_device_id(TEXT) IS 'Gets existing user or creates new user for device ID, used in MP13-1 transition';

-- Migration completed
SELECT 
    COUNT(*) as total_users,
    COUNT(*) FILTER (WHERE username LIKE 'legacy.%') as legacy_users,
    COUNT(*) FILTER (WHERE username NOT LIKE 'legacy.%') as new_users
FROM users;