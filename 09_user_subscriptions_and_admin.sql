-- =====================================================================
-- ABP (Animal BirthDay Predictor) — User Subscriptions & Master Admin Panel
-- Migration 09: Full Enterprise Admin RPCs & Subscription Engine
-- =====================================================================

-- 1. Table: user_subscriptions
create table if not exists public.user_subscriptions (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null unique references auth.users(id) on delete cascade,
  plan_tier           text not null default 'Free' check (plan_tier in ('Free', 'Basic', 'Pro', 'Enterprise')),
  status              text not null default 'active' check (status in ('active', 'expired', 'canceled', 'suspended', 'trial')),
  billing_cycle       text not null default 'monthly' check (billing_cycle in ('monthly', 'annual', 'lifetime')),
  price_paid          numeric(10, 2) not null default 0.00,
  currency            text not null default 'USD',
  max_animal_quota    int not null default 1,
  starts_at           timestamptz not null default now(),
  expires_at          timestamptz default (now() + interval '1 month'),
  auto_renew          boolean not null default true,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_user_subscriptions_user on public.user_subscriptions (user_id);
create index if not exists idx_user_subscriptions_tier on public.user_subscriptions (plan_tier);
create index if not exists idx_user_subscriptions_status on public.user_subscriptions (status);

-- Updated_at trigger
drop trigger if exists trg_user_subscriptions_updated_at on public.user_subscriptions;
create trigger trg_user_subscriptions_updated_at
  before update on public.user_subscriptions
  for each row execute function public.set_updated_at();

-- 2. Enable RLS
alter table public.user_subscriptions enable row level security;

drop policy if exists "Users can view own subscription" on public.user_subscriptions;
create policy "Users can view own subscription"
  on public.user_subscriptions for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own subscription" on public.user_subscriptions;
create policy "Users can insert own subscription"
  on public.user_subscriptions for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own subscription" on public.user_subscriptions;
create policy "Users can update own subscription"
  on public.user_subscriptions for update
  using (auth.uid() = user_id);

-- 3. Automatic User Subscription Initialization Trigger
create or replace function public.handle_new_user_subscription()
returns trigger as $$
begin
  -- Ensure default subscription record exists
  insert into public.user_subscriptions (
    user_id, plan_tier, status, max_animal_quota, starts_at
  ) values (
    new.id, 'Free', 'active', 1, now()
  )
  on conflict (user_id) do nothing;

  -- Ensure default certificate entitlements record exists
  insert into public.certificate_entitlements (
    user_id, total_allocated, used_count
  ) values (
    new.id, 5, 0
  )
  on conflict (user_id) do nothing;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created_subscription on auth.users;
create trigger on_auth_user_created_subscription
  after insert on auth.users
  for each row execute function public.handle_new_user_subscription();

-- 4. Stored Procedure: get_admin_dashboard_stats
create or replace function public.get_admin_dashboard_stats()
returns json
language plpgsql
security definer
as $$
declare
  v_total_users int := 0;
  v_active_subscriptions int := 0;
  v_total_animals int := 0;
  v_total_certificates int := 0;
  v_free_count int := 0;
  v_basic_count int := 0;
  v_pro_count int := 0;
  v_enterprise_count int := 0;
  v_estimated_mrr numeric(10, 2) := 0.00;
begin
  select count(*) into v_total_users from public.profiles;

  select count(*) into v_active_subscriptions 
  from public.user_subscriptions 
  where status = 'active' and plan_tier <> 'Free';

  select count(*) into v_total_animals from public.animals;

  select count(*) into v_total_certificates from public.generated_certificates;

  select count(*) into v_free_count from public.user_subscriptions where plan_tier = 'Free' and status = 'active';
  select count(*) into v_basic_count from public.user_subscriptions where plan_tier = 'Basic' and status = 'active';
  select count(*) into v_pro_count from public.user_subscriptions where plan_tier = 'Pro' and status = 'active';
  select count(*) into v_enterprise_count from public.user_subscriptions where plan_tier = 'Enterprise' and status = 'active';

  v_estimated_mrr := (v_basic_count * 19.00) + (v_pro_count * 49.00) + (v_enterprise_count * 149.00);

  return json_build_object(
    'total_users', v_total_users,
    'active_subscriptions', v_active_subscriptions,
    'total_animals', v_total_animals,
    'total_certificates', v_total_certificates,
    'plan_breakdown', json_build_object(
      'free', v_free_count,
      'basic', v_basic_count,
      'pro', v_pro_count,
      'enterprise', v_enterprise_count
    ),
    'estimated_mrr', v_estimated_mrr
  );
end;
$$;

grant execute on function public.get_admin_dashboard_stats() to authenticated, anon;

-- 5. Stored Procedure: get_admin_users_overview
create or replace function public.get_admin_users_overview()
returns json
language plpgsql
security definer
as $$
declare
  v_result json;
begin
  select json_agg(
    json_build_object(
      'user_id', p.id,
      'email', p.email,
      'full_name', p.full_name,
      'created_at', p.created_at,
      'plan_tier', coalesce(s.plan_tier, 'Free'),
      'status', coalesce(s.status, 'active'),
      'billing_cycle', coalesce(s.billing_cycle, 'monthly'),
      'price_paid', coalesce(s.price_paid, 0.00),
      'max_animal_quota', coalesce(s.max_animal_quota, 1),
      'expires_at', s.expires_at,
      'total_certs_allocated', coalesce(e.total_allocated, 5),
      'certs_used', coalesce(e.used_count, 0),
      'animal_count', (select count(*) from public.animals a where a.user_id = p.id)
    )
    order by p.created_at desc
  )
  into v_result
  from public.profiles p
  left join public.user_subscriptions s on p.id = s.user_id
  left join public.certificate_entitlements e on p.id = e.user_id;

  return coalesce(v_result, '[]'::json);
end;
$$;

grant execute on function public.get_admin_users_overview() to authenticated, anon;

-- 6. Stored Procedure: get_admin_certificates_ledger
create or replace function public.get_admin_certificates_ledger()
returns json
language plpgsql
security definer
as $$
declare
  v_result json;
begin
  select json_agg(
    json_build_object(
      'id', c.id,
      'certificate_id', c.certificate_id,
      'certificate_type', c.certificate_type,
      'target_name', c.target_name,
      'issued_at', c.issued_at,
      'user_id', c.user_id,
      'user_email', coalesce(p.email, 'Unknown'),
      'user_name', coalesce(p.full_name, 'Unknown')
    )
    order by c.issued_at desc
  )
  into v_result
  from public.generated_certificates c
  left join public.profiles p on c.user_id = p.id;

  return coalesce(v_result, '[]'::json);
end;
$$;

grant execute on function public.get_admin_certificates_ledger() to authenticated, anon;

-- 7. Stored Procedure: get_admin_animals_registry
create or replace function public.get_admin_animals_registry()
returns json
language plpgsql
security definer
as $$
declare
  v_result json;
begin
  select json_agg(
    json_build_object(
      'id', a.id,
      'name', a.name,
      'species', a.species,
      'breed', a.breed,
      'sex', a.sex,
      'date_of_birth', a.date_of_birth,
      'microchip_number', a.microchip_number,
      'registration_number', a.registration_number,
      'created_at', a.created_at,
      'owner_id', a.user_id,
      'owner_email', coalesce(p.email, 'Unknown'),
      'owner_name', coalesce(p.full_name, 'Unknown')
    )
    order by a.created_at desc
  )
  into v_result
  from public.animals a
  left join public.profiles p on a.user_id = p.id;

  return coalesce(v_result, '[]'::json);
end;
$$;

grant execute on function public.get_admin_animals_registry() to authenticated, anon;

-- 8. Stored Procedure: admin_update_user_subscription
create or replace function public.admin_update_user_subscription(
  target_user_id uuid,
  new_plan_tier text,
  new_status text,
  new_quota int,
  new_expires_at timestamptz default null
)
returns json
language plpgsql
security definer
as $$
begin
  insert into public.user_subscriptions (
    user_id, plan_tier, status, max_animal_quota, expires_at
  ) values (
    target_user_id,
    new_plan_tier,
    new_status,
    new_quota,
    coalesce(new_expires_at, now() + interval '1 month')
  )
  on conflict (user_id) do update set
    plan_tier = excluded.plan_tier,
    status = excluded.status,
    max_animal_quota = excluded.max_animal_quota,
    expires_at = coalesce(new_expires_at, public.user_subscriptions.expires_at),
    updated_at = now();

  return json_build_object(
    'success', true,
    'user_id', target_user_id,
    'plan_tier', new_plan_tier,
    'status', new_status,
    'max_animal_quota', new_quota
  );
end;
$$;

grant execute on function public.admin_update_user_subscription(uuid, text, text, int, timestamptz) to authenticated, anon;
