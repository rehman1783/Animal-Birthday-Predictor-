-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Database Migration 04
-- Purpose: Create `markings` table for Animal & Foal Physical Markings & Identification
-- Target: Supabase / PostgreSQL 15+
-- Safe to execute: uses IF NOT EXISTS and RLS policies
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.markings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type text NOT NULL DEFAULT 'animal',
  owner_id text NOT NULL,
  left_side_image_url text,
  right_side_image_url text,
  head_view_image_url text,
  head_view_notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create unique index to guarantee 1 markings record per owner
CREATE UNIQUE INDEX IF NOT EXISTS idx_markings_owner 
  ON public.markings (owner_type, owner_id);

-- Enable RLS
ALTER TABLE public.markings ENABLE ROW LEVEL SECURITY;

-- Allow authenticated & anon access matching other tables
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'markings' AND policyname = 'allow_all_markings_access'
  ) THEN
    CREATE POLICY "allow_all_markings_access" ON public.markings
      FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;
