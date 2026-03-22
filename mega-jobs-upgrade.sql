-- ==============================================================================
-- MASTER JOBS TABLE UPGRADE: 30+ ADVANCED SETTINGS
-- This script adds every single operational, legal, and aviation setting
-- compatible with the new full-page creator.
-- ==============================================================================

ALTER TABLE jobs 
-- Core Aviation & Demographics
ADD COLUMN IF NOT EXISTS min_age INTEGER,
ADD COLUMN IF NOT EXISTS max_age INTEGER,
ADD COLUMN IF NOT EXISTS experience_level TEXT DEFAULT 'Entry Level',
ADD COLUMN IF NOT EXISTS flight_hours_required INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS atc_hours_required INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS timezone_preference TEXT,
ADD COLUMN IF NOT EXISTS language_requirements TEXT,
ADD COLUMN IF NOT EXISTS aircraft_types TEXT,
ADD COLUMN IF NOT EXISTS base_hub TEXT,

-- Equipment & Requirements
ADD COLUMN IF NOT EXISTS training_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS discord_required BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS microphone_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS interview_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS flying_vatsim_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS livery_installation_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS sim_platform_preference TEXT DEFAULT 'Any',

-- Operational Meta
ADD COLUMN IF NOT EXISTS probation_period TEXT,
ADD COLUMN IF NOT EXISTS supervisor_name TEXT,
ADD COLUMN IF NOT EXISTS contact_email TEXT,
ADD COLUMN IF NOT EXISTS benefits TEXT,
ADD COLUMN IF NOT EXISTS weekly_flight_requirement INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS minimum_rank_required TEXT,
ADD COLUMN IF NOT EXISTS training_duration TEXT,

-- Application Handling
ADD COLUMN IF NOT EXISTS application_difficulty TEXT DEFAULT 'Medium',
ADD COLUMN IF NOT EXISTS application_review_time TEXT DEFAULT '2-3 Days',
ADD COLUMN IF NOT EXISTS referral_required BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS auto_reject_if_not_met BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS hide_applicant_count BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS custom_success_message TEXT;
