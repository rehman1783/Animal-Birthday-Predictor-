-- =====================================================================
-- ABP (Animal Birthday Predictor) — Migration 06: Delete Account RPC
-- Target: Supabase / PostgreSQL 15+
-- Description: Creates a secure RPC function to allow authenticated users
--              to permanently delete their account, credentials, and all
--              associated records (animals, breeding, foals, puppies, etc.)
-- =====================================================================

-- Helper Function: Delete User Account and All Associated Data (Security Definer)
create or replace function public.delete_user_account()
returns void
language plpgsql
security definer
as $$
declare
  target_user_id uuid := auth.uid();
begin
  -- Ensure user is authenticated
  if target_user_id is null then
    raise exception 'User is not authenticated';
  end if;

  -- 1. Explicit cleanup of user data from public tables (also cascaded via foreign keys)
  delete from public.pregnancy_records where breeding_record_id in (
    select id from public.breeding_records where account_id = target_user_id
  );
  delete from public.breeding_records where account_id = target_user_id;
  delete from public.animals where account_id = target_user_id;
  delete from public.foals where account_id = target_user_id;
  delete from public.puppies where account_id = target_user_id;
  delete from public.contacts where account_id = target_user_id;
  delete from public.profiles where id = target_user_id;

  -- 2. Permanently delete the user authentication record from auth.users
  delete from auth.users where id = target_user_id;
end;
$$;

-- Grant execution permission to authenticated users
grant execute on function public.delete_user_account() to authenticated;
