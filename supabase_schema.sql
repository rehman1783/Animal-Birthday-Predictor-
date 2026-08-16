-- ====================================================================
-- ABP (Animal BirthDay Predictor) — Database Schema: Part A
-- Feature: Supabase Email/Password Authentication & User Profiles
-- Target: Supabase / PostgreSQL 15+
-- ====================================================================

-- 1. Create linked `profiles` table
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  full_name   text not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Index for fast lookup by email
create index if not exists idx_profiles_email on public.profiles (lower(email));

-- 2. Reusable trigger function for updated_at
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- 3. Automatic Profile Creation Trigger on auth.users
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

-- 4. Helper Function: Check Email Exists (Security Definer)
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

-- 5. Helper Function: Check Email Verified (Security Definer)
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

-- 6. Row-Level Security (RLS) Policies
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

-- ====================================================================
-- End of supabase_schema.sql
-- ====================================================================
