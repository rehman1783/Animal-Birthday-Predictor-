-- ====================================================================
-- SQL Schema Migration for Animal Birthday Predictor - Part B
-- Features: Mare, Breeding, Pregnancy, Recipient Mare, Foal, Preventative Care, Markings & Reminders
-- ====================================================================

-- 1. MARES
CREATE TABLE IF NOT EXISTS public.mares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  breed TEXT,
  brand TEXT,
  dna TEXT,
  microchip_no TEXT,
  owner_client_name TEXT,
  owner_client_phone TEXT,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 2. MARKINGS (polymorphic: mare, recipient_mare, foal)
CREATE TABLE IF NOT EXISTS public.markings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type TEXT NOT NULL CHECK (owner_type IN ('mare', 'recipient_mare', 'foal')),
  owner_id UUID NOT NULL,
  left_side_image_url TEXT,
  right_side_image_url TEXT,
  head_view_image_url TEXT,
  head_view_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 3. BREEDING RECORDS
CREATE TABLE IF NOT EXISTS public.breeding_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mare_id UUID REFERENCES public.mares(id) ON DELETE CASCADE NOT NULL,
  method TEXT NOT NULL CHECK (method IN ('natural', 'chilled', 'frozen', 'icsi')),
  is_embryo_transfer BOOLEAN DEFAULT FALSE NOT NULL,
  cover_or_transfer_date DATE,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 4. RECIPIENT MARES
CREATE TABLE IF NOT EXISTS public.recipient_mares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  breeding_record_id UUID REFERENCES public.breeding_records(id) ON DELETE SET NULL,
  name_no TEXT NOT NULL,
  date_of_birth DATE,
  colour TEXT,
  microchip_no TEXT,
  dam_of_embryo TEXT,
  stallion_of_embryo TEXT,
  transfer_date DATE,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 5. PREGNANCY RECORDS
CREATE TABLE IF NOT EXISTS public.pregnancy_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  carrier_type TEXT NOT NULL CHECK (carrier_type IN ('mare', 'recipient_mare')),
  carrier_id UUID NOT NULL,
  breeding_record_id UUID REFERENCES public.breeding_records(id) ON DELETE SET NULL,
  scan_1_due_date DATE,
  scan_1_confirmed BOOLEAN DEFAULT FALSE NOT NULL,
  scan_1_image_url TEXT,
  scan_2_due_date DATE,
  scan_2_confirmed BOOLEAN DEFAULT FALSE NOT NULL,
  scan_2_image_url TEXT,
  scan_3_due_date DATE,
  scan_3_confirmed BOOLEAN DEFAULT FALSE NOT NULL,
  scan_3_image_url TEXT,
  foaling_due_date DATE,
  vet_name TEXT,
  vet_mobile TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 6. ADVANCED PREGNANCY INFO
CREATE TABLE IF NOT EXISTS public.advanced_pregnancy_info (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pregnancy_record_id UUID REFERENCES public.pregnancy_records(id) ON DELETE CASCADE NOT NULL,
  caslick_date DATE,
  caslick_done BOOLEAN DEFAULT FALSE NOT NULL,
  fetal_sex_scan_date DATE,
  fetal_sex_scan_done BOOLEAN DEFAULT FALSE NOT NULL,
  ffs_result_date DATE,
  ffs_result TEXT CHECK (ffs_result IN ('filly', 'colt')),
  ultrasound_image_url TEXT
);

-- 7. PREVENTATIVE CARE (polymorphic: mare, foal)
CREATE TABLE IF NOT EXISTS public.preventative_care (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type TEXT NOT NULL CHECK (owner_type IN ('mare', 'foal')),
  owner_id UUID NOT NULL,
  wormer_date DATE, wormer_done BOOLEAN DEFAULT FALSE NOT NULL,
  tetanus_date DATE, tetanus_done BOOLEAN DEFAULT FALSE NOT NULL,
  strangles_date DATE, strangles_done BOOLEAN DEFAULT FALSE NOT NULL,
  eq_herpes_date DATE, eq_herpes_done BOOLEAN DEFAULT FALSE NOT NULL,
  rotavirus_date DATE, rotavirus_done BOOLEAN DEFAULT FALSE NOT NULL,
  hendra_date DATE, hendra_done BOOLEAN DEFAULT FALSE NOT NULL,
  eq_influenza_date DATE, eq_influenza_done BOOLEAN DEFAULT FALSE NOT NULL,
  eee_wee_wnv_date DATE, eee_wee_wnv_done BOOLEAN DEFAULT FALSE NOT NULL,
  rabies_date DATE, rabies_done BOOLEAN DEFAULT FALSE NOT NULL,
  dental_date DATE, dental_done BOOLEAN DEFAULT FALSE NOT NULL,
  dentist_number TEXT,
  farrier_date DATE, farrier_done BOOLEAN DEFAULT FALSE NOT NULL,
  farrier_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 8. FOALS
CREATE TABLE IF NOT EXISTS public.foals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mare_id UUID REFERENCES public.mares(id) ON DELETE CASCADE NOT NULL,
  recipient_mare_id UUID REFERENCES public.recipient_mares(id) ON DELETE SET NULL,
  foal_name TEXT,
  date_of_birth DATE,
  stallion TEXT,
  breed TEXT,
  sex TEXT CHECK (sex IN ('filly', 'colt')),
  igg_value TEXT,
  foal_microchip_no TEXT,
  dna TEXT,
  gelded BOOLEAN DEFAULT FALSE NOT NULL,
  gelded_date DATE,
  stud_book_association TEXT,
  notes TEXT,
  status TEXT CHECK (status IN ('sold', 'keep', 'transferred')),
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 9. CALENDAR REMINDERS
CREATE TABLE IF NOT EXISTS public.calendar_reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  related_table TEXT NOT NULL,
  related_id UUID NOT NULL,
  field_name TEXT NOT NULL,
  reminder_date DATE NOT NULL,
  label TEXT,
  synced_to_device_calendar BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

ALTER TABLE public.mares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.markings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breeding_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipient_mares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pregnancy_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.advanced_pregnancy_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preventative_care ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_reminders ENABLE ROW LEVEL SECURITY;

-- Mares RLS
DROP POLICY IF EXISTS "Users can manage their own mares" ON public.mares;
CREATE POLICY "Users can manage their own mares" ON public.mares
  FOR ALL USING (auth.uid() = account_id);

-- Recipient Mares RLS
DROP POLICY IF EXISTS "Users can manage their own recipient mares" ON public.recipient_mares;
CREATE POLICY "Users can manage their own recipient mares" ON public.recipient_mares
  FOR ALL USING (auth.uid() = account_id);

-- Calendar Reminders RLS
DROP POLICY IF EXISTS "Users can manage their own calendar reminders" ON public.calendar_reminders;
CREATE POLICY "Users can manage their own calendar reminders" ON public.calendar_reminders
  FOR ALL USING (auth.uid() = account_id);

-- Markings RLS
DROP POLICY IF EXISTS "Users can manage markings" ON public.markings;
CREATE POLICY "Users can manage markings" ON public.markings
  FOR ALL USING (true);

-- Breeding Records RLS
DROP POLICY IF EXISTS "Users can manage breeding records" ON public.breeding_records;
CREATE POLICY "Users can manage breeding records" ON public.breeding_records
  FOR ALL USING (true);

-- Pregnancy Records RLS
DROP POLICY IF EXISTS "Users can manage pregnancy records" ON public.pregnancy_records;
CREATE POLICY "Users can manage pregnancy records" ON public.pregnancy_records
  FOR ALL USING (true);

-- Advanced Pregnancy Info RLS
DROP POLICY IF EXISTS "Users can manage advanced pregnancy info" ON public.advanced_pregnancy_info;
CREATE POLICY "Users can manage advanced pregnancy info" ON public.advanced_pregnancy_info
  FOR ALL USING (true);

-- Preventative Care RLS
DROP POLICY IF EXISTS "Users can manage preventative care" ON public.preventative_care;
CREATE POLICY "Users can manage preventative care" ON public.preventative_care
  FOR ALL USING (true);

-- Foals RLS
DROP POLICY IF EXISTS "Users can manage foals" ON public.foals;
CREATE POLICY "Users can manage foals" ON public.foals
  FOR ALL USING (true);
