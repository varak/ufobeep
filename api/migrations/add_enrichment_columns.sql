-- Add separate enrichment columns for better performance and cleaner architecture

ALTER TABLE sightings ADD COLUMN IF NOT EXISTS weather_data JSONB;
ALTER TABLE sightings ADD COLUMN IF NOT EXISTS celestial_data JSONB;
ALTER TABLE sightings ADD COLUMN IF NOT EXISTS aircraft_data JSONB;
ALTER TABLE sightings ADD COLUMN IF NOT EXISTS satellite_data JSONB;
ALTER TABLE sightings ADD COLUMN IF NOT EXISTS geocoding_data JSONB;
ALTER TABLE sightings ADD COLUMN IF NOT EXISTS content_analysis_data JSONB;

-- Add indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_sightings_weather_data ON sightings USING GIN (weather_data) WHERE weather_data IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sightings_celestial_data ON sightings USING GIN (celestial_data) WHERE celestial_data IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sightings_aircraft_data ON sightings USING GIN (aircraft_data) WHERE aircraft_data IS NOT NULL;

-- Keep the old enrichment_data column for backward compatibility during transition
-- Can be removed later once all code is updated