-- Add granular permission columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS can_manage_jobs BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS can_manage_staff BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS can_ban_users BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS can_post_announcements BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS can_send_notifications BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS can_manage_notices BOOLEAN DEFAULT false;

-- Update the existing owner to have all permissions by default if they exist
UPDATE profiles SET
  can_manage_jobs = true,
  can_manage_staff = true,
  can_ban_users = true,
  can_post_announcements = true,
  can_send_notifications = true,
  can_manage_notices = true
WHERE discord_username = 'derkloking' OR role = 'admin';
