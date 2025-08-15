-- Migration: Add multi-media primary fields to media_files table
-- Date: 2025-01-15
-- Description: Add primary media designation and user tracking fields

-- Check if media_files table exists, create if needed
CREATE TABLE IF NOT EXISTS media_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    upload_id VARCHAR(255) UNIQUE,
    sighting_id UUID REFERENCES sightings(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    url TEXT NOT NULL,
    size_bytes BIGINT NOT NULL,
    content_type VARCHAR(255),
    checksum VARCHAR(255),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add new columns for primary media functionality
ALTER TABLE media_files 
ADD COLUMN IF NOT EXISTS is_primary BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS uploaded_by_user_id UUID REFERENCES users(id),
ADD COLUMN IF NOT EXISTS upload_order INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS display_priority INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS contributed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Ensure only one primary media file per sighting
CREATE UNIQUE INDEX IF NOT EXISTS idx_media_files_primary_per_sighting 
ON media_files(sighting_id) 
WHERE is_primary = TRUE;

-- Index for efficient media retrieval with proper ordering
CREATE INDEX IF NOT EXISTS idx_media_files_sighting_priority 
ON media_files(sighting_id, display_priority DESC, upload_order ASC);

-- Index for user contributions tracking
CREATE INDEX IF NOT EXISTS idx_media_files_uploaded_by_user 
ON media_files(uploaded_by_user_id, contributed_at DESC);

-- Update existing media files to have proper primary designation
-- Mark the first uploaded media file for each sighting as primary
WITH first_media AS (
    SELECT DISTINCT ON (sighting_id) 
           id, 
           sighting_id,
           ROW_NUMBER() OVER (PARTITION BY sighting_id ORDER BY uploaded_at ASC, created_at ASC) as rn
    FROM media_files
    WHERE is_primary = FALSE
)
UPDATE media_files 
SET is_primary = TRUE, 
    upload_order = 0
FROM first_media
WHERE media_files.id = first_media.id 
  AND first_media.rn = 1;

-- Set upload_order for remaining media files
WITH ordered_media AS (
    SELECT id, 
           ROW_NUMBER() OVER (PARTITION BY sighting_id ORDER BY uploaded_at ASC, created_at ASC) - 1 as new_order
    FROM media_files
    WHERE upload_order = 0 AND is_primary = FALSE
)
UPDATE media_files 
SET upload_order = ordered_media.new_order
FROM ordered_media
WHERE media_files.id = ordered_media.id;

-- Add comment to table
COMMENT ON COLUMN media_files.is_primary IS 'Designates the primary media file for display in lists and thumbnails';
COMMENT ON COLUMN media_files.uploaded_by_user_id IS 'User who uploaded this media file (may be different from sighting reporter)';
COMMENT ON COLUMN media_files.upload_order IS 'Order in which media was uploaded (0=original, 1=first additional, etc.)';
COMMENT ON COLUMN media_files.display_priority IS 'Manual priority for display order (higher = more prominent)';
COMMENT ON COLUMN media_files.contributed_at IS 'When this media was added to the sighting';