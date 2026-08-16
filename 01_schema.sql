-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Database Schema
-- File 1 of 2: Tables, Constraints, Indexes, Triggers & Functions
-- Target: Supabase / PostgreSQL 15+
-- Scope: Horse module (Dog/Cat/Other species structurally supported
--        via the `species` column; additional species fields extensible)
-- Run this file FIRST, then 02_rls_policies.sql
-- =====================================================================

-- Enable pgcrypto extension for gen_random_uuid()
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- Reusable trigger function to automatically update `updated_at` timestamps
-- ---------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;


-- =====================================================================
-- 0. USER PROFILES & AUTHENTICATION INTEGRATION
-- =====================================================================
-- Stores public profile data linked directly to auth.users.
-- Automatically populated upon user registration via handle_new_user trigger.

create table if not exists public.profiles (
  id                  uuid primary key references auth.users(id) on delete cascade,
  email               text not null,
  full_name           text not null default '',
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_profiles_email on public.profiles (lower(email));

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Automatic Profile Creation Trigger on auth.users
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    lower(new.email),
    coalesce(new.raw_user_meta_data->>'full_name', '')
  )
  on conflict (id) do update
  set email = excluded.email,
      full_name = case when excluded.full_name <> '' then excluded.full_name else public.profiles.full_name end;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Helper Function: Check Email Exists (Security Definer)
create or replace function public.check_email_exists(email_to_check text)
returns boolean
language plpgsql
security definer
as $$
begin
  return exists (
    select 1 
    from auth.users 
    where lower(email) = lower(trim(email_to_check))
  );
end;
$$;

grant execute on function public.check_email_exists(text) to anon, authenticated;

-- Helper Function: Check Email Verified (Security Definer)
create or replace function public.check_email_verified(email_to_check text)
returns boolean
language plpgsql
security definer
as $$
begin
  return exists (
    select 1 
    from auth.users 
    where lower(email) = lower(trim(email_to_check))
      and email_confirmed_at is not null
  );
end;
$$;

grant execute on function public.check_email_verified(text) to anon, authenticated;


-- =====================================================================
-- 1. ANIMALS — Universal Animal Registry
-- =====================================================================
-- Single source of truth for every real animal registered by a user.
-- Reusable across all roles (donor mare, recipient mare, dam reference)
-- and species ('horse', 'dog', 'cat', 'other').

create table if not exists public.animals (
  id                  uuid primary key default gen_random_uuid(),
  account_id          uuid not null references auth.users(id) on delete cascade,
  species             text not null check (species in ('horse', 'dog', 'cat', 'other')),

  -- Core identity fields
  name                text not null,
  breed               text,
  colour              text,
  date_of_birth       date,
  microchip_no        text,
  dna                 text,

  -- Horse-specific identity
  brand               text,

  -- Owner / Client management
  owner_client_name   text,
  owner_client_phone  text,

  photo_url           text,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_animals_account on public.animals(account_id);
create index if not exists idx_animals_species on public.animals(account_id, species);

drop trigger if exists trg_animals_updated_at on public.animals;
create trigger trg_animals_updated_at
  before update on public.animals
  for each row execute function public.set_updated_at();


-- =====================================================================
-- 2. MARKINGS — Shared Physical Identifiers
-- =====================================================================
-- Polymorphic table storing Left, Right, Head View photos + notes.
-- Reused identically for an Animal (owner_type='animal') or Foal (owner_type='foal').

create table if not exists public.markings (
  id                    uuid primary key default gen_random_uuid(),
  owner_type            text not null check (owner_type in ('animal', 'foal')),
  owner_id              uuid not null,   -- references animals.id or foals.id
  left_side_image_url   text,
  right_side_image_url  text,
  head_view_image_url   text,
  head_view_notes       text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  constraint uq_markings_owner unique (owner_type, owner_id)
);

create index if not exists idx_markings_owner on public.markings(owner_type, owner_id);

drop trigger if exists trg_markings_updated_at on public.markings;
create trigger trg_markings_updated_at
  before update on public.markings
  for each row execute function public.set_updated_at();


-- =====================================================================
-- 3. BREEDING RECORDS
-- =====================================================================
-- Records a breeding event for a mare.
-- Supports all 4 breeding methods with optional Embryo Transfer to a recipient animal.

create table if not exists public.breeding_records (
  id                    uuid primary key default gen_random_uuid(),
  account_id            uuid not null references auth.users(id) on delete cascade,
  mare_animal_id        uuid not null references public.animals(id) on delete cascade,

  stallion_name         text,      -- free text: external stud or sire reference
  method                text not null check (method in ('natural', 'chilled', 'frozen', 'icsi')),
  cover_or_transfer_date date,

  is_embryo_transfer    boolean not null default false,
  recipient_animal_id   uuid references public.animals(id) on delete set null,
  dam_of_embryo         text,      -- genetic dam (relevant if embryo transfer)
  stallion_of_embryo    text,      -- genetic sire (relevant if embryo transfer)

  photo_url             text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  constraint chk_recipient_requires_transfer
    check (recipient_animal_id is null or is_embryo_transfer = true)
);

create index if not exists idx_breeding_account on public.breeding_records(account_id);
create index if not exists idx_breeding_mare on public.breeding_records(mare_animal_id);
create index if not exists idx_breeding_recipient on public.breeding_records(recipient_animal_id);

drop trigger if exists trg_breeding_updated_at on public.breeding_records;
create trigger trg_breeding_updated_at
  before update on public.breeding_records
  for each row execute function public.set_updated_at();


-- =====================================================================
-- 4. PREGNANCY RECORDS
-- =====================================================================
-- Tracks pregnancy against whichever animal is physically carrying the foal
-- (donor mare if no transfer, or recipient animal if transferred).
-- Scan due dates and foaling due date are computed once upon record creation.

create table if not exists public.pregnancy_records (
  id                  uuid primary key default gen_random_uuid(),
  account_id          uuid not null references auth.users(id) on delete cascade,
  breeding_record_id  uuid not null references public.breeding_records(id) on delete cascade,
  carrier_animal_id   uuid not null references public.animals(id) on delete cascade,

  scan_1_due_date     date,
  scan_1_confirmed    boolean not null default false,
  scan_1_image_url    text,

  scan_2_due_date     date,
  scan_2_confirmed    boolean not null default false,
  scan_2_image_url    text,

  scan_3_due_date     date,
  scan_3_confirmed    boolean not null default false,
  scan_3_image_url    text,

  foaling_due_date    date,

  vet_name            text,
  vet_number          text,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_pregnancy_account on public.pregnancy_records(account_id);
create index if not exists idx_pregnancy_carrier on public.pregnancy_records(carrier_animal_id);
create index if not exists idx_pregnancy_breeding on public.pregnancy_records(breeding_record_id);

drop trigger if exists trg_pregnancy_updated_at on public.pregnancy_records;
create trigger trg_pregnancy_updated_at
  before update on public.pregnancy_records
  for each row execute function public.set_updated_at();


-- =====================================================================
-- 5. ADVANCED PREGNANCY INFO
-- =====================================================================
-- Specialized vet procedures linked 1-to-1 with a pregnancy_record.

create table if not exists public.advanced_pregnancy_info (
  id                     uuid primary key default gen_random_uuid(),
  pregnancy_record_id    uuid not null unique references public.pregnancy_records(id) on delete cascade,

  caslick_date           date,
  caslick_done           boolean not null default false,

  fetal_sex_scan_date    date,
  fetal_sex_scan_done    boolean not null default false,

  ffs_result_date        date,
  ffs_result             text check (ffs_result in ('filly', 'colt')),
  ultrasound_image_url   text,

  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

create index if not exists idx_adv_preg_record on public.advanced_pregnancy_info(pregnancy_record_id);

drop trigger if exists trg_adv_preg_updated_at on public.advanced_pregnancy_info;
create trigger trg_adv_preg_updated_at
  before update on public.advanced_pregnancy_info
  for each row execute function public.set_updated_at();


-- =====================================================================
-- 6. PREVENTATIVE CARE — Combined Health Records
-- =====================================================================
-- Single combined health record (Wormer + 9 Vaccinations + Dental + Farrier)
-- Polymorphic: owner_type in ('animal', 'foal').

create table if not exists public.preventative_care (
  id                   uuid primary key default gen_random_uuid(),
  owner_type           text not null check (owner_type in ('animal', 'foal')),
  owner_id             uuid not null,   -- references animals.id or foals.id

  wormer_date          date, wormer_done boolean not null default false,
  tetanus_date         date, tetanus_done boolean not null default false,
  strangles_date       date, strangles_done boolean not null default false,
  eq_herpes_date       date, eq_herpes_done boolean not null default false,
  rotavirus_date       date, rotavirus_done boolean not null default false,
  hendra_date          date, hendra_done boolean not null default false,
  eq_influenza_date    date, eq_influenza_done boolean not null default false,
  eee_wee_wnv_date     date, eee_wee_wnv_done boolean not null default false,
  rabies_date          date, rabies_done boolean not null default false,

  dental_date          date, dental_done boolean not null default false,
  dentist_number       text,

  farrier_date         date, farrier_done boolean not null default false,
  farrier_number       text,

  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  constraint uq_prevcare_owner unique (owner_type, owner_id)
);

create index if not exists idx_prevcare_owner on public.preventative_care(owner_type, owner_id);

drop trigger if exists trg_prevcare_updated_at on public.preventative_care;
create trigger trg_prevcare_updated_at
  before update on public.preventative_care
  for each row execute function public.set_updated_at();


-- =====================================================================
-- 7. FOALS
-- =====================================================================
-- Offspring record linked to genetic dam (mare_animal_id) and optional recipient.

create table if not exists public.foals (
  id                        uuid primary key default gen_random_uuid(),
  account_id                uuid not null references auth.users(id) on delete cascade,
  mare_animal_id            uuid not null references public.animals(id) on delete cascade,
  recipient_animal_id       uuid references public.animals(id) on delete set null,

  foal_name                 text,
  date_of_birth             date,
  stallion                  text,
  breed                     text,
  sex                       text check (sex in ('filly', 'colt')),
  igg_value                 text,
  foal_microchip_no         text,
  dna                       text,
  gelded                    boolean not null default false,
  gelded_date               date,
  stud_book_association     text,
  notes                     text,
  status                    text check (status in ('sold', 'keep', 'transferred')),
  photo_url                 text,

  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now()
);

create index if not exists idx_foals_account on public.foals(account_id);
create index if not exists idx_foals_mare on public.foals(mare_animal_id);
create index if not exists idx_foals_recipient on public.foals(recipient_animal_id);

drop trigger if exists trg_foals_updated_at on public.foals;
create trigger trg_foals_updated_at
  before update on public.foals
  for each row execute function public.set_updated_at();


-- =====================================================================
-- 8. CALENDAR REMINDERS
-- =====================================================================
-- Generic reminder table linking date fields across the app to device
-- calendar sync and local notification engines.

create table if not exists public.calendar_reminders (
  id                          uuid primary key default gen_random_uuid(),
  account_id                  uuid not null references auth.users(id) on delete cascade,
  related_table               text not null,   -- e.g. 'pregnancy_records', 'preventative_care'
  related_id                  uuid not null,
  field_name                  text not null,   -- e.g. 'scan_1_due_date', 'tetanus_date'
  reminder_date               date not null,
  label                       text,
  synced_to_device_calendar   boolean not null default false,
  created_at                  timestamptz not null default now(),
  updated_at                  timestamptz not null default now()
);

create index if not exists idx_reminders_account on public.calendar_reminders(account_id);
create index if not exists idx_reminders_related on public.calendar_reminders(related_table, related_id);

drop trigger if exists trg_reminders_updated_at on public.calendar_reminders;
create trigger trg_reminders_updated_at
  before update on public.calendar_reminders
  for each row execute function public.set_updated_at();

-- =====================================================================
-- End of 01_schema.sql
-- =====================================================================
