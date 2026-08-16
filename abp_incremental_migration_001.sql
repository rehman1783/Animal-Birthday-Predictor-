-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Incremental Migration 001
-- File: abp_incremental_migration_001.sql
-- Scope: Contacts Directory, Foal Ownership Fields, Dog/Puppy Module,
--        Puppy Weight Tracking, and Dog Preventative Care (Given + Due pairs)
-- Run this file in Supabase SQL Editor.
-- NOTE: 01_schema.sql and 02_rls_policies.sql have already been executed.
--       Do NOT rerun the original SQL files.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. CONTACTS DIRECTORY TABLE
-- ---------------------------------------------------------------------
-- Stores contacts (Vet, Farrier, Dentist, Buyer/Owner, General) per account.
-- Reusable across pregnancy records, preventative care, foals, and puppies.

create table if not exists public.contacts (
  id                  uuid primary key default gen_random_uuid(),
  account_id          uuid not null references auth.users(id) on delete cascade,
  name                text not null,
  phone               text,
  email               text,
  role                text not null default 'general' check (role in ('vet', 'farrier', 'dentist', 'owner', 'buyer', 'general')),
  clinic_or_business  text,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_contacts_account on public.contacts(account_id);
create index if not exists idx_contacts_role on public.contacts(account_id, role);

drop trigger if exists trg_contacts_updated_at on public.contacts;
create trigger trg_contacts_updated_at
  before update on public.contacts
  for each row execute function public.set_updated_at();

-- RLS for contacts
alter table public.contacts enable row level security;

drop policy if exists "contacts_select_own" on public.contacts;
create policy "contacts_select_own" on public.contacts
  for select using (account_id = auth.uid());

drop policy if exists "contacts_insert_own" on public.contacts;
create policy "contacts_insert_own" on public.contacts
  for insert with check (account_id = auth.uid());

drop policy if exists "contacts_update_own" on public.contacts;
create policy "contacts_update_own" on public.contacts
  for update using (account_id = auth.uid());

drop policy if exists "contacts_delete_own" on public.contacts;
create policy "contacts_delete_own" on public.contacts
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- 2. FOALS TABLE EXTENSIONS (Buyer / New Owner Information)
-- ---------------------------------------------------------------------
-- Adds Sold/Transferred new owner fields without breaking existing columns.

alter table public.foals
  add column if not exists buyer_name text;


-- ---------------------------------------------------------------------
-- 3. PUPPIES TABLE (Dog / Canine Offspring & Litter Registry)
-- ---------------------------------------------------------------------
-- Dedicated puppy entity supporting identification, collar colors, birth order,
-- weights, and going-home information.

create table if not exists public.puppies (
  id                    uuid primary key default gen_random_uuid(),
  account_id            uuid not null references auth.users(id) on delete cascade,
  dam_animal_id         uuid references public.animals(id) on delete set null,
  sire_name             text,
  sire_animal_id        uuid references public.animals(id) on delete set null,

  puppy_name            text,
  collar_tag_colour     text,
  sex                   text check (sex in ('male', 'female')),
  colour                text,
  birth_order           integer,
  date_of_birth         date,
  time_of_birth         text,
  birth_weight          text,
  current_weight        text,
  microchip_no          text,
  dna                   text,

  status                text check (status in ('available', 'reserved', 'sold', 'keep', 'transferred')),
  date_going_home       date,
  new_owner_name        text,
  new_owner_phone       text,
  new_owner_address     text,
  general_notes         text,
  photo_url             text,

  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists idx_puppies_account on public.puppies(account_id);
create index if not exists idx_puppies_dam on public.puppies(dam_animal_id);

drop trigger if exists trg_puppies_updated_at on public.puppies;
create trigger trg_puppies_updated_at
  before update on public.puppies
  for each row execute function public.set_updated_at();

-- RLS for puppies
alter table public.puppies enable row level security;

drop policy if exists "puppies_select_own" on public.puppies;
create policy "puppies_select_own" on public.puppies
  for select using (account_id = auth.uid());

drop policy if exists "puppies_insert_own" on public.puppies;
create policy "puppies_insert_own" on public.puppies
  for insert with check (account_id = auth.uid());

drop policy if exists "puppies_update_own" on public.puppies;
create policy "puppies_update_own" on public.puppies
  for update using (account_id = auth.uid());

drop policy if exists "puppies_delete_own" on public.puppies;
create policy "puppies_delete_own" on public.puppies
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- 4. PUPPY WEIGHTS TRACKER TABLE
-- ---------------------------------------------------------------------
-- Ongoing weight records with date, age in days, weight, and notes.

create table if not exists public.puppy_weights (
  id                  uuid primary key default gen_random_uuid(),
  puppy_id            uuid not null references public.puppies(id) on delete cascade,
  account_id          uuid not null references auth.users(id) on delete cascade,
  weight_date         date not null default current_date,
  age_in_days         integer,
  weight              text not null,
  notes               text,
  created_at          timestamptz not null default now()
);

create index if not exists idx_puppy_weights_puppy on public.puppy_weights(puppy_id);
create index if not exists idx_puppy_weights_account on public.puppy_weights(account_id);

-- RLS for puppy_weights
alter table public.puppy_weights enable row level security;

drop policy if exists "puppy_weights_select_own" on public.puppy_weights;
create policy "puppy_weights_select_own" on public.puppy_weights
  for select using (account_id = auth.uid());

drop policy if exists "puppy_weights_insert_own" on public.puppy_weights;
create policy "puppy_weights_insert_own" on public.puppy_weights
  for insert with check (account_id = auth.uid());

drop policy if exists "puppy_weights_update_own" on public.puppy_weights;
create policy "puppy_weights_update_own" on public.puppy_weights
  for update using (account_id = auth.uid());

drop policy if exists "puppy_weights_delete_own" on public.puppy_weights;
create policy "puppy_weights_delete_own" on public.puppy_weights
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- 5. DOG PREVENTATIVE CARE TABLE (Date Given + Date Due Pairs)
-- ---------------------------------------------------------------------
-- Dedicated health treatment structure for dogs & puppies with Date Given + Date Due
-- pairs per item (worming, vaccination, vet checks, microchip).

create table if not exists public.dog_preventative_care (
  id                  uuid primary key default gen_random_uuid(),
  account_id          uuid not null references auth.users(id) on delete cascade,
  owner_type          text not null check (owner_type in ('animal', 'puppy')),
  owner_id            uuid not null,
  treatment_type      text not null check (treatment_type in ('worming', 'vaccination', 'vet_check', 'microchip', 'other')),
  title               text not null,
  date_given          date,
  date_due            date,
  is_completed        boolean not null default false,
  administered_by     text,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_dog_prevcare_owner on public.dog_preventative_care(owner_type, owner_id);
create index if not exists idx_dog_prevcare_account on public.dog_preventative_care(account_id);

drop trigger if exists trg_dog_prevcare_updated_at on public.dog_preventative_care;
create trigger trg_dog_prevcare_updated_at
  before update on public.dog_preventative_care
  for each row execute function public.set_updated_at();

-- RLS for dog_preventative_care
alter table public.dog_preventative_care enable row level security;

drop policy if exists "dog_prevcare_select_own" on public.dog_preventative_care;
create policy "dog_prevcare_select_own" on public.dog_preventative_care
  for select using (account_id = auth.uid());

drop policy if exists "dog_prevcare_insert_own" on public.dog_preventative_care;
create policy "dog_prevcare_insert_own" on public.dog_preventative_care
  for insert with check (account_id = auth.uid());

drop policy if exists "dog_prevcare_update_own" on public.dog_preventative_care;
create policy "dog_prevcare_update_own" on public.dog_preventative_care
  for update using (account_id = auth.uid());

drop policy if exists "dog_prevcare_delete_own" on public.dog_preventative_care;
create policy "dog_prevcare_delete_own" on public.dog_preventative_care
  for delete using (account_id = auth.uid());

-- =====================================================================
-- End of abp_incremental_migration_001.sql
-- =====================================================================
