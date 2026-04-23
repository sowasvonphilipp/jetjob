-- ═══════════════════════════════════════════════════════════════════════════
-- Jet2 Jobs — Questions & Ratings Migration
-- Run this AFTER the initial supabase-setup.sql
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Add rating to applications ──────────────────────────────────────────────
ALTER TABLE applications ADD COLUMN IF NOT EXISTS rating INTEGER CHECK (rating >= 1 AND rating <= 5);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- ─── Job questions table ─────────────────────────────────────────────────────
-- Each job can have multiple questions, each with a type
-- Types: text, textarea, select, checkbox, number
CREATE TABLE IF NOT EXISTS job_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'textarea', 'select', 'checkbox', 'number')),
  options JSONB,            -- for 'select' type: ["Option A", "Option B", ...]
  required BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Application answers table ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS application_answers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES job_questions(id) ON DELETE CASCADE,
  answer TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(application_id, question_id)
);

-- ─── RLS for job_questions ───────────────────────────────────────────────────
ALTER TABLE job_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE application_answers ENABLE ROW LEVEL SECURITY;

-- Anyone can read questions (needed to display the form)
CREATE POLICY "Anyone can view questions" ON job_questions FOR SELECT USING (true);
-- Admins manage questions
CREATE POLICY "Admins can manage questions" ON job_questions FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- Users can insert their own answers
CREATE POLICY "Users can insert answers" ON application_answers FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM applications WHERE applications.id = application_id AND applications.user_id = auth.uid())
);
-- Users can view their own answers
CREATE POLICY "Users can view own answers" ON application_answers FOR SELECT USING (
  EXISTS (SELECT 1 FROM applications WHERE applications.id = application_id AND applications.user_id = auth.uid())
);
-- Admins can view all answers
CREATE POLICY "Admins can view all answers" ON application_answers FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- ─── Example questions for existing jobs ─────────────────────────────────────
-- Get the first job (Cabin Crew Member) and add questions
DO $$
DECLARE
  cabin_crew_id UUID;
  first_officer_id UUID;
  ground_ops_id UUID;
BEGIN
  SELECT id INTO cabin_crew_id FROM jobs WHERE title = 'Cabin Crew Member' LIMIT 1;
  SELECT id INTO first_officer_id FROM jobs WHERE title = 'First Officer' LIMIT 1;
  SELECT id INTO ground_ops_id FROM jobs WHERE title = 'Ground Operations Agent' LIMIT 1;

  -- ── Cabin Crew Questions ──
  IF cabin_crew_id IS NOT NULL THEN
    INSERT INTO job_questions (job_id, question, type, options, required, sort_order) VALUES
    (cabin_crew_id, 'What is your Roblox username?', 'text', NULL, true, 1),
    (cabin_crew_id, 'How old are you?', 'number', NULL, true, 2),
    (cabin_crew_id, 'What timezone are you in?', 'select', '["UTC-8 (PST)", "UTC-5 (EST)", "UTC+0 (GMT)", "UTC+1 (CET)", "UTC+2 (EET)", "UTC+8 (SGT)", "UTC+10 (AEST)", "Other"]', true, 3),
    (cabin_crew_id, 'Why do you want to join Jet2 as cabin crew?', 'textarea', NULL, true, 4),
    (cabin_crew_id, 'Do you have any previous experience in Roblox yes?', 'select', '["No experience", "Less than 3 months", "3-6 months", "6-12 months", "1+ year"]', true, 5),
    (cabin_crew_id, 'Are you available for at least 2 training sessions per week?', 'checkbox', NULL, true, 6),
    (cabin_crew_id, 'Tell us anything else you would like us to know (optional)', 'textarea', NULL, false, 7);
  END IF;

  -- ── First Officer Questions ──
  IF first_officer_id IS NOT NULL THEN
    INSERT INTO job_questions (job_id, question, type, options, required, sort_order) VALUES
    (first_officer_id, 'What is your Roblox username?', 'text', NULL, true, 1),
    (first_officer_id, 'How many flight hours do you have in Roblox flight sims?', 'select', '["0-10 hours", "10-50 hours", "50-100 hours", "100-500 hours", "500+ hours"]', true, 2),
    (first_officer_id, 'Which flight sim platforms have you used?', 'textarea', NULL, true, 3),
    (first_officer_id, 'Do you know standard ATC communication procedures?', 'select', '["Not at all", "Basic understanding", "Intermediate", "Advanced"]', true, 4),
    (first_officer_id, 'Describe a situation where you had to follow strict procedures under pressure.', 'textarea', NULL, true, 5),
    (first_officer_id, 'Are you willing to complete a 2-week training program before flying?', 'checkbox', NULL, true, 6),
    (first_officer_id, 'Link to any flying clips or showcase (optional)', 'text', NULL, false, 7);
  END IF;

  -- ── Ground Ops Questions ──
  IF ground_ops_id IS NOT NULL THEN
    INSERT INTO job_questions (job_id, question, type, options, required, sort_order) VALUES
    (ground_ops_id, 'What is your Roblox username?', 'text', NULL, true, 1),
    (ground_ops_id, 'What interests you about ground operations?', 'textarea', NULL, true, 2),
    (ground_ops_id, 'How would you rate your attention to detail?', 'select', '["Average", "Good", "Excellent"]', true, 3),
    (ground_ops_id, 'Are you comfortable communicating with pilots via radio?', 'checkbox', NULL, true, 4),
    (ground_ops_id, 'What days are you typically available?', 'select', '["Weekdays only", "Weekends only", "Both weekdays and weekends", "Varies"]', true, 5);
  END IF;
END $$;
