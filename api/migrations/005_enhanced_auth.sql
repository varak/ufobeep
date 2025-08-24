-- MP15: Enhanced Authentication System
-- Adds social login, magic links, and password authentication

ALTER TABLE users 
ADD COLUMN password_hash VARCHAR(255),
ADD COLUMN magic_link_token VARCHAR(64),
ADD COLUMN magic_link_expires_at TIMESTAMP,
ADD COLUMN google_id VARCHAR(255),
ADD COLUMN apple_id VARCHAR(255),
ADD COLUMN social_profile_data JSON,
ADD COLUMN last_login_at TIMESTAMP,
ADD COLUMN login_methods JSON DEFAULT '["magic_link"]',
ADD COLUMN preferred_login_method VARCHAR(20) DEFAULT 'magic_link';

-- Indexes for performance
CREATE INDEX idx_users_magic_link_token ON users(magic_link_token);
CREATE INDEX idx_users_password_hash ON users(email, password_hash) WHERE password_hash IS NOT NULL;
CREATE INDEX idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;
CREATE INDEX idx_users_apple_id ON users(apple_id) WHERE apple_id IS NOT NULL;
CREATE INDEX idx_users_last_login ON users(last_login_at);