-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Database Migration 03
-- Purpose: Add `sex` column to `animals` table for Mare / Stallion / Gelding classification
-- Target: Supabase / PostgreSQL 15+
-- Safe to execute: uses IF NOT EXISTS and non-destructive defaults
-- =====================================================================

ALTER TABLE public.animals 
  ADD COLUMN IF NOT EXISTS sex text DEFAULT 'mare';

-- Create an index for high performance species & sex queries
CREATE INDEX IF NOT EXISTS idx_animals_species_sex 
  ON public.animals (account_id, species, sex);
