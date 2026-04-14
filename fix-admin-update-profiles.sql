-- ═══════════════════════════════════════════════════════════════════════════
-- Fix: Allow admins to UPDATE any profile (staff management, banning, etc.)
-- The existing RLS policies only allow users to update their OWN profile
-- and admins to SELECT all profiles — but admins could not UPDATE others.
-- Run this in Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════════════════

-- Add missing admin UPDATE policy for profiles
-- Uses the is_admin() SECURITY DEFINER function created in supabase-fix-rls.sql
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
CREATE POLICY "Admins can update all profiles" ON profiles
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());
