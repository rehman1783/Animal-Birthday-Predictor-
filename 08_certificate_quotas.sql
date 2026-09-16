-- =====================================================================
-- ABP (Animal BirthDay Predictor) — Certificate Quota & Entitlements
-- Migration 08: Tracks allowed vs consumed certificate generation quota
-- Prevents users from generating more certificates than entitled/purchased
-- =====================================================================

-- 1. Table: certificate_entitlements
create table if not exists public.certificate_entitlements (
  user_id             uuid primary key references auth.users(id) on delete cascade,
  total_allocated     int not null default 5,
  used_count          int not null default 0,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint chk_used_non_negative check (used_count >= 0),
  constraint chk_total_non_negative check (total_allocated >= 0)
);

create index if not exists idx_cert_entitlements_user on public.certificate_entitlements (user_id);

-- Trigger for updated_at
drop trigger if exists trg_cert_entitlements_updated_at on public.certificate_entitlements;
create trigger trg_cert_entitlements_updated_at
  before update on public.certificate_entitlements
  for each row execute function public.set_updated_at();

-- 2. Table: generated_certificates (Audit log of all issued certificates)
create table if not exists public.generated_certificates (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references auth.users(id) on delete cascade,
  certificate_id      text not null unique,
  certificate_type    text not null check (certificate_type in ('foal', 'puppy', '45_day_scan', 'diary', 'other')),
  target_id           text not null, -- Foal ID, Puppy ID, or Pregnancy ID
  target_name         text not null default '',
  issued_at           timestamptz not null default now(),
  metadata            jsonb default '{}'::jsonb
);

create index if not exists idx_gen_cert_user_target on public.generated_certificates (user_id, target_id);
create index if not exists idx_gen_cert_code on public.generated_certificates (certificate_id);

-- 3. Enable RLS
alter table public.certificate_entitlements enable row level security;
alter table public.generated_certificates enable row level security;

-- Policies for certificate_entitlements
drop policy if exists "Users can view own certificate entitlements" on public.certificate_entitlements;
create policy "Users can view own certificate entitlements"
  on public.certificate_entitlements for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own initial entitlement" on public.certificate_entitlements;
create policy "Users can insert own initial entitlement"
  on public.certificate_entitlements for insert
  with check (auth.uid() = user_id);

-- Policies for generated_certificates
drop policy if exists "Users can view own generated certificates" on public.generated_certificates;
create policy "Users can view own generated certificates"
  on public.generated_certificates for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own generated certificate" on public.generated_certificates;
create policy "Users can insert own generated certificate"
  on public.generated_certificates for insert
  with check (auth.uid() = user_id);

-- 4. Stored Procedure: check_certificate_entitlement
create or replace function public.check_certificate_entitlement(target_id_param text)
returns json
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_already_generated boolean := false;
  v_total int := 5;
  v_used int := 0;
  v_remaining int := 5;
begin
  if v_user_id is null then
    return json_build_object(
      'allowed', false,
      'error', 'Authentication required'
    );
  end if;

  -- Check if already generated for this specific target (foal/puppy/pregnancy)
  select exists (
    select 1 from public.generated_certificates
    where user_id = v_user_id and target_id = target_id_param
  ) into v_already_generated;

  -- Fetch or initialize user's entitlement record
  insert into public.certificate_entitlements (user_id, total_allocated, used_count)
  values (v_user_id, 5, 0)
  on conflict (user_id) do nothing;

  select total_allocated, used_count
  into v_total, v_used
  from public.certificate_entitlements
  where user_id = v_user_id;

  v_remaining := greatest(0, v_total - v_used);

  -- If previously generated for this animal, re-downloading is free and allowed
  if v_already_generated then
    return json_build_object(
      'allowed', true,
      'already_generated', true,
      'total', v_total,
      'used', v_used,
      'remaining', v_remaining
    );
  end if;

  -- Otherwise, must have at least 1 credit remaining
  return json_build_object(
    'allowed', (v_remaining > 0),
    'already_generated', false,
    'total', v_total,
    'used', v_used,
    'remaining', v_remaining
  );
end;
$$;

grant execute on function public.check_certificate_entitlement(text) to authenticated, anon;

-- 5. Stored Procedure: consume_certificate_credit
create or replace function public.consume_certificate_credit(
  cert_id_param text,
  cert_type_param text,
  target_id_param text,
  target_name_param text default ''
)
returns json
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_already_generated boolean := false;
  v_total int := 5;
  v_used int := 0;
  v_remaining int := 5;
begin
  if v_user_id is null then
    return json_build_object('success', false, 'error', 'Authentication required');
  end if;

  -- Check if certificate for this animal already exists
  select exists (
    select 1 from public.generated_certificates
    where user_id = v_user_id and target_id = target_id_param
  ) into v_already_generated;

  -- Ensure entitlement row exists
  insert into public.certificate_entitlements (user_id, total_allocated, used_count)
  values (v_user_id, 5, 0)
  on conflict (user_id) do nothing;

  select total_allocated, used_count
  into v_total, v_used
  from public.certificate_entitlements
  where user_id = v_user_id;

  v_remaining := greatest(0, v_total - v_used);

  -- If previously generated, do not consume another credit
  if v_already_generated then
    return json_build_object(
      'success', true,
      'credit_consumed', false,
      'already_generated', true,
      'total', v_total,
      'used', v_used,
      'remaining', v_remaining
    );
  end if;

  -- Check quota
  if v_remaining <= 0 then
    return json_build_object(
      'success', false,
      'error', 'Quota exceeded. Additional certificates required.',
      'total', v_total,
      'used', v_used,
      'remaining', 0
    );
  end if;

  -- Record newly generated certificate
  insert into public.generated_certificates (
    user_id,
    certificate_id,
    certificate_type,
    target_id,
    target_name
  ) values (
    v_user_id,
    cert_id_param,
    cert_type_param,
    target_id_param,
    target_name_param
  );

  -- Increment consumed count atomically
  update public.certificate_entitlements
  set used_count = used_count + 1
  where user_id = v_user_id;

  v_used := v_used + 1;
  v_remaining := greatest(0, v_total - v_used);

  return json_build_object(
    'success', true,
    'credit_consumed', true,
    'already_generated', false,
    'total', v_total,
    'used', v_used,
    'remaining', v_remaining
  );
end;
$$;

grant execute on function public.consume_certificate_credit(text, text, text, text) to authenticated, anon;

-- 6. Stored Procedure: admin_adjust_certificate_credits
create or replace function public.admin_adjust_certificate_credits(
  target_user_id uuid,
  credits_to_add int
)
returns json
language plpgsql
security definer
as $$
declare
  v_new_total int;
begin
  insert into public.certificate_entitlements (user_id, total_allocated, used_count)
  values (target_user_id, 5 + credits_to_add, 0)
  on conflict (user_id) do update
  set total_allocated = public.certificate_entitlements.total_allocated + credits_to_add;

  select total_allocated into v_new_total
  from public.certificate_entitlements
  where user_id = target_user_id;

  return json_build_object(
    'success', true,
    'user_id', target_user_id,
    'total_allocated', v_new_total
  );
end;
$$;

grant execute on function public.admin_adjust_certificate_credits(uuid, int) to authenticated;
