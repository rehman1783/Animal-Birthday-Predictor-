-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Database Schema Sync & Migration 007
-- File: 07_complete_supabase_sync_and_fixes.sql
-- Scope: Syncs all database columns, check constraints, and RLS policies
--        to guarantee zero schema mismatches across Web, Android, iOS & Windows.
-- Instructions: Run this entire script in Supabase SQL Editor.
-- =====================================================================

-- 1. EXTENSIONS & FUNCTIONS
create extension if not exists "pgcrypto";

-- 2. ANIMALS TABLE EXTENSIONS
alter table if exists public.animals
  add column if not exists sex text,
  add column if not exists breed text,
  add column if not exists colour text,
  add column if not exists date_of_birth date,
  add column if not exists microchip_no text,
  add column if not exists dna text,
  add column if not exists brand text,
  add column if not exists owner_client_name text,
  add column if not exists owner_client_phone text,
  add column if not exists photo_url text;

-- Relax species check constraint to support ovine/sheep and extended species
alter table if exists public.animals drop constraint if exists animals_species_check;
alter table if exists public.animals add constraint animals_species_check check (species in ('horse', 'dog', 'cat', 'sheep', 'other'));

-- 3. BREEDING RECORDS TABLE EXTENSIONS
alter table if exists public.breeding_records
  add column if not exists is_embryo_transfer boolean not null default false,
  add column if not exists recipient_animal_id uuid references public.animals(id) on delete set null,
  add column if not exists dam_of_embryo text,
  add column if not exists stallion_of_embryo text,
  add column if not exists photo_url text;

-- Relax method check constraint to include 'et' explicitly alongside natural, chilled, frozen, icsi
alter table if exists public.breeding_records drop constraint if exists breeding_records_method_check;
alter table if exists public.breeding_records add constraint breeding_records_method_check check (method in ('natural', 'chilled', 'frozen', 'et', 'icsi'));

-- 4. PREGNANCY RECORDS TABLE EXTENSIONS
alter table if exists public.pregnancy_records
  add column if not exists twins_suspected boolean not null default false,
  add column if not exists twin_rescan_date date,
  add column if not exists scan_1_image_url text,
  add column if not exists scan_2_image_url text,
  add column if not exists scan_3_image_url text,
  add column if not exists vet_name text,
  add column if not exists vet_number text;

-- 5. FOALS TABLE EXTENSIONS (Buyer / New Owner Information)
alter table if exists public.foals
  add column if not exists buyer_name text,
  add column if not exists buyer_phone text,
  add column if not exists buyer_email text,
  add column if not exists buyer_address text,
  add column if not exists sale_date date,
  add column if not exists sale_price text,
  add column if not exists igg_value text,
  add column if not exists foal_microchip_no text,
  add column if not exists dna text,
  add column if not exists gelded boolean not null default false,
  add column if not exists gelded_date date,
  add column if not exists stud_book_association text,
  add column if not exists notes text,
  add column if not exists status text,
  add column if not exists photo_url text;

-- Relax foal status check constraint
alter table if exists public.foals drop constraint if exists foals_status_check;
alter table if exists public.foals add constraint foals_status_check check (status in ('available', 'reserved', 'sold', 'keep', 'transferred'));

-- 6. ENSURE ALL TABLES HAVE PROPER RLS ENABLED & ACCESSIBLE
alter table if exists public.animals enable row level security;
alter table if exists public.breeding_records enable row level security;
alter table if exists public.pregnancy_records enable row level security;
alter table if exists public.advanced_pregnancy_info enable row level security;
alter table if exists public.preventative_care enable row level security;
alter table if exists public.foals enable row level security;
alter table if exists public.markings enable row level security;
alter table if exists public.contacts enable row level security;
alter table if exists public.puppies enable row level security;
alter table if exists public.puppy_weights enable row level security;
alter table if exists public.dog_preventative_care enable row level security;

-- 7. REFRESH RLS POLICIES FOR DIRECT USER OWNERSHIP
drop policy if exists "breeding_select_own" on public.breeding_records;
create policy "breeding_select_own" on public.breeding_records for select using (account_id = auth.uid());
drop policy if exists "breeding_insert_own" on public.breeding_records;
create policy "breeding_insert_own" on public.breeding_records for insert with check (account_id = auth.uid());
drop policy if exists "breeding_update_own" on public.breeding_records;
create policy "breeding_update_own" on public.breeding_records for update using (account_id = auth.uid());
drop policy if exists "breeding_delete_own" on public.breeding_records;
create policy "breeding_delete_own" on public.breeding_records for delete using (account_id = auth.uid());

drop policy if exists "pregnancy_select_own" on public.pregnancy_records;
create policy "pregnancy_select_own" on public.pregnancy_records for select using (account_id = auth.uid());
drop policy if exists "pregnancy_insert_own" on public.pregnancy_records;
create policy "pregnancy_insert_own" on public.pregnancy_records for insert with check (account_id = auth.uid());
drop policy if exists "pregnancy_update_own" on public.pregnancy_records;
create policy "pregnancy_update_own" on public.pregnancy_records for update using (account_id = auth.uid());
drop policy if exists "pregnancy_delete_own" on public.pregnancy_records;
create policy "pregnancy_delete_own" on public.pregnancy_records for delete using (account_id = auth.uid());

-- Done
select 'ABP Database Schema Successfully Synced!' as status;
