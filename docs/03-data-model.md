# 03 — Modelo de datos

> **Última migración alineada:** `supabase/migrations/20260528022319_initial_schema.sql` (T-009, 2026-05-28). Cualquier divergencia entre este doc y el SQL aplicado es un bug — alinear ambos en la misma pasada.

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

**Trigger `log_result_change` (AFTER UPDATE OF `score_a`, `score_b` en `matches`):** inserta una fila acá cada vez que cambia un score, leyendo `changed_by` desde `auth.uid()`. Si la sesión que ejecuta el UPDATE no tiene un user autenticado (ej: queries directas con rol `postgres` desde el SQL editor del dashboard), el trigger **rechaza el cambio con `raise exception`**. Es intencional: no hay cambios de resultado sin auditoría. Para correcciones excepcionales sin sesión hay que usar el service role.

### `app_config`

Singleton de configuración. Una sola fila.

```sql
create table app_config (
  id int primary key default 1 check (id = 1),
  tournament_start_at timestamptz not null, -- kickoff inaugural
  bonus_lock_at timestamptz not null,       -- cuándo se cierran los bonus
  rules_locked boolean not null default false,
  scoring_rules jsonb not null              -- shape detallado abajo (ver doc 04)
);
```

**Shape de `scoring_rules`** (la función `calculate_match_points` y el código TS lo asumen exactamente así):

```jsonc
{
  "match_points": {
    "exact": 5,           // pred exacto
    "winner_and_diff": 3, // misma diferencia de goles (incluye ganador acertado)
    "winner_or_draw": 2,  // mismo signo (ganador o empate acertado, sin diff exacta)
    "none": 0
  },
  "stage_multipliers": {
    "group": 1.0, "r32": 1.0, "r16": 1.5,
    "quarter": 2.0, "semi": 2.5, "third": 1.5, "final": 3.0
  },
  "bonus_points": {
    "champion": 20,
    "runner_up": 10,
    "top_scorer": 15,
    "semifinalist_each": 5   // hasta 4 semifinalistas → máximo 20
  }
}
```

**RLS:** SELECT autenticado, INSERT/UPDATE/DELETE solo admin.

## Funciones y triggers

### `is_admin(uid uuid) → boolean`

Helper SQL con `security definer` y `search_path = public`. Devuelve `profiles.is_admin` del usuario dado, o `false` si no existe. Centraliza el check de admin en las policies (`teams_admin_cud`, `matches_admin_cud`, `app_config_admin_cud`, `result_changes_log_select_admin`) y evita recursión en las policies de la propia `profiles`.

### `handle_new_user()`

Trigger en `auth.users` AFTER INSERT. Crea fila en `profiles` con `alias = split_part(email, '@', 1)`. El alias lo puede editar el usuario después.

### `set_updated_at()`

Trigger genérico BEFORE UPDATE en `predictions` y `bonus_predictions`. Reescribe `updated_at = now()` en cada update. Necesario para honrar la regla del CLAUDE.md: "timestamps inmutables, no se borran ni al editarlas" — sin este trigger, `updated_at` quedaría como `created_at` salvo que el código TS lo seteara explícitamente cada vez.

### `calculate_match_points(match_id int)`

Función que recalcula `points_awarded` de todas las predicciones de un partido. Lee puntos base + multiplicadores desde `app_config.scoring_rules` (jsonb).

**Trigger `on_match_result_set`:** AFTER UPDATE OF `score_a`, `score_b`, **`finalized_at`** en `matches`. Escucha las 3 columnas (no solo `finalized_at`) para que cualquier corrección posterior de un resultado dispare el recálculo automático. Alineado con doc 04: "si un resultado se carga mal y se corrige, los puntajes se recalculan para todos".

Pseudocódigo:

```
1. Obtener score y stage del match. Si score es null, return (no hay resultado todavía).
2. Leer puntos base + multiplicador del stage desde app_config.scoring_rules.
3. Para cada predicción del match:
   - Si pred_a = score_a AND pred_b = score_b: puntos exactos
   - Sino si (pred_a - pred_b) = (score_a - score_b): puntos winner_and_diff
   - Sino si sign(pred_a - pred_b) = sign(score_a - score_b): puntos winner_or_draw
   - Sino: 0 puntos
   - Multiplicar por multiplicador del stage. Round half-up al int más cercano
     (5 pts × 1.5 = 7.5 → 8).
4. UPDATE predictions SET points_awarded = ...
```

### `recalculate_bonus_points()`

**Stub hasta T-017+.** Firma declarada (`returns void`, body vacío) para que la API quede establecida desde la migración inicial. La lógica real (cálculo de puntos por campeón / subcampeón / goleador / semifinalistas, con los puntajes del doc 04) se implementa cuando aterricen los bonus y al cierre del torneo. Invocación manual por admin al terminar el Mundial.

## Vista `ranking`

```sql
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
```

- `security_invoker = true` (PG15+): la view se ejecuta con permisos del caller, respetando las RLS policies de las tablas subyacentes.
- `max(bp.points_awarded)` en vez de incluir esa columna en el GROUP BY: equivalente porque `bonus_predictions.user_id` es PK (hay 0 o 1 fila por user), pero más limpio.

Si en algún momento hay problemas de performance (no debería con ~20 usuarios), pasar a materialized view + refresh post-trigger.

## Datos de seed

- 48 selecciones (los 48 clasificados al Mundial 2026, a confirmar fixture oficial FIFA).
- 104 matches con horarios en UTC (a cargar manualmente desde fuente oficial).
- 1 fila en `app_config`.
