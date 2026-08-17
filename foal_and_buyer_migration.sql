-- ====================================================================
-- ABP STANDALONE EXTENSION MIGRATION: FOALS & BUYER INFORMATION
-- ====================================================================
-- Description: Adds buyer/new owner information and ensures all required
-- columns, indexes, and RLS policies are available for Foal records.
-- Safe to run multiple times (idempotent with 'if not exists').
-- ====================================================================

-- 1. Ensure Foals Table Extensions
alter table if exists public.foals
  add column if not exists buyer_name text;

-- 2. Performance Index for Foals query by account
create index if not exists idx_foals_account_id on public.foals(account_id);

-- 3. Row Level Security Policies for Foals Table (if not already enabled)
alter table if exists public.foals enable row level security;

drop policy if exists "foals_select_own" on public.foals;
create policy "foals_select_own" on public.foals 
  for select using (account_id = auth.uid());

drop policy if exists "foals_insert_own" on public.foals;
create policy "foals_insert_own" on public.foals 
  for insert with check (account_id = auth.uid());

drop policy if exists "foals_update_own" on public.foals;
create policy "foals_update_own" on public.foals 
  for update using (account_id = auth.uid());

drop policy if exists "foals_delete_own" on public.foals;
create policy "foals_delete_own" on public.foals 
  for delete using (account_id = auth.uid());
