# 03 — Modelo de datos

## Tablas

### `profiles`

Extiende `auth.users` de Supabase. Se crea por trigger al registrarse un usuario.

```sql
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  alias text not null,
  avatar_url text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);
```

**RLS:**
- SELECT: cualquiera autenticado puede ver alias y avatar_url de todos.
- UPDATE: solo el propio dueño puede actualizar su alias/avatar.
- INSERT: vía trigger (`handle_new_user`), no expuesto.
- DELETE: bloqueado.

### `teams`

48 selecciones del Mundial. Se cargan vía seed.

```sql
create table teams (
  id serial primary key,
  name text not null,           -- "Argentina"
  code char(3) not null unique, -- "ARG"
  group_letter char(1) not null,-- 'A'..'L' (12 grupos en formato 48 equipos)
  flag_emoji text                -- "🇦🇷" para UI
);
```

**RLS:** SELECT público, INSERT/UPDATE/DELETE solo admin.

### `matches`

104 partidos del Mundial. 72 fase de grupos + 32 eliminación directa.

```sql
create type match_stage as enum (
  'group', 'r32', 'r16', 'quarter', 'semi', 'third', 'final'
);

create table matches (
  id serial primary key,
  stage match_stage not null,
  team_a_id int references teams(id),  -- nullable: cruces de elim. directa
  team_b_id int references teams(id),  -- se completan al avanzar la fase
  kickoff_at timestamptz not null,
  venue text,
  score_a int,
  score_b int,
  finalized_at timestamptz,
  created_at timestamptz not null default now()
);

create index idx_matches_kickoff on matches(kickoff_at);
```

**Notas:**
- En partidos de elim. directa los equipos pueden quedar `null` hasta que se definan. Las predicciones para esos partidos se manejan distinto (ver más abajo).
- `finalized_at` se setea al cargar el resultado oficial. Dispara el trigger de cálculo de puntajes.

**RLS:** SELECT público, INSERT/UPDATE/DELETE solo admin.

### `predictions`

```sql
create table predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  match_id int not null references matches(id) on delete cascade,
  pred_a int not null check (pred_a >= 0 and pred_a <= 20),
  pred_b int not null check (pred_b >= 0 and pred_b <= 20),
  points_awarded int,           -- null hasta que el match se finalice
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, match_id)
);

create index idx_predictions_match on predictions(match_id);
create index idx_predictions_user on predictions(user_id);
```

**RLS (críticas):**
- SELECT: el usuario ve siempre las suyas. Las de otros usuarios solo si `match.kickoff_at <= now()` (para no spoilear estrategias).
- INSERT/UPDATE: solo si `match.kickoff_at > now()` Y `auth.uid() = user_id`. Esto cierra la predicción al kickoff.
- DELETE: bloqueado siempre. Si querés "borrar" la predicción, actualizá los goles.

### `bonus_predictions`

```sql
create table bonus_predictions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  champion_team_id int references teams(id),
  runner_up_team_id int references teams(id),
  top_scorer_name text,         -- texto libre, validación manual al final
  semifinalist_1 int references teams(id),
  semifinalist_2 int references teams(id),
  semifinalist_3 int references teams(id),
  semifinalist_4 int references teams(id),
  points_awarded int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

**RLS:**
- SELECT: solo el propio dueño hasta el kickoff inaugural. Después, todos ven todo.
- INSERT/UPDATE: solo el propio dueño Y solo si `now() < <fecha kickoff inaugural>`. La fecha se hardcodea en la policy o se guarda en una tabla de config.

### `result_changes_log`

Auditoría obligatoria por la plata en juego.

```sql
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
```

**RLS:** SELECT solo admin, INSERT vía trigger, UPDATE/DELETE bloqueados.

### `app_config`

Singleton de configuración. Una sola fila.

```sql
create table app_config (
  id int primary key default 1 check (id = 1),
  tournament_start_at timestamptz not null, -- kickoff inaugural
  bonus_lock_at timestamptz not null,       -- cuándo se cierran los bonus
  rules_locked boolean not null default false,
  scoring_rules jsonb not null              -- las reglas exactas (ver doc 04)
);
```

## Funciones y triggers

### `handle_new_user()`

Trigger en `auth.users` AFTER INSERT. Crea fila en `profiles` con alias = parte local del email.

### `calculate_match_points(match_id int)`

Función que recalcula `points_awarded` de todas las predicciones de un partido.
Llamada por trigger AFTER UPDATE OF `finalized_at` en `matches`.

Pseudocódigo:

```
1. Obtener score real del match
2. Para cada predicción del match:
   - Si pred_a = score_a AND pred_b = score_b: puntos exactos
   - Sino si ganador acertado AND diferencia de goles acertada: puntos parciales 1
   - Sino si ganador acertado o empate acertado: puntos parciales 2
   - Sino: 0 puntos
   - Aplicar multiplicador según stage
3. UPDATE predictions SET points_awarded = ...
```

### `recalculate_bonus_points()`

Función para invocar al terminar el torneo. Solo admin.

## Vista materializada (opcional)

Para el ranking, se puede usar una vista normal:

```sql
create view ranking as
select
  p.id,
  p.alias,
  p.avatar_url,
  coalesce(sum(pr.points_awarded), 0) + coalesce(bp.points_awarded, 0) as total_points
from profiles p
left join predictions pr on pr.user_id = p.id
left join bonus_predictions bp on bp.user_id = p.id
group by p.id, p.alias, p.avatar_url, bp.points_awarded
order by total_points desc;
```

Si hay performance issues (no debería con 20 usuarios), pasar a materialized view + refresh post-trigger.

## Datos de seed

- 48 selecciones (los 48 clasificados al Mundial 2026, a confirmar fixture oficial FIFA).
- 104 matches con horarios en UTC (a cargar manualmente desde fuente oficial).
- 1 fila en `app_config`.
