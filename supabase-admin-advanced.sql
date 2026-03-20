-- ═══════════════════════════════════════════════════════════════════════════
-- Jet2 Jobs — Advanced Admin Features Migration
-- Run this in Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════════════════

-- 1) ─── Staff Role on Profiles ───────────────────────────────────────────────
-- Granular staff role for display purposes (owner, admin, moderator, staff)
-- The existing 'role' column is kept for RLS backward compatibility
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS staff_role TEXT
  CHECK (staff_role IN ('owner', 'admin', 'moderator', 'staff'));

-- 2) ─── Application Notices ──────────────────────────────────────────────────
-- Announcements targeted at applicants, e.g. "Results will be out on XX.XX.XXXX"
CREATE TABLE IF NOT EXISTS application_notices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  target TEXT NOT NULL DEFAULT 'all' CHECK (target IN ('all', 'job')),
  target_job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
  is_active BOOLEAN NOT NULL DEFAULT true,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  author_name TEXT,
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE application_notices ENABLE ROW LEVEL SECURITY;

-- Anyone can view active notices
DROP POLICY IF EXISTS "Anyone can view active notices" ON application_notices;
CREATE POLICY "Anyone can view active notices" ON application_notices
  FOR SELECT USING (is_active = true);

-- Admins can manage all notices
DROP POLICY IF EXISTS "Admins can manage notices" ON application_notices;
CREATE POLICY "Admins can manage notices" ON application_notices FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- 3) ─── Extend Announcements with Author ─────────────────────────────────────
ALTER TABLE announcements ADD COLUMN IF NOT EXISTS author_name TEXT;

-- 4) ─── Extend Notifications with Admin Metadata ─────────────────────────────
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS sent_by_name TEXT;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS category TEXT
  DEFAULT 'system'
  CHECK (category IN ('system', 'admin_broadcast', 'application_notice', 'status_update'));

-- 5) ─── Extend Application Events with Author ───────────────────────────────
-- Drop the old constraint to allow new event types
ALTER TABLE application_events DROP CONSTRAINT IF EXISTS application_events_event_type_check;
ALTER TABLE application_events ADD CONSTRAINT application_events_event_type_check
  CHECK (event_type IN (
    'submitted', 'status_change', 'note_added', 'rated',
    'ai_flagged', 'ai_cleared', 'notice_posted', 'custom'
  ));

-- Add author_name column to events for display
ALTER TABLE application_events ADD COLUMN IF NOT EXISTS author_name TEXT;
