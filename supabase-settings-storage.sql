-- ═══════════════════════════════════════════════════════════════════════════
-- Jet2 Jobs — Cloud Settings Storage
-- Run this in Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. Add settings JSONB column to profiles to store the 50+ custom toggles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS settings JSONB DEFAULT '{}'::jsonb;

-- 2. Ensure RLS allows the user to update their own profile settings
-- (Assuming standard profile RLS is already in place: "Profiles are updatable by owners")

-- 3. (Optional) Create a helper function if you want to merge settings server-side
-- But we'll handle merging in the Nuxt frontend for maximum flexibility.
