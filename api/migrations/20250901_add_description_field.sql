-- 20250901_add_description_field.sql
-- Add description field to alerts table for enhanced MUFON data

ALTER TABLE alerts
  ADD COLUMN IF NOT EXISTS description TEXT;