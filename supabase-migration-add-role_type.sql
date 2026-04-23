-- Add role_type column to jobs table
-- This migration adds a text column `role_type` (e.g. 'general', 'organization')
-- and sets a sensible default for existing rows.

BEGIN;

ALTER TABLE public.jobs
  ADD COLUMN IF NOT EXISTS role_type text DEFAULT 'general';

UPDATE public.jobs
SET role_type = 'general'
WHERE role_type IS NULL;

COMMENT ON COLUMN public.jobs.role_type IS 'Role classification (e.g., general, organization) used by admin templates and UI.';

COMMIT;
