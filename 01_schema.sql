-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Database Schema
-- File 1 of 2: Tables, Constraints, Indexes
-- Target: Supabase / PostgreSQL 15+
-- Scope: Horse module (Dog/Cat/Other species are structurally supported
--        via the `species` column but their extra fields are not yet
--        defined — see documentation Section 5).
-- Run this file FIRST, then 02_rls_policies.sql
-- =====================================================================

create extension if not exists "pgcrypto";  -- for gen_random_uuid()

-- ---------------------------------------------------------------------
-- Reusable trigger function to keep updated_at current on every UPDATE
-- ---------------------------------------------------------------------
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;


-- =====================================================================
-- 1. ANIMALS — the universal animal registry
-- =====================================================================
-- Every animal a user registers lives here first, regardless of species
-- or how it's later used (as a mare, a recipient, a sire reference, etc).
-- This is what powers the "select an existing animal" picker across the
-- whole app instead of re-entering the same animal's details every time.

create table if not exists animals (
  id                  uuid primary key default gen_random_uuid(),
  account_id          uuid not null references auth.users(id) on delete cascade,
  species             text not null check (species in ('horse', 'dog', 'cat', 'other')),

  -- Core identity fields (shared across all species — matches the
  -- "Essential" certificate field set)
  name                text not null,
  breed               text,
  colour              text,
  date_of_birth       date,
  microchip_no        text,
  dna                 text,

  -- Horse-specific (nullable so other species don't need them)
  brand               text,

  -- Owner/client — the stud may manage animals belonging to someone else
  owner_client_name   text,
  owner_client_phone  text,

  photo_url           text,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_animals_account on animals(account_id);
create index if not exists idx_animals_species on animals(account_id, species);

drop trigger if exists trg_animals_updated_at on animals;
create trigger trg_animals_updated_at
  before update on animals
  for each row execute function set_updated_at();


-- =====================================================================
-- 2. MARKINGS — shared component (Animal or Foal)
-- =====================================================================
-- One record per owner. Reused identically from the Animal (Mare/
-- Recipient) detail screen and the Foal detail screen.

create table if not exists markings (
  id                    uuid primary key default gen_random_uuid(),
  owner_type            text not null check (owner_type in ('animal', 'foal')),
  owner_id              uuid not null,   -- references animals.id or foals.id depending on owner_type
  left_side_image_url   text,
  right_side_image_url  text,
  head_view_image_url   text,
  head_view_notes       text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (owner_type, owner_id)
);

drop trigger if exists trg_markings_updated_at on markings;
create trigger trg_markings_updated_at
  before update on markings
  for each row execute function set_updated_at();


-- =====================================================================
-- 3. BREEDING RECORDS
-- =====================================================================
-- One breeding event for a mare (an animal with species='horse').
-- If the resulting embryo is transferred, recipient_animal_id points to
-- another `animals` row (also species='horse') that carries the foal
-- instead of the donor mare. DAM/Stallion of Embryo describe the
-- embryo's genetic parents — only relevant, and only shown in the UI,
-- when a transfer is involved (they can differ from the donor mare
-- herself, e.g. a purchased/flushed embryo).

create table if not exists breeding_records (
  id                    uuid primary key default gen_random_uuid(),
  account_id            uuid not null references auth.users(id) on delete cascade,
  mare_animal_id        uuid not null references animals(id) on delete cascade,

  stallion_name         text,      -- free text: usually an external stallion, not owned by this account
  method                text not null check (method in ('natural', 'chilled', 'frozen', 'icsi')),
  cover_or_transfer_date date,

  is_embryo_transfer    boolean not null default false,
  recipient_animal_id   uuid references animals(id),         -- set only if is_embryo_transfer = true
  dam_of_embryo         text,                                  -- only relevant if is_embryo_transfer = true
  stallion_of_embryo    text,                                  -- only relevant if is_embryo_transfer = true

  photo_url             text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  constraint chk_recipient_requires_transfer
    check (recipient_animal_id is null or is_embryo_transfer = true)
);

create index if not exists idx_breeding_mare on breeding_records(mare_animal_id);
create index if not exists idx_breeding_recipient on breeding_records(recipient_animal_id);

drop trigger if exists trg_breeding_updated_at on breeding_records;
create trigger trg_breeding_updated_at
  before update on breeding_records
  for each row execute function set_updated_at();


-- =====================================================================
-- 4. PREGNANCY RECORDS
-- =====================================================================
-- carrier_animal_id is whichever animal is physically carrying the
-- foal — the donor mare (mare_animal_id) if is_embryo_transfer = false,
-- or the recipient (recipient_animal_id) if true. Scan due dates and
-- the foaling due date are computed once (see documentation Section 4)
-- and stored here, not recalculated on every read.
--
-- "Pregnancy Details" and "Pregnancy Scans" (two separate screens in
-- the app) both read/write this same table — they are two views onto
-- one pregnancy record, not two separate data models.

create table if not exists pregnancy_records (
  id                  uuid primary key default gen_random_uuid(),
  account_id          uuid not null references auth.users(id) on delete cascade,
  breeding_record_id  uuid not null references breeding_records(id) on delete cascade,
  carrier_animal_id   uuid not null references animals(id) on delete cascade,

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
  vet_number           text,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_pregnancy_carrier on pregnancy_records(carrier_animal_id);
create index if not exists idx_pregnancy_breeding on pregnancy_records(breeding_record_id);

drop trigger if exists trg_pregnancy_updated_at on pregnancy_records;
create trigger trg_pregnancy_updated_at
  before update on pregnancy_records
  for each row execute function set_updated_at();


-- =====================================================================
-- 5. ADVANCED PREGNANCY INFO
-- =====================================================================

create table if not exists advanced_pregnancy_info (
  id                     uuid primary key default gen_random_uuid(),
  pregnancy_record_id    uuid not null unique references pregnancy_records(id) on delete cascade,

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

drop trigger if exists trg_adv_preg_updated_at on advanced_pregnancy_info;
create trigger trg_adv_preg_updated_at
  before update on advanced_pregnancy_info
  for each row execute function set_updated_at();


-- =====================================================================
-- 6. PREVENTATIVE CARE — one combined record per animal or foal
-- =====================================================================
-- Confirmed layout: a single scrollable screen (Wormer, all
-- vaccinations, Dental, Farrier together) — one row per owner, not
-- split across multiple tables/screens.
-- NOTE: Horse uses a single date+done pair per item. If/when Dog is
-- built, its Preventative Care needs a "date given" + "date due" pair
-- instead — do not reuse this table as-is for Dog; extend or create a
-- parallel table at that time (see documentation Section 5).

create table if not exists preventative_care (
  id                   uuid primary key default gen_random_uuid(),
  owner_type           text not null check (owner_type in ('animal', 'foal')),
  owner_id             uuid not null,   -- references animals.id or foals.id depending on owner_type

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
  unique (owner_type, owner_id)
);

drop trigger if exists trg_prevcare_updated_at on preventative_care;
create trigger trg_prevcare_updated_at
  before update on preventative_care
  for each row execute function set_updated_at();


-- =====================================================================
-- 7. FOALS
-- =====================================================================

create table if not exists foals (
  id                        uuid primary key default gen_random_uuid(),
  account_id                uuid not null references auth.users(id) on delete cascade,
  mare_animal_id             uuid not null references animals(id) on delete cascade,
  recipient_animal_id        uuid references animals(id),   -- set only if this foal came via embryo transfer

  foal_name                 text,
  date_of_birth              date,
  stallion                  text,
  breed                     text,
  sex                       text check (sex in ('filly', 'colt')),
  igg_value                 text,
  foal_microchip_no          text,
  dna                       text,
  gelded                    boolean not null default false,
  gelded_date                date,
  stud_book_association      text,
  notes                     text,
  status                    text check (status in ('sold', 'keep', 'transferred')),
  photo_url                  text,

  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now()
);

create index if not exists idx_foals_mare on foals(mare_animal_id);
create index if not exists idx_foals_recipient on foals(recipient_animal_id);

drop trigger if exists trg_foals_updated_at on foals;
create trigger trg_foals_updated_at
  before update on foals
  for each row execute function set_updated_at();


-- =====================================================================
-- 8. CALENDAR REMINDERS — generic, links any date field above to a
--    synced device-calendar event / local notification
-- =====================================================================

create table if not exists calendar_reminders (
  id                          uuid primary key default gen_random_uuid(),
  account_id                  uuid not null references auth.users(id) on delete cascade,
  related_table               text not null,   -- e.g. 'pregnancy_records', 'preventative_care'
  related_id                  uuid not null,
  field_name                  text not null,   -- e.g. 'scan_1_due_date', 'tetanus_date'
  reminder_date                date not null,
  label                       text,
  synced_to_device_calendar    boolean not null default false,
  created_at                  timestamptz not null default now()
);

create index if not exists idx_reminders_account on calendar_reminders(account_id);
create index if not exists idx_reminders_related on calendar_reminders(related_table, related_id);


-- =====================================================================
-- Notes for the AI coding agent:
-- - No table for "Certificate" — it is a generated/rendered document
--   (one universal template, species/terminology swapped at render
--   time), assembled from animals + foals + preventative_care at
--   request time. Nothing to store beyond what's already above.
-- - No table for "Congratulations" screen — it reads
--   pregnancy_records.foaling_due_date directly; it has no fields of
--   its own to persist.
-- =====================================================================
