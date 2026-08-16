-- ====================================================================
-- ABP (Animal BirthDay Predictor) — Database Schema: Part B
-- Features: Animals Registry, Markings, Breeding, Pregnancy, Advanced Info,
--           Preventative Care, Foals & Calendar Reminders
-- Target: Supabase / PostgreSQL 15+
-- Prerequisite: supabase_schema.sql (Part A: Auth & Profiles)
-- ====================================================================

-- Enable pgcrypto extension for gen_random_uuid()
create extension if not exists "pgcrypto";

-- Reusable trigger function for updated_at timestamps
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;


-- ====================================================================
-- 1. ANIMALS — Universal Animal Registry
-- ====================================================================
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

  -- Horse-specific
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


-- ====================================================================
-- 2. MARKINGS — Shared Physical Identifiers
-- ====================================================================
create table if not exists public.markings (
  id                    uuid primary key default gen_random_uuid(),
  owner_type            text not null check (owner_type in ('animal', 'foal')),
  owner_id              uuid not null,
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


-- ====================================================================
-- 3. BREEDING RECORDS
-- ====================================================================
create table if not exists public.breeding_records (
  id                    uuid primary key default gen_random_uuid(),
  account_id            uuid not null references auth.users(id) on delete cascade,
  mare_animal_id        uuid not null references public.animals(id) on delete cascade,

  stallion_name         text,
  method                text not null check (method in ('natural', 'chilled', 'frozen', 'icsi')),
  cover_or_transfer_date date,

  is_embryo_transfer    boolean not null default false,
  recipient_animal_id   uuid references public.animals(id) on delete set null,
  dam_of_embryo         text,
  stallion_of_embryo    text,

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


-- ====================================================================
-- 4. PREGNANCY RECORDS
-- ====================================================================
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


-- ====================================================================
-- 5. ADVANCED PREGNANCY INFO
-- ====================================================================
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


-- ====================================================================
-- 6. PREVENTATIVE CARE
-- ====================================================================
create table if not exists public.preventative_care (
  id                   uuid primary key default gen_random_uuid(),
  owner_type           text not null check (owner_type in ('animal', 'foal')),
  owner_id             uuid not null,

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


-- ====================================================================
-- 7. FOALS
-- ====================================================================
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


-- ====================================================================
-- 8. CALENDAR REMINDERS
-- ====================================================================
create table if not exists public.calendar_reminders (
  id                          uuid primary key default gen_random_uuid(),
  account_id                  uuid not null references auth.users(id) on delete cascade,
  related_table               text not null,
  related_id                  uuid not null,
  field_name                  text not null,
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


-- ====================================================================
-- ROW-LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

-- Animals RLS
alter table public.animals enable row level security;
drop policy if exists "animals_select_own" on public.animals;
create policy "animals_select_own" on public.animals for select using (account_id = auth.uid());
drop policy if exists "animals_insert_own" on public.animals;
create policy "animals_insert_own" on public.animals for insert with check (account_id = auth.uid());
drop policy if exists "animals_update_own" on public.animals;
create policy "animals_update_own" on public.animals for update using (account_id = auth.uid());
drop policy if exists "animals_delete_own" on public.animals;
create policy "animals_delete_own" on public.animals for delete using (account_id = auth.uid());

-- Markings RLS
alter table public.markings enable row level security;
drop policy if exists "markings_select_own" on public.markings;
create policy "markings_select_own" on public.markings for select using (
  (owner_type = 'animal' and exists (select 1 from public.animals a where a.id = markings.owner_id and a.account_id = auth.uid()))
  or
  (owner_type = 'foal' and exists (select 1 from public.foals f where f.id = markings.owner_id and f.account_id = auth.uid()))
);
drop policy if exists "markings_insert_own" on public.markings;
create policy "markings_insert_own" on public.markings for insert with check (
  (owner_type = 'animal' and exists (select 1 from public.animals a where a.id = markings.owner_id and a.account_id = auth.uid()))
  or
  (owner_type = 'foal' and exists (select 1 from public.foals f where f.id = markings.owner_id and f.account_id = auth.uid()))
);
drop policy if exists "markings_update_own" on public.markings;
create policy "markings_update_own" on public.markings for update using (
  (owner_type = 'animal' and exists (select 1 from public.animals a where a.id = markings.owner_id and a.account_id = auth.uid()))
  or
  (owner_type = 'foal' and exists (select 1 from public.foals f where f.id = markings.owner_id and f.account_id = auth.uid()))
);
drop policy if exists "markings_delete_own" on public.markings;
create policy "markings_delete_own" on public.markings for delete using (
  (owner_type = 'animal' and exists (select 1 from public.animals a where a.id = markings.owner_id and a.account_id = auth.uid()))
  or
  (owner_type = 'foal' and exists (select 1 from public.foals f where f.id = markings.owner_id and f.account_id = auth.uid()))
);

-- Breeding Records RLS
alter table public.breeding_records enable row level security;
drop policy if exists "breeding_select_own" on public.breeding_records;
create policy "breeding_select_own" on public.breeding_records for select using (account_id = auth.uid());
drop policy if exists "breeding_insert_own" on public.breeding_records;
create policy "breeding_insert_own" on public.breeding_records for insert with check (account_id = auth.uid());
drop policy if exists "breeding_update_own" on public.breeding_records;
create policy "breeding_update_own" on public.breeding_records for update using (account_id = auth.uid());
drop policy if exists "breeding_delete_own" on public.breeding_records;
create policy "breeding_delete_own" on public.breeding_records for delete using (account_id = auth.uid());

-- Pregnancy Records RLS
alter table public.pregnancy_records enable row level security;
drop policy if exists "pregnancy_select_own" on public.pregnancy_records;
create policy "pregnancy_select_own" on public.pregnancy_records for select using (account_id = auth.uid());
drop policy if exists "pregnancy_insert_own" on public.pregnancy_records;
create policy "pregnancy_insert_own" on public.pregnancy_records for insert with check (account_id = auth.uid());
drop policy if exists "pregnancy_update_own" on public.pregnancy_records;
create policy "pregnancy_update_own" on public.pregnancy_records for update using (account_id = auth.uid());
drop policy if exists "pregnancy_delete_own" on public.pregnancy_records;
create policy "pregnancy_delete_own" on public.pregnancy_records for delete using (account_id = auth.uid());

-- Advanced Pregnancy Info RLS
alter table public.advanced_pregnancy_info enable row level security;
drop policy if exists "adv_preg_select_own" on public.advanced_pregnancy_info;
create policy "adv_preg_select_own" on public.advanced_pregnancy_info for select using (
  exists (select 1 from public.pregnancy_records p where p.id = advanced_pregnancy_info.pregnancy_record_id and p.account_id = auth.uid())
);
drop policy if exists "adv_preg_insert_own" on public.advanced_pregnancy_info;
create policy "adv_preg_insert_own" on public.advanced_pregnancy_info for insert with check (
  exists (select 1 from public.pregnancy_records p where p.id = advanced_pregnancy_info.pregnancy_record_id and p.account_id = auth.uid())
);
drop policy if exists "adv_preg_update_own" on public.advanced_pregnancy_info;
create policy "adv_preg_update_own" on public.advanced_pregnancy_info for update using (
  exists (select 1 from public.pregnancy_records p where p.id = advanced_pregnancy_info.pregnancy_record_id and p.account_id = auth.uid())
);
drop policy if exists "adv_preg_delete_own" on public.advanced_pregnancy_info;
create policy "adv_preg_delete_own" on public.advanced_pregnancy_info for delete using (
  exists (select 1 from public.pregnancy_records p where p.id = advanced_pregnancy_info.pregnancy_record_id and p.account_id = auth.uid())
);

-- Preventative Care RLS
alter table public.preventative_care enable row level security;
drop policy if exists "prevcare_select_own" on public.preventative_care;
create policy "prevcare_select_own" on public.preventative_care for select using (
  (owner_type = 'animal' and exists (select 1 from public.animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()))
  or
  (owner_type = 'foal' and exists (select 1 from public.foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()))
);
drop policy if exists "prevcare_insert_own" on public.preventative_care;
create policy "prevcare_insert_own" on public.preventative_care for insert with check (
  (owner_type = 'animal' and exists (select 1 from public.animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()))
  or
  (owner_type = 'foal' and exists (select 1 from public.foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()))
);
drop policy if exists "prevcare_update_own" on public.preventative_care;
create policy "prevcare_update_own" on public.preventative_care for update using (
  (owner_type = 'animal' and exists (select 1 from public.animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()))
  or
  (owner_type = 'foal' and exists (select 1 from public.foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()))
);
drop policy if exists "prevcare_delete_own" on public.preventative_care;
create policy "prevcare_delete_own" on public.preventative_care for delete using (
  (owner_type = 'animal' and exists (select 1 from public.animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()))
  or
  (owner_type = 'foal' and exists (select 1 from public.foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()))
);

-- Foals RLS
alter table public.foals enable row level security;
drop policy if exists "foals_select_own" on public.foals;
create policy "foals_select_own" on public.foals for select using (account_id = auth.uid());
drop policy if exists "foals_insert_own" on public.foals;
create policy "foals_insert_own" on public.foals for insert with check (account_id = auth.uid());
drop policy if exists "foals_update_own" on public.foals;
create policy "foals_update_own" on public.foals for update using (account_id = auth.uid());
drop policy if exists "foals_delete_own" on public.foals;
create policy "foals_delete_own" on public.foals for delete using (account_id = auth.uid());

-- Calendar Reminders RLS
alter table public.calendar_reminders enable row level security;
drop policy if exists "reminders_select_own" on public.calendar_reminders;
create policy "reminders_select_own" on public.calendar_reminders for select using (account_id = auth.uid());
drop policy if exists "reminders_insert_own" on public.calendar_reminders;
create policy "reminders_insert_own" on public.calendar_reminders for insert with check (account_id = auth.uid());
drop policy if exists "reminders_update_own" on public.calendar_reminders;
create policy "reminders_update_own" on public.calendar_reminders for update using (account_id = auth.uid());
drop policy if exists "reminders_delete_own" on public.calendar_reminders;
create policy "reminders_delete_own" on public.calendar_reminders for delete using (account_id = auth.uid());

-- ====================================================================
-- End of supabase_schema_part_b.sql
-- ====================================================================
