-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Database Migration 05
-- Purpose: Strict User Data Isolation & Row-Level Security (RLS)
-- Target: Supabase / PostgreSQL 15+
-- Safe to execute: Ensures every user can ONLY see and manage their own records.
-- =====================================================================

-- 1. Enable RLS on all primary tables
ALTER TABLE IF EXISTS public.animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.foals ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.puppies ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.puppy_weights ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.dog_preventative_care ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.breeding_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.pregnancy_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.advanced_pregnancy_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.preventative_care ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.markings ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.profiles ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing permissive or conflicting policies
DROP POLICY IF EXISTS "animals_select_own" ON public.animals;
DROP POLICY IF EXISTS "animals_insert_own" ON public.animals;
DROP POLICY IF EXISTS "animals_update_own" ON public.animals;
DROP POLICY IF EXISTS "animals_delete_own" ON public.animals;
DROP POLICY IF EXISTS "allow_all_animals_access" ON public.animals;

DROP POLICY IF EXISTS "foals_select_own" ON public.foals;
DROP POLICY IF EXISTS "foals_insert_own" ON public.foals;
DROP POLICY IF EXISTS "foals_update_own" ON public.foals;
DROP POLICY IF EXISTS "foals_delete_own" ON public.foals;

DROP POLICY IF EXISTS "puppies_select_own" ON public.puppies;
DROP POLICY IF EXISTS "puppies_insert_own" ON public.puppies;
DROP POLICY IF EXISTS "puppies_update_own" ON public.puppies;
DROP POLICY IF EXISTS "puppies_delete_own" ON public.puppies;

DROP POLICY IF EXISTS "contacts_select_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_insert_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_update_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_delete_own" ON public.contacts;

DROP POLICY IF EXISTS "breeding_select_own" ON public.breeding_records;
DROP POLICY IF EXISTS "breeding_insert_own" ON public.breeding_records;
DROP POLICY IF EXISTS "breeding_update_own" ON public.breeding_records;
DROP POLICY IF EXISTS "breeding_delete_own" ON public.breeding_records;

DROP POLICY IF EXISTS "pregnancy_select_own" ON public.pregnancy_records;
DROP POLICY IF EXISTS "pregnancy_insert_own" ON public.pregnancy_records;
DROP POLICY IF EXISTS "pregnancy_update_own" ON public.pregnancy_records;
DROP POLICY IF EXISTS "pregnancy_delete_own" ON public.pregnancy_records;

DROP POLICY IF EXISTS "markings_select_own" ON public.markings;
DROP POLICY IF EXISTS "markings_insert_own" ON public.markings;
DROP POLICY IF EXISTS "markings_update_own" ON public.markings;
DROP POLICY IF EXISTS "markings_delete_own" ON public.markings;
DROP POLICY IF EXISTS "allow_all_markings_access" ON public.markings;

DROP POLICY IF EXISTS "preventative_care_select_own" ON public.preventative_care;
DROP POLICY IF EXISTS "preventative_care_insert_own" ON public.preventative_care;
DROP POLICY IF EXISTS "preventative_care_update_own" ON public.preventative_care;
DROP POLICY IF EXISTS "preventative_care_delete_own" ON public.preventative_care;

-- 3. ANIMALS: Strict account_id isolation
CREATE POLICY "animals_select_own" ON public.animals
  FOR SELECT USING (account_id = auth.uid());
CREATE POLICY "animals_insert_own" ON public.animals
  FOR INSERT WITH CHECK (account_id = auth.uid());
CREATE POLICY "animals_update_own" ON public.animals
  FOR UPDATE USING (account_id = auth.uid()) WITH CHECK (account_id = auth.uid());
CREATE POLICY "animals_delete_own" ON public.animals
  FOR DELETE USING (account_id = auth.uid());

-- 4. FOALS: Strict account_id isolation
CREATE POLICY "foals_select_own" ON public.foals
  FOR SELECT USING (account_id = auth.uid());
CREATE POLICY "foals_insert_own" ON public.foals
  FOR INSERT WITH CHECK (account_id = auth.uid());
CREATE POLICY "foals_update_own" ON public.foals
  FOR UPDATE USING (account_id = auth.uid()) WITH CHECK (account_id = auth.uid());
CREATE POLICY "foals_delete_own" ON public.foals
  FOR DELETE USING (account_id = auth.uid());

-- 5. PUPPIES: Strict account_id isolation
CREATE POLICY "puppies_select_own" ON public.puppies
  FOR SELECT USING (account_id = auth.uid());
CREATE POLICY "puppies_insert_own" ON public.puppies
  FOR INSERT WITH CHECK (account_id = auth.uid());
CREATE POLICY "puppies_update_own" ON public.puppies
  FOR UPDATE USING (account_id = auth.uid()) WITH CHECK (account_id = auth.uid());
CREATE POLICY "puppies_delete_own" ON public.puppies
  FOR DELETE USING (account_id = auth.uid());

-- 6. CONTACTS: Strict account_id isolation
CREATE POLICY "contacts_select_own" ON public.contacts
  FOR SELECT USING (account_id = auth.uid());
CREATE POLICY "contacts_insert_own" ON public.contacts
  FOR INSERT WITH CHECK (account_id = auth.uid());
CREATE POLICY "contacts_update_own" ON public.contacts
  FOR UPDATE USING (account_id = auth.uid()) WITH CHECK (account_id = auth.uid());
CREATE POLICY "contacts_delete_own" ON public.contacts
  FOR DELETE USING (account_id = auth.uid());

-- 7. BREEDING RECORDS: Strict account_id isolation
CREATE POLICY "breeding_select_own" ON public.breeding_records
  FOR SELECT USING (account_id = auth.uid());
CREATE POLICY "breeding_insert_own" ON public.breeding_records
  FOR INSERT WITH CHECK (account_id = auth.uid());
CREATE POLICY "breeding_update_own" ON public.breeding_records
  FOR UPDATE USING (account_id = auth.uid()) WITH CHECK (account_id = auth.uid());
CREATE POLICY "breeding_delete_own" ON public.breeding_records
  FOR DELETE USING (account_id = auth.uid());

-- 8. PREGNANCY RECORDS: Strict account_id isolation
CREATE POLICY "pregnancy_select_own" ON public.pregnancy_records
  FOR SELECT USING (account_id = auth.uid());
CREATE POLICY "pregnancy_insert_own" ON public.pregnancy_records
  FOR INSERT WITH CHECK (account_id = auth.uid());
CREATE POLICY "pregnancy_update_own" ON public.pregnancy_records
  FOR UPDATE USING (account_id = auth.uid()) WITH CHECK (account_id = auth.uid());
CREATE POLICY "pregnancy_delete_own" ON public.pregnancy_records
  FOR DELETE USING (account_id = auth.uid());

-- 9. MARKINGS: Relational account_id isolation (via animal or foal owner)
CREATE POLICY "markings_select_own" ON public.markings
  FOR SELECT USING (
    (owner_type = 'animal' AND EXISTS (
      SELECT 1 FROM public.animals a WHERE a.id::text = markings.owner_id::text AND a.account_id = auth.uid()
    ))
    OR
    (owner_type = 'foal' AND EXISTS (
      SELECT 1 FROM public.foals f WHERE f.id::text = markings.owner_id::text AND f.account_id = auth.uid()
    ))
  );

CREATE POLICY "markings_insert_own" ON public.markings
  FOR INSERT WITH CHECK (
    (owner_type = 'animal' AND EXISTS (
      SELECT 1 FROM public.animals a WHERE a.id::text = markings.owner_id::text AND a.account_id = auth.uid()
    ))
    OR
    (owner_type = 'foal' AND EXISTS (
      SELECT 1 FROM public.foals f WHERE f.id::text = markings.owner_id::text AND f.account_id = auth.uid()
    ))
  );

CREATE POLICY "markings_update_own" ON public.markings
  FOR UPDATE USING (
    (owner_type = 'animal' AND EXISTS (
      SELECT 1 FROM public.animals a WHERE a.id::text = markings.owner_id::text AND a.account_id = auth.uid()
    ))
    OR
    (owner_type = 'foal' AND EXISTS (
      SELECT 1 FROM public.foals f WHERE f.id::text = markings.owner_id::text AND f.account_id = auth.uid()
    ))
  );

CREATE POLICY "markings_delete_own" ON public.markings
  FOR DELETE USING (
    (owner_type = 'animal' AND EXISTS (
      SELECT 1 FROM public.animals a WHERE a.id::text = markings.owner_id::text AND a.account_id = auth.uid()
    ))
    OR
    (owner_type = 'foal' AND EXISTS (
      SELECT 1 FROM public.foals f WHERE f.id::text = markings.owner_id::text AND f.account_id = auth.uid()
    ))
  );

-- 10. PREVENTATIVE CARE: Relational account_id isolation
CREATE POLICY "preventative_care_select_own" ON public.preventative_care
  FOR SELECT USING (
    (owner_type = 'animal' AND EXISTS (
      SELECT 1 FROM public.animals a WHERE a.id::text = preventative_care.owner_id::text AND a.account_id = auth.uid()
    ))
    OR
    (owner_type = 'foal' AND EXISTS (
      SELECT 1 FROM public.foals f WHERE f.id::text = preventative_care.owner_id::text AND f.account_id = auth.uid()
    ))
  );

CREATE POLICY "preventative_care_insert_own" ON public.preventative_care
  FOR INSERT WITH CHECK (
    (owner_type = 'animal' AND EXISTS (
      SELECT 1 FROM public.animals a WHERE a.id::text = preventative_care.owner_id::text AND a.account_id = auth.uid()
    ))
    OR
    (owner_type = 'foal' AND EXISTS (
      SELECT 1 FROM public.foals f WHERE f.id::text = preventative_care.owner_id::text AND f.account_id = auth.uid()
    ))
  );

CREATE POLICY "preventative_care_update_own" ON public.preventative_care
  FOR UPDATE USING (
    (owner_type = 'animal' AND EXISTS (
      SELECT 1 FROM public.animals a WHERE a.id::text = preventative_care.owner_id::text AND a.account_id = auth.uid()
    ))
    OR
    (owner_type = 'foal' AND EXISTS (
      SELECT 1 FROM public.foals f WHERE f.id::text = preventative_care.owner_id::text AND f.account_id = auth.uid()
    ))
  );

CREATE POLICY "preventative_care_delete_own" ON public.preventative_care
  FOR DELETE USING (
    (owner_type = 'animal' AND EXISTS (
      SELECT 1 FROM public.animals a WHERE a.id::text = preventative_care.owner_id::text AND a.account_id = auth.uid()
    ))
    OR
    (owner_type = 'foal' AND EXISTS (
      SELECT 1 FROM public.foals f WHERE f.id::text = preventative_care.owner_id::text AND f.account_id = auth.uid()
    ))
  );
