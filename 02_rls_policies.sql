-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Row-Level Security (RLS)
-- File 2 of 2: RLS Enablement & Access Control Policies
-- Target: Supabase / PostgreSQL 15+
-- Run this file AFTER 01_schema.sql
-- =====================================================================
-- Principle: A user can only access rows belonging to their own account.
-- 1. Direct Ownership (account_id = auth.uid()):
--    - profiles, animals, breeding_records, pregnancy_records, foals, calendar_reminders
-- 2. Relational Ownership (via parent record join):
--    - markings (via animals or foals)
--    - advanced_pregnancy_info (via pregnancy_records)
--    - preventative_care (via animals or foals)
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. PROFILES
-- ---------------------------------------------------------------------
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select using (id = auth.uid());

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert with check (id = auth.uid());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (id = auth.uid());

drop policy if exists "profiles_delete_own" on public.profiles;
create policy "profiles_delete_own" on public.profiles
  for delete using (id = auth.uid());


-- ---------------------------------------------------------------------
-- 1. ANIMALS
-- ---------------------------------------------------------------------
alter table public.animals enable row level security;

drop policy if exists "animals_select_own" on public.animals;
create policy "animals_select_own" on public.animals
  for select using (account_id = auth.uid());

drop policy if exists "animals_insert_own" on public.animals;
create policy "animals_insert_own" on public.animals
  for insert with check (account_id = auth.uid());

drop policy if exists "animals_update_own" on public.animals;
create policy "animals_update_own" on public.animals
  for update using (account_id = auth.uid());

drop policy if exists "animals_delete_own" on public.animals;
create policy "animals_delete_own" on public.animals
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- 2. MARKINGS
-- ---------------------------------------------------------------------
alter table public.markings enable row level security;

drop policy if exists "markings_select_own" on public.markings;
create policy "markings_select_own" on public.markings
  for select using (
    (owner_type = 'animal' and exists (
      select 1 from public.animals a where a.id = markings.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from public.foals f where f.id = markings.owner_id and f.account_id = auth.uid()
    ))
  );

drop policy if exists "markings_insert_own" on public.markings;
create policy "markings_insert_own" on public.markings
  for insert with check (
    (owner_type = 'animal' and exists (
      select 1 from public.animals a where a.id = markings.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from public.foals f where f.id = markings.owner_id and f.account_id = auth.uid()
    ))
  );

drop policy if exists "markings_update_own" on public.markings;
create policy "markings_update_own" on public.markings
  for update using (
    (owner_type = 'animal' and exists (
      select 1 from public.animals a where a.id = markings.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from public.foals f where f.id = markings.owner_id and f.account_id = auth.uid()
    ))
  );

drop policy if exists "markings_delete_own" on public.markings;
create policy "markings_delete_own" on public.markings
  for delete using (
    (owner_type = 'animal' and exists (
      select 1 from public.animals a where a.id = markings.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from public.foals f where f.id = markings.owner_id and f.account_id = auth.uid()
    ))
  );


-- ---------------------------------------------------------------------
-- 3. BREEDING RECORDS
-- ---------------------------------------------------------------------
alter table public.breeding_records enable row level security;

drop policy if exists "breeding_select_own" on public.breeding_records;
create policy "breeding_select_own" on public.breeding_records
  for select using (account_id = auth.uid());

drop policy if exists "breeding_insert_own" on public.breeding_records;
create policy "breeding_insert_own" on public.breeding_records
  for insert with check (account_id = auth.uid());

drop policy if exists "breeding_update_own" on public.breeding_records;
create policy "breeding_update_own" on public.breeding_records
  for update using (account_id = auth.uid());

drop policy if exists "breeding_delete_own" on public.breeding_records;
create policy "breeding_delete_own" on public.breeding_records
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- 4. PREGNANCY RECORDS
-- ---------------------------------------------------------------------
alter table public.pregnancy_records enable row level security;

drop policy if exists "pregnancy_select_own" on public.pregnancy_records;
create policy "pregnancy_select_own" on public.pregnancy_records
  for select using (account_id = auth.uid());

drop policy if exists "pregnancy_insert_own" on public.pregnancy_records;
create policy "pregnancy_insert_own" on public.pregnancy_records
  for insert with check (account_id = auth.uid());

drop policy if exists "pregnancy_update_own" on public.pregnancy_records;
create policy "pregnancy_update_own" on public.pregnancy_records
  for update using (account_id = auth.uid());

drop policy if exists "pregnancy_delete_own" on public.pregnancy_records;
create policy "pregnancy_delete_own" on public.pregnancy_records
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- 5. ADVANCED PREGNANCY INFO
-- ---------------------------------------------------------------------
alter table public.advanced_pregnancy_info enable row level security;

drop policy if exists "adv_preg_select_own" on public.advanced_pregnancy_info;
create policy "adv_preg_select_own" on public.advanced_pregnancy_info
  for select using (
    exists (
      select 1 from public.pregnancy_records p
      where p.id = advanced_pregnancy_info.pregnancy_record_id
      and p.account_id = auth.uid()
    )
  );

drop policy if exists "adv_preg_insert_own" on public.advanced_pregnancy_info;
create policy "adv_preg_insert_own" on public.advanced_pregnancy_info
  for insert with check (
    exists (
      select 1 from public.pregnancy_records p
      where p.id = advanced_pregnancy_info.pregnancy_record_id
      and p.account_id = auth.uid()
    )
  );

drop policy if exists "adv_preg_update_own" on public.advanced_pregnancy_info;
create policy "adv_preg_update_own" on public.advanced_pregnancy_info
  for update using (
    exists (
      select 1 from public.pregnancy_records p
      where p.id = advanced_pregnancy_info.pregnancy_record_id
      and p.account_id = auth.uid()
    )
  );

drop policy if exists "adv_preg_delete_own" on public.advanced_pregnancy_info;
create policy "adv_preg_delete_own" on public.advanced_pregnancy_info
  for delete using (
    exists (
      select 1 from public.pregnancy_records p
      where p.id = advanced_pregnancy_info.pregnancy_record_id
      and p.account_id = auth.uid()
    )
  );


-- ---------------------------------------------------------------------
-- 6. PREVENTATIVE CARE
-- ---------------------------------------------------------------------
alter table public.preventative_care enable row level security;

drop policy if exists "prevcare_select_own" on public.preventative_care;
create policy "prevcare_select_own" on public.preventative_care
  for select using (
    (owner_type = 'animal' and exists (
      select 1 from public.animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from public.foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()
    ))
  );

drop policy if exists "prevcare_insert_own" on public.preventative_care;
create policy "prevcare_insert_own" on public.preventative_care
  for insert with check (
    (owner_type = 'animal' and exists (
      select 1 from public.animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from public.foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()
    ))
  );

drop policy if exists "prevcare_update_own" on public.preventative_care;
create policy "prevcare_update_own" on public.preventative_care
  for update using (
    (owner_type = 'animal' and exists (
      select 1 from public.animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from public.foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()
    ))
  );

drop policy if exists "prevcare_delete_own" on public.preventative_care;
create policy "prevcare_delete_own" on public.preventative_care
  for delete using (
    (owner_type = 'animal' and exists (
      select 1 from public.animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from public.foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()
    ))
  );


-- ---------------------------------------------------------------------
-- 7. FOALS
-- ---------------------------------------------------------------------
alter table public.foals enable row level security;

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


-- ---------------------------------------------------------------------
-- 8. CALENDAR REMINDERS
-- ---------------------------------------------------------------------
alter table public.calendar_reminders enable row level security;

drop policy if exists "reminders_select_own" on public.calendar_reminders;
create policy "reminders_select_own" on public.calendar_reminders
  for select using (account_id = auth.uid());

drop policy if exists "reminders_insert_own" on public.calendar_reminders;
create policy "reminders_insert_own" on public.calendar_reminders
  for insert with check (account_id = auth.uid());

drop policy if exists "reminders_update_own" on public.calendar_reminders;
create policy "reminders_update_own" on public.calendar_reminders
  for update using (account_id = auth.uid());

drop policy if exists "reminders_delete_own" on public.calendar_reminders;
create policy "reminders_delete_own" on public.calendar_reminders
  for delete using (account_id = auth.uid());

-- =====================================================================
-- End of 02_rls_policies.sql
-- =====================================================================
