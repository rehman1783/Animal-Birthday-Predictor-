-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Row-Level Security
-- File 2 of 2: RLS enablement + policies
-- Run this AFTER 01_schema.sql
-- =====================================================================
-- Principle: a user can only ever see/modify rows tied to their own
-- account_id, either directly (animals, breeding_records,
-- pregnancy_records, foals, calendar_reminders) or via a join back to
-- an owning row (markings, advanced_pregnancy_info, preventative_care —
-- none of these carry account_id directly, so ownership is resolved
-- through their owner/parent record).
-- =====================================================================

-- ---------------------------------------------------------------------
-- ANIMALS
-- ---------------------------------------------------------------------
alter table animals enable row level security;

create policy "animals_select_own" on animals
  for select using (account_id = auth.uid());
create policy "animals_insert_own" on animals
  for insert with check (account_id = auth.uid());
create policy "animals_update_own" on animals
  for update using (account_id = auth.uid());
create policy "animals_delete_own" on animals
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- MARKINGS (owner_type = 'animal' -> animals, owner_type = 'foal' -> foals)
-- ---------------------------------------------------------------------
alter table markings enable row level security;

create policy "markings_select_own" on markings
  for select using (
    (owner_type = 'animal' and exists (
      select 1 from animals a where a.id = markings.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from foals f where f.id = markings.owner_id and f.account_id = auth.uid()
    ))
  );

create policy "markings_insert_own" on markings
  for insert with check (
    (owner_type = 'animal' and exists (
      select 1 from animals a where a.id = markings.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from foals f where f.id = markings.owner_id and f.account_id = auth.uid()
    ))
  );

create policy "markings_update_own" on markings
  for update using (
    (owner_type = 'animal' and exists (
      select 1 from animals a where a.id = markings.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from foals f where f.id = markings.owner_id and f.account_id = auth.uid()
    ))
  );

create policy "markings_delete_own" on markings
  for delete using (
    (owner_type = 'animal' and exists (
      select 1 from animals a where a.id = markings.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from foals f where f.id = markings.owner_id and f.account_id = auth.uid()
    ))
  );


-- ---------------------------------------------------------------------
-- BREEDING RECORDS
-- ---------------------------------------------------------------------
alter table breeding_records enable row level security;

create policy "breeding_select_own" on breeding_records
  for select using (account_id = auth.uid());
create policy "breeding_insert_own" on breeding_records
  for insert with check (account_id = auth.uid());
create policy "breeding_update_own" on breeding_records
  for update using (account_id = auth.uid());
create policy "breeding_delete_own" on breeding_records
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- PREGNANCY RECORDS
-- ---------------------------------------------------------------------
alter table pregnancy_records enable row level security;

create policy "pregnancy_select_own" on pregnancy_records
  for select using (account_id = auth.uid());
create policy "pregnancy_insert_own" on pregnancy_records
  for insert with check (account_id = auth.uid());
create policy "pregnancy_update_own" on pregnancy_records
  for update using (account_id = auth.uid());
create policy "pregnancy_delete_own" on pregnancy_records
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- ADVANCED PREGNANCY INFO (ownership via pregnancy_records)
-- ---------------------------------------------------------------------
alter table advanced_pregnancy_info enable row level security;

create policy "adv_preg_select_own" on advanced_pregnancy_info
  for select using (
    exists (
      select 1 from pregnancy_records p
      where p.id = advanced_pregnancy_info.pregnancy_record_id
      and p.account_id = auth.uid()
    )
  );

create policy "adv_preg_insert_own" on advanced_pregnancy_info
  for insert with check (
    exists (
      select 1 from pregnancy_records p
      where p.id = advanced_pregnancy_info.pregnancy_record_id
      and p.account_id = auth.uid()
    )
  );

create policy "adv_preg_update_own" on advanced_pregnancy_info
  for update using (
    exists (
      select 1 from pregnancy_records p
      where p.id = advanced_pregnancy_info.pregnancy_record_id
      and p.account_id = auth.uid()
    )
  );

create policy "adv_preg_delete_own" on advanced_pregnancy_info
  for delete using (
    exists (
      select 1 from pregnancy_records p
      where p.id = advanced_pregnancy_info.pregnancy_record_id
      and p.account_id = auth.uid()
    )
  );


-- ---------------------------------------------------------------------
-- PREVENTATIVE CARE (owner_type = 'animal' -> animals, owner_type = 'foal' -> foals)
-- ---------------------------------------------------------------------
alter table preventative_care enable row level security;

create policy "prevcare_select_own" on preventative_care
  for select using (
    (owner_type = 'animal' and exists (
      select 1 from animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()
    ))
  );

create policy "prevcare_insert_own" on preventative_care
  for insert with check (
    (owner_type = 'animal' and exists (
      select 1 from animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()
    ))
  );

create policy "prevcare_update_own" on preventative_care
  for update using (
    (owner_type = 'animal' and exists (
      select 1 from animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()
    ))
  );

create policy "prevcare_delete_own" on preventative_care
  for delete using (
    (owner_type = 'animal' and exists (
      select 1 from animals a where a.id = preventative_care.owner_id and a.account_id = auth.uid()
    ))
    or
    (owner_type = 'foal' and exists (
      select 1 from foals f where f.id = preventative_care.owner_id and f.account_id = auth.uid()
    ))
  );


-- ---------------------------------------------------------------------
-- FOALS
-- ---------------------------------------------------------------------
alter table foals enable row level security;

create policy "foals_select_own" on foals
  for select using (account_id = auth.uid());
create policy "foals_insert_own" on foals
  for insert with check (account_id = auth.uid());
create policy "foals_update_own" on foals
  for update using (account_id = auth.uid());
create policy "foals_delete_own" on foals
  for delete using (account_id = auth.uid());


-- ---------------------------------------------------------------------
-- CALENDAR REMINDERS
-- ---------------------------------------------------------------------
alter table calendar_reminders enable row level security;

create policy "reminders_select_own" on calendar_reminders
  for select using (account_id = auth.uid());
create policy "reminders_insert_own" on calendar_reminders
  for insert with check (account_id = auth.uid());
create policy "reminders_update_own" on calendar_reminders
  for update using (account_id = auth.uid());
create policy "reminders_delete_own" on calendar_reminders
  for delete using (account_id = auth.uid());

-- =====================================================================
-- End of RLS policies.
-- =====================================================================
