-- Migration: Add device_id column to sightings table
-- Date: 2025-09-07
-- Purpose: Link sightings to specific devices for analytics and troubleshooting
-- Safety: Uses IF NOT EXISTS and nullable column to avoid breaking existing data

-- Check if column already exists before adding
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sightings' AND column_name = 'device_id'
    ) THEN
        -- Add the column as nullable VARCHAR(255) to store device UUID/ID
        ALTER TABLE sightings ADD COLUMN device_id VARCHAR(255);
        
        -- Add comment explaining the column
        COMMENT ON COLUMN sightings.device_id IS 'UUID/ID of the device that reported this sighting';
        
        RAISE NOTICE 'Added device_id column to sightings table successfully';
    ELSE
        RAISE NOTICE 'device_id column already exists in sightings table';
    END IF;
END $$;

-- Add index separately (outside transaction to allow CONCURRENTLY)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sightings_device_id ON sightings (device_id);