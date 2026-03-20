-- ═══════════════════════════════════════════════════════════════════════════
-- Jet2 Jobs — Supabase Database Setup
-- Run this in Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════════════════

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── Jobs table ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  position TEXT NOT NULL,
  title TEXT NOT NULL,
  department TEXT NOT NULL DEFAULT 'General',
  short_description TEXT NOT NULL,
  long_description TEXT NOT NULL DEFAULT '',
  salary TEXT,
  location TEXT NOT NULL DEFAULT 'Remote',
  image_url TEXT,
  posted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  closing_at TIMESTAMPTZ,
  applicant_limit INTEGER,
  applicant_count INTEGER NOT NULL DEFAULT 0,
  requirements INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Applications table ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  discord_username TEXT,
  discord_avatar TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'accepted', 'rejected')),
  cover_letter TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(job_id, user_id)
);

-- ─── Profiles table ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY,
  discord_id TEXT,
  discord_username TEXT,
  discord_avatar TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Example jobs ────────────────────────────────────────────────────────────
INSERT INTO jobs (position, title, department, short_description, long_description, salary, location, image_url, posted_at, closing_at, applicant_limit, requirements) VALUES
(
  'Cabin Crew Member',
  'Cabin Crew Member',
  'In-flight',
  'Serve passengers, ensure safety on board and keep the cabin running smoothly. No experience needed — we train you.',
  E'As a Cabin Crew Member at Jet2 Roblox Airline, you will be responsible for ensuring the safety and comfort of all passengers during flights. Your duties include conducting pre-flight safety checks, delivering safety demonstrations, serving food and beverages, and handling any in-flight emergencies.\n\nNo prior experience is required — we provide comprehensive training to all new crew members. You will learn emergency procedures, customer service excellence, and cabin management skills.\n\nThis is a great entry-level position for anyone passionate about aviation in the Roblox community.',
  'Volunteer',
  'In-game (Roblox)',
  'https://media.discordapp.net/attachments/1449762217464565893/1483538750867767367/image.png?ex=69baf4a1&is=69b9a321&hm=d1edf9cf586e2b15f339ceb21187f4821a449632e56b0acd05b347bd3d32beac&=&format=webp&quality=lossless&width=1782&height=872',
  now(),
  now() + interval '21 days',
  10,
  3
),
(
  'First Officer',
  'First Officer',
  'Flight Deck',
  'Fly alongside our senior captains, learn procedures from day one, and work your way up to Captain over time.',
  E'As a First Officer at Jet2 Roblox Airline, you will serve as the co-pilot alongside experienced captains. You will be responsible for assisting with pre-flight planning, navigation, communication with ATC, and executing standard operating procedures.\n\nRequirements include basic knowledge of flight simulation controls, ability to follow standard procedures, and willingness to complete our training program.\n\nThis position offers a clear career path — demonstrate your skills and dedication, and you can progress to Captain.',
  'Volunteer',
  'In-game (Roblox)',
  'https://cdn.discordapp.com/attachments/1449762217464565893/1482711721658548224/image.png?ex=69ba9565&is=69b943e5&hm=02911866ce64660939a774dbd170fd466688d7b4200b9566e0b0bb15e399ed17&',
  now(),
  now() + interval '14 days',
  5,
  5
),
(
  'Ground Operations Agent',
  'Ground Operations Agent',
  'Ground Crew',
  'Coordinate gate assignments, manage pushback and handle ground logistics to keep flights on schedule.',
  E'As a Ground Operations Agent, you will play a critical role in ensuring smooth airport operations at Jet2 Roblox Airline. Your responsibilities include coordinating aircraft parking, managing pushback procedures, directing ground traffic, and communicating with flight crew.\n\nYou will work closely with pilots and other ground staff to maintain on-time performance. This role requires attention to detail and the ability to work efficiently under time pressure.\n\nTraining is provided for all procedures.',
  'Volunteer',
  'In-game (Roblox)',
  NULL,
  now(),
  now() + interval '30 days',
  8,
  2
);

-- ─── Row Level Security ──────────────────────────────────────────────────────
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Jobs: anyone can read active jobs
CREATE POLICY "Anyone can view active jobs" ON jobs FOR SELECT USING (is_active = true);
-- Jobs: admins can do everything
CREATE POLICY "Admins can manage jobs" ON jobs FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- Applications: users see own
CREATE POLICY "Users can view own applications" ON applications FOR SELECT USING (auth.uid() = user_id);
-- Applications: users can apply
CREATE POLICY "Users can create applications" ON applications FOR INSERT WITH CHECK (auth.uid() = user_id);
-- Applications: admins see all
CREATE POLICY "Admins can view all applications" ON applications FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);
-- Applications: admins can update status
CREATE POLICY "Admins can update applications" ON applications FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- Profiles: users see own
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
-- Profiles: admins see all
CREATE POLICY "Admins can view all profiles" ON profiles FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- ─── Auto-update applicant count ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_applicant_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE jobs SET applicant_count = applicant_count + 1 WHERE id = NEW.job_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE jobs SET applicant_count = applicant_count - 1 WHERE id = OLD.job_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_application_change
  AFTER INSERT OR DELETE ON applications
  FOR EACH ROW
  EXECUTE FUNCTION update_applicant_count();

-- ─── Auto-create profile on Discord signup ───────────────────────────────────
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, discord_id, discord_username, discord_avatar)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'provider_id',
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.raw_user_meta_data ->> 'name', NEW.raw_user_meta_data ->> 'user_name'),
    NEW.raw_user_meta_data ->> 'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
