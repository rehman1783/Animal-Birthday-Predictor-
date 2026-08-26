-- ==============================================================================
-- Migration: 07_create_foaling_diary_entries.sql
-- Description: Create foaling_diary_entries table for Stud Management & Planner
-- Author: ABP Engineering Team
-- Date: 2026-08-26
-- ==============================================================================

-- 1. Create foaling_diary_entries table
CREATE TABLE IF NOT EXISTS public.foaling_diary_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    mare_id UUID REFERENCES public.animals(id) ON DELETE SET NULL,
    mare_name TEXT NOT NULL,
    microchip_no TEXT,
    stallion_name TEXT NOT NULL DEFAULT '',
    is_embryo_transfer BOOLEAN NOT NULL DEFAULT false,
    donor_mare_name TEXT,
    recipient_mare_name TEXT,
    breeding_method TEXT NOT NULL DEFAULT 'natural',
    service_date TIMESTAMPTZ NOT NULL,
    foaling_due_date TIMESTAMPTZ NOT NULL,
    min_due_date TIMESTAMPTZ NOT NULL,
    max_due_date TIMESTAMPTZ NOT NULL,
    current_paddock TEXT NOT NULL DEFAULT 'Main Broodmare Pasture',
    scan1_confirmed BOOLEAN NOT NULL DEFAULT false,
    scan2_confirmed BOOLEAN NOT NULL DEFAULT false,
    scan3_confirmed BOOLEAN NOT NULL DEFAULT false,
    twin_detected BOOLEAN NOT NULL DEFAULT false,
    is_foaled BOOLEAN NOT NULL DEFAULT false,
    notes TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_foaling_diary_user_id ON public.foaling_diary_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_foaling_diary_due_date ON public.foaling_diary_entries(foaling_due_date);
CREATE INDEX IF NOT EXISTS idx_foaling_diary_mare_id ON public.foaling_diary_entries(mare_id);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.foaling_diary_entries ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for Strict User Data Isolation
DROP POLICY IF EXISTS "Users can view their own foaling diary entries" ON public.foaling_diary_entries;
CREATE POLICY "Users can view their own foaling diary entries"
    ON public.foaling_diary_entries
    FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own foaling diary entries" ON public.foaling_diary_entries;
CREATE POLICY "Users can insert their own foaling diary entries"
    ON public.foaling_diary_entries
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own foaling diary entries" ON public.foaling_diary_entries;
CREATE POLICY "Users can update their own foaling diary entries"
    ON public.foaling_diary_entries
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own foaling diary entries" ON public.foaling_diary_entries;
CREATE POLICY "Users can delete their own foaling diary entries"
    ON public.foaling_diary_entries
    FOR DELETE
    USING (auth.uid() = user_id);

-- 5. Auto-update timestamp trigger
CREATE OR REPLACE FUNCTION public.handle_foaling_diary_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_foaling_diary_updated_at ON public.foaling_diary_entries;
CREATE TRIGGER trg_foaling_diary_updated_at
    BEFORE UPDATE ON public.foaling_diary_entries
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_foaling_diary_updated_at();
