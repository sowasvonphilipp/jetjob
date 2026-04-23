-- ═══════════════════════════════════════════════════════════════════════════
-- Jet2 Jobs — Audit Logs Table
-- Run this in Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('auth', 'app', 'sec', 'admin', 'system')),
  event TEXT NOT NULL,
  detail TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Users can only view their own audit logs
DROP POLICY IF EXISTS "Users can view own audit logs" ON audit_logs;
CREATE POLICY "Users can view own audit logs" 
  ON audit_logs FOR SELECT 
  USING (auth.uid() = user_id);

-- Admins can view all audit logs
DROP POLICY IF EXISTS "Admins can view all audit logs" ON audit_logs;
CREATE POLICY "Admins can view all audit logs" 
  ON audit_logs FOR SELECT 
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
  );

-- Users cannot insert their own logs manually; only via secure functions or service role.
-- BUT for client-side frontend logging to work until there's an RPC, we allow inserts if the user matches user_id.
DROP POLICY IF EXISTS "Users can insert own logs" ON audit_logs;
CREATE POLICY "Users can insert own logs" 
  ON audit_logs FOR INSERT 
  WITH CHECK (auth.uid() = user_id);
