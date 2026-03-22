-- ==============================================================================
-- ADD 20 NEW ADVANCED SETTINGS AND METADATA TO JOBS TABLE
-- This seamlessly powers the new Fullpage Job Wizard and Application Dashboard
-- ==============================================================================

ALTER TABLE jobs 
ADD COLUMN IF NOT EXISTS min_age INTEGER,
ADD COLUMN IF NOT EXISTS max_age INTEGER,
ADD COLUMN IF NOT EXISTS experience_level TEXT DEFAULT 'Entry Level',
ADD COLUMN IF NOT EXISTS flight_hours_required INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS atc_hours_required INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS training_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS discord_required BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS microphone_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS timezone_preference TEXT,
ADD COLUMN IF NOT EXISTS language_requirements TEXT,
ADD COLUMN IF NOT EXISTS aircraft_types TEXT,
ADD COLUMN IF NOT EXISTS base_hub TEXT,
ADD COLUMN IF NOT EXISTS benefits TEXT,
ADD COLUMN IF NOT EXISTS application_difficulty TEXT DEFAULT 'Medium',
ADD COLUMN IF NOT EXISTS interview_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS probation_period TEXT,
ADD COLUMN IF NOT EXISTS supervisor_name TEXT,
ADD COLUMN IF NOT EXISTS contact_email TEXT,
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS hide_applicant_count BOOLEAN DEFAULT false;
