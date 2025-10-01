-- Add name column to email_interests table
ALTER TABLE email_interests
ADD COLUMN IF NOT EXISTS name VARCHAR(255) DEFAULT '';
