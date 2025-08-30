-- Migration 006: Comments and Follows System - Sprint B (MP16)
-- Creates tables for comment threads and user follows on alerts

-- Comments table for threaded discussions on alerts (sightings)
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    sighting_id UUID NOT NULL REFERENCES sightings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL CHECK (length(body) >= 1 AND length(body) <= 2000),
    media_url TEXT, -- Optional attached media
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Follows table for users following alerts (sightings) to get notifications
CREATE TABLE follows (
    id SERIAL PRIMARY KEY,
    sighting_id UUID NOT NULL REFERENCES sightings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    -- Prevent duplicate follows
    UNIQUE(sighting_id, user_id)
);

-- Indexes for performance
CREATE INDEX idx_comments_sighting_id ON comments(sighting_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);
CREATE INDEX idx_comments_user_id ON comments(user_id);

CREATE INDEX idx_follows_sighting_id ON follows(sighting_id);
CREATE INDEX idx_follows_user_id ON follows(user_id);
CREATE INDEX idx_follows_created_at ON follows(created_at DESC);

-- Comments for documentation
COMMENT ON TABLE comments IS 'User comments on UFO sighting alerts - Sprint B (MP16)';
COMMENT ON TABLE follows IS 'User follows for alert notifications - Sprint B (MP16)';

COMMENT ON COLUMN comments.body IS 'Comment text content, 1-2000 chars';
COMMENT ON COLUMN comments.media_url IS 'Optional attached image/video URL';
COMMENT ON COLUMN follows.sighting_id IS 'Sighting/alert being followed for notifications';

-- Migration completed - show counts
SELECT 'Comments and follows tables created successfully' AS status;