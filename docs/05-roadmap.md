# 05 — Roadmap día por día

Deadline: **11 de junio de 2026, 19:00 ART** (kickoff inaugural).
Punto de partida: martes 26 de mayo de 2026.
Régimen: nights/weekends, full-time en Mercado Libre durante el día.

## Semana 1 — Fundamentos (26/5 al 1/6)

### Día 1 — Martes 26/5 (HOY)
- T-001: Crear repo en GitHub
- T-002: Crear proyecto en Supabase
- T-003: Crear proyecto en Vercel + conectar a GitHub
- T-004: Inicializar Next.js (latest) con TypeScript + Tailwind + shadcn
- T-005: Configurar variables de entorno + .env.example

### Día 2 — Miércoles 27/5
- T-006: Auth con Supabase magic link funcionando end-to-end
- T-007: Middleware de protección de rutas autenticadas
- T-008: Layout base con navegación mobile-first

### Día 3 — Jueves 28/5
- T-009: Crear schema completo en Supabase (tablas + RLS + triggers)
- T-010: Seed de 48 selecciones del Mundial
- T-011: Seed de 104 partidos con fixture oficial

### Día 4 — Viernes 29/5
- T-012: Pantalla de listado de partidos con filtros por fecha/fase
- T-013: Vista de detalle de partido

### Día 5-6 — Sábado 30/5 y Domingo 31/5
- T-014: Form de predicción de partido (server action + Zod)
- T-015: Validación de cierre al kickoff (server-side y RLS)
- T-016: Listado de "mis predicciones"

### Día 7 — Lunes 1/6
- T-017: Form de bonus predictions
- T-018: Lock de bonus a fecha hardcodeada
- T-019: Pantalla de "ya cargaste tus bonus"

## Semana 2 — Lógica y admin (2/6 al 8/6)

### Día 8 — Martes 2/6
- T-020: Función Postgres `calculate_match_points`
- T-021: Trigger que dispara cálculo al finalizar match
- T-022: Tests unitarios de la lógica de puntaje (Vitest)

### Día 9 — Miércoles 3/6
- T-023: Panel admin: lista de partidos con botón "cargar resultado"
- T-024: Form de carga de resultado con confirmación
- T-025: Log automático de cambios

### Día 10 — Jueves 4/6
- T-026: Pantalla de ranking general
- T-027: Variación de puntos desde última visita

### Día 11 — Viernes 5/6
- T-028: Vista de perfil de usuario (predicciones post-kickoff)
- T-029: Vista "qué predijo cada uno" en detalle de partido

### Día 12 — Sábado 6/6
- T-030: PWA manifest + service worker
- T-031: Íconos en todos los tamaños
- T-032: Test de instalación en iOS y Android real

### Día 13 — Domingo 7/6
- T-033: UX polish: countdowns, loading states, empty states
- T-034: Mensajes de error en español, claros

### Día 14 — Lunes 8/6
- T-035: Pantalla de Reglas
- T-036: Pantalla "Cómo funciona" / onboarding

## Recta final (9/6 al 11/6)

### Día 15 — Martes 9/6
- T-037: Beta testing con 2-3 amigos
- T-038: Fix de bugs reportados

### Día 16 — Miércoles 10/6
- T-039: Fixes finales y polish
- T-040: Mandar invitaciones a todo el grupo
- T-041: Recordatorio para cargar bonus antes del 11/6 19:00

### Día 17 — Jueves 11/6
- 🎉 KICKOFF DEL MUNDIAL
- T-042: Cargar resultado del primer partido y validar que todo funcione

## Indicadores de alerta

Si alguno de estos se cumple, hay que recortar scope (ver `docs/01-requirements.md` sección 9):

- **Día 5 sin auth funcionando:** parar, debuggear, no avanzar.
- **Día 7 sin form de predicción funcionando end-to-end:** crítico. Es el core.
- **Día 10 sin cálculo de puntajes:** crítico. Recortar tests si hace falta.
- **Día 13 sin PWA instalable:** dejar como web responsive y avanzar.
