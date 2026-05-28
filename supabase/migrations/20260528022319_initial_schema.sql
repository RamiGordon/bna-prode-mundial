-- =============================================================================
-- Initial schema for Prode Mundial 2026
-- Tablas, RLS, funciones y triggers según docs/03-data-model.md
-- Reglas de puntaje según docs/04-scoring-rules.md
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Enums
-- -----------------------------------------------------------------------------

create type match_stage as enum (
  'group', 'r32', 'r16', 'quarter', 'semi', 'third', 'final'
);

-- -----------------------------------------------------------------------------
-- 2. Tablas
-- -----------------------------------------------------------------------------

-- profiles: extiende auth.users. Se crea por trigger al registrarse un usuario.
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  alias text not null,
  avatar_url text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

-- teams: 48 selecciones del Mundial. Cargadas vía seed (T-010).
create table teams (
  id serial primary key,
  name text not null,
  code char(3) not null unique,
  group_letter char(1) not null,
  flag_emoji text
);

-- matches: 104 partidos. Cargados vía seed (T-011).
create table matches (
  id serial primary key,
  stage match_stage not null,
  team_a_id int references teams(id),
  team_b_id int references teams(id),
  kickoff_at timestamptz not null,
  venue text,
  score_a int,
  score_b int,
  finalized_at timestamptz,
  created_at timestamptz not null default now()
);

create index idx_matches_kickoff on matches(kickoff_at);

-- predictions: una por (user, match). Inmutables salvo updated_at.
create table predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  match_id int not null references matches(id) on delete cascade,
  pred_a int not null check (pred_a >= 0 and pred_a <= 20),
  pred_b int not null check (pred_b >= 0 and pred_b <= 20),
  points_awarded int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, match_id)
);

create index idx_predictions_match on predictions(match_id);
create index idx_predictions_user on predictions(user_id);

-- bonus_predictions: una por user. user_id es PK.
create table bonus_predictions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  champion_team_id int references teams(id),
  runner_up_team_id int references teams(id),
  top_scorer_name text,
  semifinalist_1 int references teams(id),
  semifinalist_2 int references teams(id),
  semifinalist_3 int references teams(id),
  semifinalist_4 int references teams(id),
  points_awarded int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- result_changes_log: auditoría obligatoria de cambios de score.
create table result_changes_log (
  id serial primary key,
  match_id int not null references matches(id),
  old_score_a int,
  old_score_b int,
  new_score_a int,
  new_score_b int,
  changed_by uuid not null references auth.users(id),
  changed_at timestamptz not null default now(),
  reason text
);

-- app_config: singleton (id siempre = 1).
-- scoring_rules jsonb shape:
--   {
--     "match_points": { "exact": 5, "winner_and_diff": 3, "winner_or_draw": 2, "none": 0 },
--     "stage_multipliers": { "group": 1.0, "r32": 1.0, "r16": 1.5, "quarter": 2.0,
--                            "semi": 2.5, "third": 1.5, "final": 3.0 },
--     "bonus_points": { "champion": 20, "runner_up": 10, "top_scorer": 15,
--                       "semifinalist_each": 5 }
--   }
create table app_config (
  id int primary key default 1 check (id = 1),
  tournament_start_at timestamptz not null,
  bonus_lock_at timestamptz not null,
  rules_locked boolean not null default false,
  scoring_rules jsonb not null
);

-- -----------------------------------------------------------------------------
-- 3. Insert inicial de app_config
-- 11/06/2026 19:00 ART = 22:00 UTC
-- -----------------------------------------------------------------------------

insert into app_config (id, tournament_start_at, bonus_lock_at, rules_locked, scoring_rules)
values (
  1,
  '2026-06-11 22:00:00+00',
  '2026-06-11 22:00:00+00',
  false,
  jsonb_build_object(
    'match_points', jsonb_build_object(
      'exact', 5,
      'winner_and_diff', 3,
      'winner_or_draw', 2,
      'none', 0
    ),
    'stage_multipliers', jsonb_build_object(
      'group', 1.0,
      'r32', 1.0,
      'r16', 1.5,
      'quarter', 2.0,
      'semi', 2.5,
      'third', 1.5,
      'final', 3.0
    ),
    'bonus_points', jsonb_build_object(
      'champion', 20,
      'runner_up', 10,
      'top_scorer', 15,
      'semifinalist_each', 5
    )
  )
);

-- -----------------------------------------------------------------------------
-- 4. Helper: is_admin(uid)
-- SECURITY DEFINER + search_path fijo evita recursión cuando se usa
-- dentro de policies de la propia tabla profiles.
-- -----------------------------------------------------------------------------

create or replace function is_admin(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select is_admin from profiles where id = uid), false);
$$;

-- -----------------------------------------------------------------------------
-- 5. Funciones y triggers
-- -----------------------------------------------------------------------------

-- 5a. handle_new_user: AFTER INSERT en auth.users → crea profile.
-- Alias = parte local del email. Usuario lo puede editar después.
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into profiles (id, alias)
  values (new.id, split_part(new.email, '@', 1))
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- 5b. set_updated_at: BEFORE UPDATE genérico para mantener updated_at fresco.
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger predictions_set_updated_at
  before update on predictions
  for each row execute function set_updated_at();

create trigger bonus_predictions_set_updated_at
  before update on bonus_predictions
  for each row execute function set_updated_at();

-- 5c. log_result_change: AFTER UPDATE de score_a/score_b en matches
-- → inserta auditoría. Falla si no hay auth.uid() (privilegia auditoría
-- sobre conveniencia operativa: cambios manuales sin sesión no permitidos).
create or replace function log_result_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (old.score_a is distinct from new.score_a)
     or (old.score_b is distinct from new.score_b) then
    if auth.uid() is null then
      raise exception 'cannot change match result without authenticated user';
    end if;
    insert into result_changes_log
      (match_id, old_score_a, old_score_b, new_score_a, new_score_b, changed_by)
    values
      (new.id, old.score_a, old.score_b, new.score_a, new.score_b, auth.uid());
  end if;
  return new;
end;
$$;

create trigger on_match_score_changed
  after update of score_a, score_b on matches
  for each row execute function log_result_change();

-- 5d. calculate_match_points: recalcula points_awarded de todas las
-- predicciones de un partido. Lee reglas desde app_config.scoring_rules.
-- Lógica (en orden de prioridad):
--   - pred exacto                                 → puntos exactos
--   - misma diferencia de goles (incluye ganador) → puntos winner_and_diff
--   - mismo signo (ganador o empate acertado)     → puntos winner_or_draw
--   - sino                                        → 0
-- Multiplica por stage. round(numeric) usa half-up, no bankers'.
create or replace function calculate_match_points(p_match_id int)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_score_a int;
  v_score_b int;
  v_stage text;
  v_rules jsonb;
  v_pts_exact numeric;
  v_pts_winner_and_diff numeric;
  v_pts_winner_or_draw numeric;
  v_multiplier numeric;
begin
  select score_a, score_b, stage::text
    into v_score_a, v_score_b, v_stage
  from matches
  where id = p_match_id;

  if v_score_a is null or v_score_b is null then
    return;
  end if;

  select scoring_rules into v_rules from app_config where id = 1;
  v_pts_exact := (v_rules -> 'match_points' ->> 'exact')::numeric;
  v_pts_winner_and_diff := (v_rules -> 'match_points' ->> 'winner_and_diff')::numeric;
  v_pts_winner_or_draw := (v_rules -> 'match_points' ->> 'winner_or_draw')::numeric;
  v_multiplier := (v_rules -> 'stage_multipliers' ->> v_stage)::numeric;

  update predictions
  set points_awarded = round(
    case
      when pred_a = v_score_a and pred_b = v_score_b
        then v_pts_exact * v_multiplier
      when (pred_a - pred_b) = (v_score_a - v_score_b)
        then v_pts_winner_and_diff * v_multiplier
      when sign(pred_a - pred_b) = sign(v_score_a - v_score_b)
        then v_pts_winner_or_draw * v_multiplier
      else 0
    end
  )::int
  where match_id = p_match_id;
end;
$$;

-- 5e. trigger_calculate_match_points: dispara recálculo cuando cambia
-- score o finalized_at. Cubre tanto carga inicial como correcciones.
create or replace function trigger_calculate_match_points()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform calculate_match_points(new.id);
  return new;
end;
$$;

create trigger on_match_result_set
  after update of score_a, score_b, finalized_at on matches
  for each row execute function trigger_calculate_match_points();

-- 5f. recalculate_bonus_points: stub. Implementación real en T-017+
-- cuando aterricen los bonus y al cierre del torneo.
create or replace function recalculate_bonus_points()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  return;
end;
$$;

-- -----------------------------------------------------------------------------
-- 6. Row Level Security
-- -----------------------------------------------------------------------------

alter table profiles enable row level security;
alter table teams enable row level security;
alter table matches enable row level security;
alter table predictions enable row level security;
alter table bonus_predictions enable row level security;
alter table result_changes_log enable row level security;
alter table app_config enable row level security;

-- 6a. profiles
-- SELECT: cualquiera autenticado puede ver alias y avatar_url de todos.
-- UPDATE: solo el dueño.
-- INSERT: vía trigger handle_new_user (SECURITY DEFINER bypassea RLS).
-- DELETE: bloqueado (sin policy).
create policy profiles_select_authenticated on profiles
  for select to authenticated
  using (true);

create policy profiles_update_own on profiles
  for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- 6b. teams
create policy teams_select_authenticated on teams
  for select to authenticated
  using (true);

create policy teams_admin_cud on teams
  for all to authenticated
  using (is_admin(auth.uid()))
  with check (is_admin(auth.uid()));

-- 6c. matches
create policy matches_select_authenticated on matches
  for select to authenticated
  using (true);

create policy matches_admin_cud on matches
  for all to authenticated
  using (is_admin(auth.uid()))
  with check (is_admin(auth.uid()));

-- 6d. predictions (las críticas)
-- SELECT: el usuario ve siempre las suyas; las de otros solo si
--   el partido ya empezó (para no spoilear estrategias).
create policy predictions_select on predictions
  for select to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1 from matches m
      where m.id = match_id and m.kickoff_at <= now()
    )
  );

-- INSERT: solo own AND match aún no empezó.
create policy predictions_insert_own_pre_kickoff on predictions
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from matches m
      where m.id = match_id and m.kickoff_at > now()
    )
  );

-- UPDATE: solo own AND match aún no empezó (lock al kickoff).
create policy predictions_update_own_pre_kickoff on predictions
  for update to authenticated
  using (
    user_id = auth.uid()
    and exists (
      select 1 from matches m
      where m.id = match_id and m.kickoff_at > now()
    )
  )
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from matches m
      where m.id = match_id and m.kickoff_at > now()
    )
  );

-- DELETE: bloqueado siempre (sin policy).

-- 6e. bonus_predictions
-- SELECT: own siempre; los de otros solo post-kickoff inaugural.
create policy bonus_predictions_select on bonus_predictions
  for select to authenticated
  using (
    user_id = auth.uid()
    or now() >= (select tournament_start_at from app_config where id = 1)
  );

create policy bonus_predictions_insert_own_pre_lock on bonus_predictions
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and now() < (select bonus_lock_at from app_config where id = 1)
  );

create policy bonus_predictions_update_own_pre_lock on bonus_predictions
  for update to authenticated
  using (
    user_id = auth.uid()
    and now() < (select bonus_lock_at from app_config where id = 1)
  )
  with check (
    user_id = auth.uid()
    and now() < (select bonus_lock_at from app_config where id = 1)
  );

-- 6f. result_changes_log
-- SELECT: solo admin. INSERT: vía trigger (SECURITY DEFINER bypassea RLS).
-- UPDATE/DELETE: bloqueados.
create policy result_changes_log_select_admin on result_changes_log
  for select to authenticated
  using (is_admin(auth.uid()));

-- 6g. app_config
create policy app_config_select_authenticated on app_config
  for select to authenticated
  using (true);

create policy app_config_admin_cud on app_config
  for all to authenticated
  using (is_admin(auth.uid()))
  with check (is_admin(auth.uid()));

-- -----------------------------------------------------------------------------
-- 7. View de ranking
-- security_invoker = true (PG15+): la view ejecuta con permisos del
-- caller, respetando las policies de las tablas subyacentes.
-- -----------------------------------------------------------------------------

create view ranking
with (security_invoker = true)
as
select
  p.id,
  p.alias,
  p.avatar_url,
  coalesce(sum(pr.points_awarded), 0) + coalesce(max(bp.points_awarded), 0) as total_points
from profiles p
left join predictions pr on pr.user_id = p.id
left join bonus_predictions bp on bp.user_id = p.id
group by p.id, p.alias, p.avatar_url
order by total_points desc;
