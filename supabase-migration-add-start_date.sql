-- Add start_date column to jobs table
-- This migration adds a date column `start_date` used by the UI and admin forms.

BEGIN;

ALTER TABLE public.jobs
  ADD COLUMN IF NOT EXISTS start_date DATE;

COMMENT ON COLUMN public.jobs.start_date IS 'Expected start date (date-only) for job listings.';

COMMIT;
-- Add start_date column to jobs table
-- This migration adds an optional `start_date` column (date) to jobs.

BEGIN;

ALTER TABLE public.jobs
  ADD COLUMN IF NOT EXISTS start_date date;

-- Ensure existing rows are explicit (no-op if already NULL)
UPDATE public.jobs
SET start_date = NULL
WHERE start_date IS NULL;

COMMENT ON COLUMN public.jobs.start_date IS 'Optional planned start date for the job (date).';

COMMIT;
