# Backlog

Tareas pendientes ordenadas por prioridad. Cuando se arranca una, se mueve a `in-progress.md` con todo el detalle. Cuando se termina, a `done.md`.

## Sesión 1 — Setup inicial (Día 1, hoy)

- [x] **T-001** Crear repo en GitHub e inicializarlo localmente
- [x] **T-002** Crear proyecto en Supabase (free tier) y obtener credenciales
- [x] **T-003** Crear proyecto en Vercel y conectarlo al repo de GitHub
- [ ] **T-004** Inicializar Next.js 14 con App Router, TypeScript estricto, Tailwind, shadcn/ui base
- [ ] **T-005** Configurar `.env.local` y `.env.example` con variables de Supabase

## Sesión 2 — Auth y navegación (Día 2)

- [ ] **T-006** Implementar auth con Supabase magic link (login + callback + logout)
- [ ] **T-007** Middleware de Next que protege rutas autenticadas
- [ ] **T-008** Layout base con navegación mobile-first (bottom nav o drawer)

## Sesión 3 — Schema de datos (Día 3)

- [ ] **T-009** Migraciones SQL: tablas + RLS + triggers según `docs/03-data-model.md`
- [ ] **T-010** Seed de 48 selecciones del Mundial 2026
- [ ] **T-011** Seed de 104 partidos con fixture oficial FIFA (fechas en UTC)

## Sesión 4 — Vistas de partidos (Día 4)

- [ ] **T-012** Página de listado de partidos con filtros por día y por fase
- [ ] **T-013** Página de detalle de partido (sin form de predicción todavía)

## Sesiones 5-6 — Predicciones (Días 5-6)

- [ ] **T-014** Form de predicción con validación en server action y Zod
- [ ] **T-015** Verificar que RLS y server action rechazan submission post-kickoff
- [ ] **T-016** Página "mis predicciones" con countdown a cierre

## Sesión 7 — Bonus (Día 7)

- [ ] **T-017** Form de bonus predictions (campeón, subcampeón, goleador, semifinalistas)
- [ ] **T-018** Lock server-side de bonus al timestamp configurado
- [ ] **T-019** Pantalla "bonus cargados" + edición permitida hasta deadline

## Sesión 8 — Lógica de puntaje (Día 8)

- [ ] **T-020** Función Postgres `calculate_match_points(match_id int)`
- [ ] **T-021** Trigger AFTER UPDATE en matches.finalized_at
- [ ] **T-022** Tests unitarios de la lógica (espejo en TypeScript + Vitest)

## Sesión 9 — Admin (Día 9)

- [ ] **T-023** Página `/admin/matches` con lista de partidos
- [ ] **T-024** Form de carga de resultado con confirmación de doble click
- [ ] **T-025** Auditoría visible de cambios de resultado

## Sesión 10 — Ranking (Día 10)

- [ ] **T-026** Página de ranking general con paginación
- [ ] **T-027** Indicador de variación desde última visita

## Sesión 11 — Vistas sociales (Día 11)

- [ ] **T-028** Página `/usuarios/[id]` con predicciones del usuario (solo post-kickoff)
- [ ] **T-029** Vista "qué predijo cada uno" en detalle de partido

## Sesión 12 — PWA (Día 12)

- [ ] **T-030** Configurar manifest.json
- [ ] **T-031** Generar íconos en todos los tamaños (Bruma puede ayudar)
- [ ] **T-032** Service worker básico (next-pwa)
- [ ] **T-033** Test de instalación en iOS y Android

## Sesión 13 — Polish (Día 13)

- [ ] **T-034** Empty states y loading states en todas las pantallas
- [ ] **T-035** Mensajes de error en español rioplatense

## Sesión 14 — Onboarding (Día 14)

- [ ] **T-036** Pantalla de Reglas (renderiza el contenido de `docs/04-scoring-rules.md`)
- [ ] **T-037** Pantalla "Cómo funciona"

## Sesión 15-16 — Beta y lanzamiento (Días 15-16)

- [ ] **T-038** Beta testing con 2-3 amigos
- [ ] **T-039** Fix de bugs reportados
- [ ] **T-040** Mandar invitaciones al grupo completo
- [ ] **T-041** Recordatorio para cargar bonus

## Día del Mundial (Día 17)

- [ ] **T-042** Validar carga del primer resultado
- [ ] **T-043** Monitorear errores en logs de Vercel y Supabase

---

## Ideas / nice-to-have (V2, post-Mundial)

No tocar hasta que la V1 esté estable.

- Push notifications cuando arranca un partido
- Stats personales (% de aciertos, fortalezas/debilidades)
- Mini-ligas (subgrupos dentro del grupo)
- Modo "duelo" (predicciones cara a cara)
- Histórico de prodes anteriores
- Subir avatar real
- App nativa (React Native o similar)
