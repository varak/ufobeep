-- Migration: Add User Device Data and Marketing Tracking
-- Date: 2025-09-23
-- Purpose: Capture device technical data and marketing consent for admin dashboard

-- Add device technical data columns
ALTER TABLE users ADD COLUMN IF NOT EXISTS device_model VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS device_manufacturer VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS os_version VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS app_version VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS device_language VARCHAR(10);
ALTER TABLE users ADD COLUMN IF NOT EXISTS timezone VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS screen_resolution VARCHAR(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS device_memory_gb INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS storage_available_gb INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS network_type VARCHAR(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS battery_optimization_enabled BOOLEAN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS location_permission_type VARCHAR(20);

-- Add marketing and acquisition tracking
ALTER TABLE users ADD COLUMN IF NOT EXISTS marketing_consent BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS acquisition_source VARCHAR(50); -- 'google_play', 'website', 'referral'
ALTER TABLE users ADD COLUMN IF NOT EXISTS acquisition_campaign VARCHAR(100); -- UTM tracking
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_login_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_photo_url VARCHAR(500);

-- Create email marketing table for GDPR compliance
CREATE TABLE IF NOT EXISTS email_marketing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    consent_given_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    consent_source VARCHAR(50), -- 'google_signin', 'magic_link', 'manual'
    unsubscribed_at TIMESTAMP WITH TIME ZONE,
    unsubscribe_reason VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create analytics events table for user behavior tracking
CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB,
    session_id VARCHAR(100),
    device_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_marketing_consent ON users(marketing_consent) WHERE marketing_consent = TRUE;
CREATE INDEX IF NOT EXISTS idx_users_acquisition_source ON users(acquisition_source);
CREATE INDEX IF NOT EXISTS idx_users_device_model ON users(device_model);
CREATE INDEX IF NOT EXISTS idx_users_last_active ON users(last_active_at);

CREATE INDEX IF NOT EXISTS idx_email_marketing_consent ON email_marketing(consent_given_at) WHERE unsubscribed_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_email_marketing_user ON email_marketing(user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_user ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_events_created ON analytics_events(created_at);

-- Add comments for documentation
COMMENT ON COLUMN users.device_model IS 'Device model (e.g., Pixel 9a, iPhone 14 Pro)';
COMMENT ON COLUMN users.device_manufacturer IS 'Device manufacturer (e.g., Google, Apple, Samsung)';
COMMENT ON COLUMN users.os_version IS 'Operating system version (e.g., Android 14, iOS 17.1)';
COMMENT ON COLUMN users.app_version IS 'UFOBeep app version when data was captured';
COMMENT ON COLUMN users.marketing_consent IS 'User consent for marketing emails (GDPR compliant)';
COMMENT ON COLUMN users.acquisition_source IS 'Where user came from (google_play, website, etc.)';

COMMENT ON TABLE email_marketing IS 'GDPR-compliant email marketing consent tracking';
COMMENT ON TABLE analytics_events IS 'User behavior and interaction tracking for business intelligence';