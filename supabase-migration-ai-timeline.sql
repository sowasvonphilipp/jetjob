-- ═══════════════════════════════════════════════════════════════════════════
-- Jet2 Jobs — AI Detection & Timeline Migration
-- Run AFTER the questions migration
-- ═══════════════════════════════════════════════════════════════════════════

-- Add AI detection fields to applications
ALTER TABLE applications ADD COLUMN IF NOT EXISTS ai_scores JSONB DEFAULT '[]';
ALTER TABLE applications ADD COLUMN IF NOT EXISTS ai_flagged BOOLEAN NOT NULL DEFAULT false;

-- Add AI score per answer
ALTER TABLE application_answers ADD COLUMN IF NOT EXISTS ai_score NUMERIC(5,2);

-- Timeline events table
CREATE TABLE IF NOT EXISTS application_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL CHECK (event_type IN (
    'submitted', 'status_change', 'note_added', 'rated', 'ai_flagged', 'ai_cleared'
  )),
  description TEXT NOT NULL,
  metadata JSONB,
  created_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS for events
ALTER TABLE application_events ENABLE ROW LEVEL SECURITY;

-- Users can view events on their own applications
CREATE POLICY "Users can view own events" ON application_events FOR SELECT USING (
  EXISTS (SELECT 1 FROM applications WHERE applications.id = application_id AND applications.user_id = auth.uid())
);

-- Admins can do everything with events
CREATE POLICY "Admins can manage events" ON application_events FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- Allow anyone to insert events (triggered server-side)
CREATE POLICY "Anyone can insert events" ON application_events FOR INSERT WITH CHECK (true);
