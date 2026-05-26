# Prode Mundial 2026 — Documento de Requerimientos

**Autor:** Rami
**Fecha:** 26 de mayo de 2026
**Deadline:** 11 de junio de 2026 (partido inaugural)
**Días hábiles disponibles:** 16

---

## 1. Visión y alcance

Aplicación web (PWA) para que un grupo cerrado de 10–20 amigos realicen un prode híbrido del Mundial 2026. Cada usuario predice resultados de partidos y bonus (campeón, goleador, etc.); la app calcula puntajes automáticamente al cargarse los resultados reales y muestra ranking en tiempo real.

**No es alcance de esta primera versión:**

- Cobro/pago del pozo dentro de la app (se gestiona fuera, en una planilla aparte).
- Soporte multi-torneo o multi-liga.
- App nativa en App Store o Google Play.
- Onboarding público (es invite-only).
- Chat o foro interno.

---

## 2. Decisiones de producto ya tomadas

| Decisión | Elección | Motivo |
|---|---|---|
| Plataforma | Web app instalable (PWA) | Cero fricción de distribución, deploy instantáneo, un solo codebase |
| Modelo de prode | Híbrido: partidos + bonus | Mantiene a todos enganchados aunque pifien la fase de grupos |
| Pozo | Sí, gestionado fuera de la app | Evita complejidad legal/regulatoria de pagos |
| Acceso | Invite-only | Es un grupo de amigos, no producto masivo |

---

## 3. Requerimientos funcionales

### 3.1 Autenticación y usuarios

- RF-01: Login con magic link por email (Supabase Auth lo provee de fábrica).
- RF-02: Acceso solo para usuarios invitados previamente (lista blanca de emails, cargada por el admin).
- RF-03: Cada usuario tiene perfil con: nombre visible (alias), avatar (opcional, default genérico), email (no público).
- RF-04: El admin (Rami) tiene un rol diferenciado que le permite cargar resultados reales y gestionar el grupo.

### 3.2 Predicciones de partidos

- RF-05: La app muestra el fixture completo del Mundial (104 partidos: 72 de fase de grupos + 32 de eliminación directa).
- RF-06: El usuario predice para cada partido: goles del equipo A, goles del equipo B.
- RF-07: Las predicciones se pueden editar libremente hasta el momento del kickoff de cada partido.
- RF-08: Una vez iniciado el partido, la predicción queda congelada (read-only). No se aceptan submissions tardías.
- RF-09: Si el usuario no predijo un partido antes del kickoff, se considera "no pronosticado" y suma 0 puntos por ese partido.
- RF-10: La app muestra countdown al cierre de cada partido para evitar que los usuarios se olviden.
- RF-11: Toda predicción se guarda con timestamp inmutable para trazabilidad (importante: hay plata en juego).

### 3.3 Predicciones de bonus (largo plazo)

Estas predicciones se cargan **antes** del partido inaugural y no se pueden modificar una vez iniciado el torneo.

- RF-12: Campeón del Mundial.
- RF-13: Subcampeón (finalista perdedor).
- RF-14: Goleador del torneo.
- RF-15: Las 4 selecciones que llegan a semifinales (sin orden).
- RF-16: Deadline duro: 11/06/2026 a las 19:00 ART (kickoff del partido inaugural). Después de eso, los bonus quedan congelados aunque el usuario no los haya cargado.

### 3.4 Sistema de puntajes (a confirmar con el grupo)

Propuesta base, ajustable antes del 11/6:

**Partidos de fase de grupos:**
- Acertar resultado exacto: **5 puntos**
- Acertar ganador/empate + diferencia de goles: **3 puntos**
- Acertar solo ganador/empate: **2 puntos**
- No acertar: 0 puntos

**Partidos de eliminación directa (octavos en adelante):**
- Mismos puntos pero multiplicados ×1.5 (octavos), ×2 (cuartos), ×2.5 (semis), ×3 (final).
- En partidos definidos por penales, vale el resultado al final de los 90/120 min (no se cuenta la tanda).

**Bonus:**
- Campeón: 20 puntos
- Subcampeón: 10 puntos
- Goleador: 15 puntos
- Cada semifinalista acertado: 5 puntos (máximo 20)

- RF-17: Las reglas del puntaje deben estar visibles en una pantalla "Reglas" dentro de la app, congeladas antes del kickoff inaugural.
- RF-18: El cálculo de puntajes se ejecuta automáticamente al cargar un resultado oficial.

### 3.5 Resultados oficiales

- RF-19: El admin carga el resultado oficial de cada partido manualmente (decisión confirmada más abajo).
- RF-20: Al cargar un resultado, la app recalcula los puntajes de todos los usuarios para ese partido.
- RF-21: Se puede editar un resultado en caso de error de carga (con confirmación + log de la corrección).

### 3.6 Ranking y visualización

- RF-22: Ranking general visible para todos los usuarios, ordenado por puntaje total descendente.
- RF-23: Cada fila del ranking muestra: posición, alias, puntaje total, variación desde la última actualización (+5 desde ayer, etc.).
- RF-24: Vista de detalle por usuario: ver sus predicciones pasadas y los puntos que obtuvo cada una.
- RF-25: Vista por partido: ver qué predijo cada usuario para ese partido (visible solo después del kickoff, no antes — para no spoilear estrategias).
- RF-26: Pantalla de "próximos partidos" con countdown y acceso rápido a cargar predicciones pendientes.

### 3.7 Panel admin (Rami)

- RF-27: Cargar/editar resultados de partidos.
- RF-28: Invitar usuarios (agregar email a la lista blanca).
- RF-29: Ver auditoría de cambios (qué resultados editó, cuándo).
- RF-30: Forzar recálculo de puntajes (botón de emergencia por si algo se desincroniza).

---

## 4. Requerimientos no funcionales

- RNF-01: La app debe funcionar bien en mobile (es donde el 95% va a entrar). Mobile-first en el diseño.
- RNF-02: Instalable como PWA en iOS y Android ("Agregar a pantalla de inicio").
- RNF-03: Tiempo de carga de pantalla principal < 2 segundos en 4G.
- RNF-04: Soporta hasta 50 usuarios concurrentes sin degradación (margen amplio vs. los 20 reales).
- RNF-05: Estado de las predicciones se persiste en backend (Supabase). Nada vive solo en localStorage.
- RNF-06: Costo operativo total ≤ USD 5/mes (free tier de Supabase + Vercel cubre todo).
- RNF-07: Idioma: español (rioplatense). Sin internacionalización en V1.
- RNF-08: Las predicciones tienen integridad transaccional: si falla el guardado, el usuario ve error claro y reintenta.

---

## 5. Stack tecnológico recomendado

| Capa | Elección | Por qué |
|---|---|---|
| Frontend | Next.js 14 (App Router) + React | Lo conocés, SSR/ISR, deploy en Vercel en un click |
| Estilos | Tailwind CSS + shadcn/ui | Componentes accesibles y configurables, te ahorra días de UI |
| Backend / DB | Supabase (Postgres + Auth + RLS) | Free tier sobra, Auth con magic link de fábrica, sin escribir API REST |
| Hosting | Vercel | Ya lo configuraste para Bruma, deploy directo desde GitHub |
| State | React Server Components + Server Actions | Menos código de fetching, valida en server, simpler |
| Realtime (opcional) | Supabase Realtime | Ranking se actualiza solo cuando cargás un resultado |
| Notificaciones (opcional, fuera de scope V1) | Grupo de WhatsApp manual | No invertir en push para V1 |

**Justificación de no usar:**
- React Native / Expo: no hace falta y suma 5 días de configuración mínimo.
- Backend custom (Express/Nest): Supabase resuelve auth, DB y RLS sin código.
- Firebase: viable pero el modelo NoSQL es peor para ranking con joins, y RLS de Supabase es más claro.

---

## 6. Modelo de datos (Postgres)

```sql
-- Usuarios (extiende auth.users de Supabase)
profiles (
  id uuid PK (FK a auth.users),
  alias text,
  avatar_url text,
  is_admin boolean default false,
  created_at timestamptz
)

-- Selecciones del Mundial
teams (
  id serial PK,
  name text,                -- "Argentina"
  code text,                -- "ARG"
  group_letter char(1)      -- 'A', 'B', etc.
)

-- Fixture
matches (
  id serial PK,
  team_a_id int FK,
  team_b_id int FK,
  stage text,               -- 'group' | 'r32' | 'r16' | 'quarter' | 'semi' | 'final' | 'third'
  kickoff_at timestamptz,   -- UTC
  venue text,
  -- Resultados (null hasta que se cargan)
  score_a int,
  score_b int,
  finalized_at timestamptz
)

-- Predicciones de partido
predictions (
  id uuid PK,
  user_id uuid FK,
  match_id int FK,
  pred_a int,
  pred_b int,
  points_awarded int,       -- se llena al finalizar el partido
  created_at timestamptz,
  updated_at timestamptz,
  UNIQUE(user_id, match_id)
)

-- Predicciones de bonus
bonus_predictions (
  user_id uuid PK,
  champion_team_id int,
  runner_up_team_id int,
  top_scorer_name text,     -- texto libre, validado al final
  semifinalist_1 int,
  semifinalist_2 int,
  semifinalist_3 int,
  semifinalist_4 int,
  points_awarded int,
  locked_at timestamptz     -- timestamp del kickoff inaugural
)

-- Auditoría de cambios de resultados (importante con plata en juego)
result_changes_log (
  id serial PK,
  match_id int FK,
  old_score_a int, old_score_b int,
  new_score_a int, new_score_b int,
  changed_by uuid FK,
  changed_at timestamptz,
  reason text
)
```

**Row Level Security (RLS):**
- `predictions`: usuario solo ve/edita las suyas hasta kickoff; después de kickoff todos pueden leer las de todos.
- `matches`: lectura pública, escritura solo admin.
- `profiles`: lectura pública (alias, avatar), escritura solo el propio dueño.

---

## 7. Resultados oficiales: cómo se cargan

**Decisión recomendada: carga manual por el admin.**

Razones:
- Las APIs de fútbol gratuitas son inconsistentes (lag de minutos, errores ocasionales).
- 104 partidos en 39 días = en promedio menos de 3 por día. Te toma 30 segundos cargar cada uno desde el panel admin.
- Eliminás dependencia externa y rate limits.
- Si querés automatizarlo en V2, [football-data.org](https://www.football-data.org/) tiene tier gratuito con el Mundial cubierto.

**Workflow:** termina el partido → abrís el panel admin desde el celular → input de score → guardás → Supabase recalcula puntajes vía función Postgres → ranking se actualiza para todos.

---

## 8. Roadmap día por día (16 días)

### Semana 1 — Fundamentos (26/5 al 1/6)

- **Día 1–2 (mar 26 – mié 27):** Setup repo, Next.js + Supabase + Tailwind + shadcn. Auth con magic link funcionando. Deploy en Vercel con dominio.
- **Día 3 (jue 28):** Modelo de datos en Supabase. Seed del fixture completo (104 partidos, 48 equipos, fechas UTC). Esto lo conseguís de [FIFA.com](https://www.fifa.com/) o Wikipedia.
- **Día 4 (vie 29):** Listado de partidos + filtros por fecha/fase. Mobile-first.
- **Día 5–6 (sáb 30 – dom 31):** Pantalla de carga de predicciones, con validación de kickoff. Server actions para guardar. Esto es el corazón de la app.
- **Día 7 (lun 1):** Bonus predictions UI + lock al deadline.

### Semana 2 — Lógica y panel admin (2/6 al 8/6)

- **Día 8 (mar 2):** Función Postgres de cálculo de puntajes. Test con datos sintéticos.
- **Día 9 (mié 3):** Panel admin: carga de resultados + trigger de recálculo.
- **Día 10 (jue 4):** Ranking general + vista de detalle por usuario.
- **Día 11 (vie 5):** Vista por partido (qué predijo cada uno, post-kickoff).
- **Día 12 (sáb 6):** PWA setup (manifest, service worker, ícono). Test instalación en iOS y Android.
- **Día 13 (dom 7):** UX polish: countdowns, estados vacíos, errores, loading.
- **Día 14 (lun 8):** Pantalla de Reglas + Términos del prode visibles.

### Recta final (9/6 al 11/6)

- **Día 15 (mar 9):** Beta testing con 2-3 amigos. Caza de bugs.
- **Día 16 (mié 10):** Fixes finales. Invitar a todos los amigos. Cargar bonus predictions.
- **Día 17 (jue 11):** 🎉 Kickoff del Mundial. Lock de bonus a las 19:00 ART. Carga de resultado del primer partido.

**Buffer:** 0. Si te atrasás un día, recortás de la lista de "scope a recortar" abajo.

---

## 9. Scope a recortar si vas atrasado (en este orden)

1. **Realtime updates.** Que el ranking se actualice al refrescar la página, no al instante.
2. **Vista de detalle por usuario.** Solo muestra ranking general en V1.
3. **Auditoría de cambios.** Confías en vos mismo como admin y log a mano en un Notion.
4. **Avatares.** Iniciales del alias y listo.
5. **Bonus de semifinalistas.** Quedate solo con campeón + goleador.
6. **PWA installable.** Que sea solo web responsive sin manifest. Tus amigos abren el link y listo.

**No recortar bajo ninguna circunstancia:**
- Lock de predicciones al kickoff (sin esto, alguien puede cargar predicción 5 minutos después del primer gol).
- Timestamp inmutable de predicciones (con plata en juego es no negociable).
- Pantalla de reglas visible antes del torneo.

---

## 10. Riesgos identificados

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Bug en cálculo de puntajes con plata en juego | Media | Alto | Tests unitarios de la función de puntaje + revisión manual de los primeros 5 partidos |
| Alguien carga predicción después del kickoff por bug | Baja | Alto | Validación en server (no solo en cliente) + RLS en Postgres |
| Vos no llegás al 11/6 | Media | Alto | Lista de recorte de scope arriba |
| Discusiones en el grupo por reglas ambiguas | Alta | Medio | Reglas escritas y aprobadas por todos antes del 11/6 |
| Alguien pierde acceso a su email | Baja | Bajo | Magic link puede reenviarse, en peor caso admin invita con otro email |

---

## 11. Decisiones pendientes (a resolver antes del 11/6)

- [ ] Validar el sistema de puntajes con el grupo. Que voten o aprueben.
- [ ] Definir entrada del pozo y mecanismo de cobro (fuera de la app).
- [ ] Definir desempate en caso de empate en el ranking final.
- [ ] Nombre y dominio de la app. Algunas opciones: `prode26.app`, `elprode.ar`, `prodemundial.com`.
- [ ] Logo (¿colaboración con Agustina?).

---

## 12. Próximos pasos inmediatos

1. Aprobar este documento.
2. Crear repo en GitHub y proyecto en Supabase + Vercel hoy mismo.
3. Conseguir el fixture oficial del Mundial 2026 (lo busco yo cuando arranquemos).
4. Mandarle al grupo de WhatsApp el sistema de puntajes propuesto y esperar feedback antes del jueves.
