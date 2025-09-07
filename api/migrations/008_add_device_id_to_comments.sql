-- Migration 008: Add device_id to comments table
-- Enables device-level exclusion for comment notifications

-- Add device_id column to comments table (nullable for existing comments)
ALTER TABLE comments 
ADD COLUMN device_id TEXT;

-- Add index for device_id lookups
CREATE INDEX idx_comments_device_id ON comments(device_id);

-- Add comment for documentation
COMMENT ON COLUMN comments.device_id IS 'Device ID that posted the comment - enables device-level notification exclusion';

-- Migration completed
SELECT 'Added device_id column to comments table' AS status;