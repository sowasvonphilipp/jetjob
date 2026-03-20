-- Update the Applications Status Constraint to allow 'interview'
ALTER TABLE applications DROP CONSTRAINT IF EXISTS applications_status_check;
ALTER TABLE applications ADD CONSTRAINT applications_status_check 
  CHECK (status IN ('pending', 'reviewing', 'interview', 'accepted', 'rejected'));
