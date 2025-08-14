-- Migration: Add comprehensive photo metadata table for astronomical/aircraft identification
-- Created for storing detailed EXIF, camera, and sensor data with photos

-- Create photo_metadata table
CREATE TABLE IF NOT EXISTS photo_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sighting_id UUID NOT NULL REFERENCES sightings(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size_bytes BIGINT,
    content_type VARCHAR(100),
    
    -- Extraction metadata
    exif_available BOOLEAN DEFAULT false,
    extraction_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    extraction_error TEXT,
    
    -- Location data (from EXIF GPS)
    exif_latitude DECIMAL(10,8),
    exif_longitude DECIMAL(11,8),
    exif_altitude DECIMAL(10,2),
    gps_speed DECIMAL(8,2),
    gps_speed_ref VARCHAR(10),
    gps_track DECIMAL(6,2),
    gps_track_ref VARCHAR(10),
    gps_img_direction DECIMAL(6,2),
    gps_img_direction_ref VARCHAR(10),
    gps_dest_bearing DECIMAL(6,2),
    gps_dest_bearing_ref VARCHAR(10),
    gps_date_stamp VARCHAR(50),
    gps_time_stamp VARCHAR(50),
    gps_map_datum VARCHAR(50),
    gps_processing_method VARCHAR(100),
    gps_area_info VARCHAR(255),
    gps_differential INTEGER,
    gps_h_positioning_error DECIMAL(8,2),
    
    -- Camera settings (crucial for astronomical analysis)
    exposure_time VARCHAR(50),
    f_number VARCHAR(50),
    iso_speed VARCHAR(50),
    focal_length VARCHAR(50),
    focal_length_35mm VARCHAR(50),
    max_aperture VARCHAR(50),
    subject_distance VARCHAR(50),
    flash VARCHAR(50),
    white_balance VARCHAR(50),
    exposure_mode VARCHAR(50),
    exposure_program VARCHAR(50),
    metering_mode VARCHAR(50),
    light_source VARCHAR(50),
    scene_capture_type VARCHAR(50),
    gain_control VARCHAR(50),
    contrast VARCHAR(50),
    saturation VARCHAR(50),
    sharpness VARCHAR(50),
    digital_zoom_ratio VARCHAR(50),
    
    -- Lens information
    lens_specification VARCHAR(255),
    lens_make VARCHAR(100),
    lens_model VARCHAR(100),
    
    -- Device orientation and compass data
    image_orientation VARCHAR(50),
    camera_direction DECIMAL(6,2),
    camera_direction_ref VARCHAR(10),
    movement_direction DECIMAL(6,2),
    movement_direction_ref VARCHAR(10),
    
    -- Timestamp data
    datetime_original VARCHAR(50),
    datetime_taken VARCHAR(50),
    datetime_digitized VARCHAR(50),
    image_datetime VARCHAR(50),
    subsec_time VARCHAR(10),
    subsec_time_original VARCHAR(10),
    subsec_time_digitized VARCHAR(10),
    timezone_offset VARCHAR(20),
    
    -- Image properties
    pixel_x_dimension INTEGER,
    pixel_y_dimension INTEGER,
    image_width INTEGER,
    image_length INTEGER,
    bits_per_sample VARCHAR(50),
    photometric_interpretation VARCHAR(50),
    samples_per_pixel INTEGER,
    x_resolution VARCHAR(50),
    y_resolution VARCHAR(50),
    resolution_unit VARCHAR(50),
    color_space VARCHAR(50),
    components_configuration VARCHAR(50),
    compressed_bits_per_pixel VARCHAR(50),
    
    -- Device and software information
    device_make VARCHAR(100),
    device_model VARCHAR(100),
    software VARCHAR(255),
    exif_version VARCHAR(50),
    flashpix_version VARCHAR(50),
    artist VARCHAR(255),
    copyright VARCHAR(255),
    image_description TEXT,
    user_comment TEXT,
    maker_note TEXT,
    
    -- Device sensor data (from UFOBeep app)
    sensor_latitude DECIMAL(10,8),
    sensor_longitude DECIMAL(11,8),
    sensor_altitude DECIMAL(8,2),
    sensor_accuracy DECIMAL(8,2),
    sensor_azimuth_deg DECIMAL(6,2),
    sensor_pitch_deg DECIMAL(6,2),
    sensor_roll_deg DECIMAL(6,2),
    sensor_hfov_deg DECIMAL(6,2),
    sensor_timestamp TIMESTAMP WITH TIME ZONE,
    
    -- Raw EXIF data for debugging/future processing
    raw_exif_keys TEXT[],
    raw_exif_data JSONB,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_photo_metadata_sighting_id ON photo_metadata(sighting_id);
CREATE INDEX IF NOT EXISTS idx_photo_metadata_filename ON photo_metadata(filename);
CREATE INDEX IF NOT EXISTS idx_photo_metadata_location ON photo_metadata(exif_latitude, exif_longitude);
CREATE INDEX IF NOT EXISTS idx_photo_metadata_datetime ON photo_metadata(datetime_original);
CREATE INDEX IF NOT EXISTS idx_photo_metadata_device ON photo_metadata(device_make, device_model);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_photo_metadata_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_photo_metadata_timestamp_trigger
    BEFORE UPDATE ON photo_metadata
    FOR EACH ROW
    EXECUTE FUNCTION update_photo_metadata_timestamp();

-- Add comment for documentation
COMMENT ON TABLE photo_metadata IS 'Comprehensive photo metadata for astronomical and aircraft identification services. Stores EXIF data, camera settings, GPS coordinates, device sensor data, and technical parameters needed for sky object analysis.';