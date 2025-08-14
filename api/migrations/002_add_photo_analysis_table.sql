-- Migration: Add photo analysis results table
-- Created: 2025-08-14
-- Purpose: Store planet/satellite analysis results for photos

CREATE TABLE IF NOT EXISTS photo_analysis_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sighting_id UUID NOT NULL REFERENCES sightings(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    
    -- Analysis results
    classification VARCHAR(50), -- 'planet', 'satellite', 'unknown'
    matched_object VARCHAR(100), -- 'Mars', 'ISS', null
    confidence DECIMAL(5,3), -- 0.000-1.000
    angular_separation_deg DECIMAL(8,4), -- degrees
    
    -- Plate solving data
    field_center_ra DECIMAL(10,6), -- Right Ascension in degrees
    field_center_dec DECIMAL(10,6), -- Declination in degrees  
    field_radius_deg DECIMAL(8,4), -- Field radius in degrees
    astrometry_job_id VARCHAR(100), -- Astrometry.net job ID
    
    -- Observer data (for reference)
    observer_latitude DECIMAL(10,8),
    observer_longitude DECIMAL(11,8), 
    observer_elevation_m DECIMAL(8,2),
    observation_time TIMESTAMP WITH TIME ZONE,
    
    -- Processing metadata
    analysis_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'completed', 'failed'
    analysis_error TEXT,
    processing_duration_ms INTEGER,
    all_matches JSONB, -- Array of all potential matches
    raw_analysis_data JSONB, -- Full analysis response
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_photo_analysis_sighting ON photo_analysis_results(sighting_id);
CREATE INDEX IF NOT EXISTS idx_photo_analysis_classification ON photo_analysis_results(classification);
CREATE INDEX IF NOT EXISTS idx_photo_analysis_status ON photo_analysis_results(analysis_status);
CREATE INDEX IF NOT EXISTS idx_photo_analysis_confidence ON photo_analysis_results(confidence DESC);
CREATE INDEX IF NOT EXISTS idx_photo_analysis_created ON photo_analysis_results(created_at DESC);