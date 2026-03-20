-- ═══════════════════════════════════════════════════════════════════════════
-- Fix infinite recursion in RLS policies
-- The admin check was querying profiles which triggered the same policy
-- ═══════════════════════════════════════════════════════════════════════════

-- Drop old policies that cause recursion
DROP POLICY IF EXISTS "Admins can manage jobs" ON jobs;
DROP POLICY IF EXISTS "Admins can view all applications" ON applications;
DROP POLICY IF EXISTS "Admins can update applications" ON applications;
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can manage questions" ON job_questions;
DROP POLICY IF EXISTS "Admins can view all answers" ON application_answers;

-- Create a SECURITY DEFINER function to check admin role
-- This bypasses RLS on profiles, breaking the recursion
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Re-create admin policies using the function
CREATE POLICY "Admins can manage jobs" ON jobs FOR ALL USING (is_admin());
CREATE POLICY "Admins can view all applications" ON applications FOR SELECT USING (is_admin());
CREATE POLICY "Admins can update applications" ON applications FOR UPDATE USING (is_admin());
CREATE POLICY "Admins can view all profiles" ON profiles FOR SELECT USING (is_admin());
CREATE POLICY "Admins can manage questions" ON job_questions FOR ALL USING (is_admin());
CREATE POLICY "Admins can view all answers" ON application_answers FOR SELECT USING (is_admin());
