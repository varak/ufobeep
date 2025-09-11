-- Add short_url column to sightings table
ALTER TABLE sightings ADD COLUMN short_url VARCHAR(5);

-- Create unique index on short_url
CREATE UNIQUE INDEX idx_sightings_short_url ON sightings(short_url);

-- Python function to generate short URL (same as shared Node.js version)
CREATE OR REPLACE FUNCTION generate_short_url(input_text TEXT) 
RETURNS VARCHAR(5) AS $$
DECLARE
    safe_chars TEXT := '23456789abcdefghjkmnpqrstuvwxyz';
    hash_val BIGINT := 0;
    char_code INTEGER;
    short_id TEXT := '';
    num BIGINT;
    i INTEGER;
BEGIN
    -- Calculate hash (djb2 algorithm)
    FOR i IN 1..LENGTH(input_text) LOOP
        char_code := ASCII(SUBSTRING(input_text, i, 1));
        hash_val := ((hash_val << 5) - hash_val) + char_code;
        hash_val := hash_val & 4294967295; -- Keep as 32-bit
    END LOOP;
    
    -- Convert hash to safe character string
    num := ABS(hash_val);
    FOR i IN 1..5 LOOP
        short_id := SUBSTRING(safe_chars, (num % LENGTH(safe_chars)) + 1, 1) || short_id;
        num := num / LENGTH(safe_chars);
    END LOOP;
    
    RETURN short_id;
END;
$$ LANGUAGE plpgsql;

-- Update existing records with short URLs
UPDATE sightings 
SET short_url = generate_short_url(id::TEXT) 
WHERE short_url IS NULL;

-- Make short_url NOT NULL after populating existing records
ALTER TABLE sightings ALTER COLUMN short_url SET NOT NULL;