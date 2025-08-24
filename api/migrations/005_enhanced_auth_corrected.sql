-- MP15: Enhanced Authentication System - Corrected Migration
-- Adds only missing columns for social login and magic links

-- Add missing columns (skip existing ones)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS magic_link_token VARCHAR(64),
ADD COLUMN IF NOT EXISTS magic_link_expires_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS google_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS apple_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS social_profile_data JSON,
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS login_methods JSON DEFAULT '["magic_link"]',
ADD COLUMN IF NOT EXISTS preferred_login_method VARCHAR(20) DEFAULT 'magic_link';

-- Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_users_magic_link_token ON users(magic_link_token) WHERE magic_link_token IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_apple_id ON users(apple_id) WHERE apple_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_last_login ON users(last_login_at);