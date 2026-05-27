# 02 — Arquitectura

## Diagrama de alto nivel

```
┌─────────────────────────────────────────┐
│  Cliente (PWA en mobile/desktop)        │
│  Next.js App Router + React + TW        │
└────────────────┬────────────────────────┘
                 │ HTTPS
                 ▼
┌─────────────────────────────────────────┐
│  Vercel Edge / Node Runtime             │
│  - Server Components                    │
│  - Server Actions (mutaciones)          │
│  - Route Handlers (webhooks si hace falta)│
└────────────────┬────────────────────────┘
                 │ Postgres wire protocol + REST
                 ▼
┌─────────────────────────────────────────┐
│  Supabase                               │
│  - Postgres con RLS                     │
│  - Auth (magic link)                    │
│  - Realtime (opcional, V2)              │
└─────────────────────────────────────────┘
```

## Capas

### Frontend (Next.js App Router)

- **Server Components por defecto.** Todo lo que se pueda renderizar en server, se renderiza en server. Menos JS al cliente.
- **Client Components solo donde hay interactividad real:** forms con validación en vivo, countdown timers, toggles.
- **Server Actions** para mutaciones (cargar predicción, cargar resultado, etc). No se exponen rutas REST custom.
- **Routing:**
  - `/` — landing + login
  - `/dashboard` — overview con próximos partidos y ranking
  - `/partidos` — listado completo del fixture
  - `/partidos/[id]` — detalle de partido + predicción
  - `/bonus` — predicciones de bonus (campeón, etc)
  - `/ranking` — tabla general
  - `/usuarios/[id]` — vista de predicciones de un usuario (post-kickoff)
  - `/admin/*` — solo accesible para admins

### Backend (Supabase)

- **Auth:** magic link por email. No password, no OAuth en V1.
- **DB:** Postgres con Row Level Security activa en todas las tablas.
- **Lógica de puntajes:** función Postgres (`calculate_match_points`) llamada por trigger cuando se finaliza un partido. Esto garantiza que el puntaje se calcula en server, no en cliente.
- **Cierre de predicciones:** RLS policy que rechaza UPDATE/INSERT en `predictions` si `match.kickoff_at <= now()`.

### Hosting

- **Vercel** para el frontend. Conectado a GitHub, deploy automático en push a `main`.
- **Supabase** para DB + Auth. Free tier alcanza para 20 usuarios.
- **Dominio:** a definir. Mientras tanto se usa el `*.vercel.app` autogenerado.

## Decisiones clave (resumen)

Para detalle, ver `docs/decisions/`.

| Decisión | Resumen |
|---|---|
| PWA vs nativa | PWA. Distribución por link, deploy instantáneo. |
| Stack | Next.js + Supabase. Conocido, integrado, free tier suficiente. |
| Cálculo de puntajes | En Postgres (función + trigger). Garantía de integridad. |
| Carga de resultados | Manual por admin. APIs gratuitas son inconsistentes. |
| Estado cliente | Mínimo. RSC + Server Actions. Sin Redux, Zustand, Jotai. |
| Tests | Vitest para lógica de puntaje y validaciones críticas. UI sin tests E2E en V1. |

## Estructura de carpetas del código

```
src/
├── app/                    # App Router de Next
│   ├── (auth)/             # Routes públicas (login, callback)
│   ├── (app)/              # Routes autenticadas
│   │   ├── partidos/
│   │   ├── bonus/
│   │   ├── ranking/
│   │   └── layout.tsx      # Verifica auth
│   ├── admin/              # Admin-only
│   └── api/                # Solo route handlers necesarios
├── components/
│   ├── ui/                 # shadcn components
│   └── domain/             # Componentes del dominio (PredictionCard, etc)
├── lib/
│   ├── supabase/           # Cliente, server, middleware
│   ├── scoring/            # Lógica de puntaje (espejo del de Postgres, para tests)
│   └── utils/
├── server-actions/         # Server actions, una por archivo
└── types/                  # Tipos TS compartidos
```

## Convenciones de código

- TypeScript estricto (`strict: true`).
- Validación de inputs en server actions con **Zod**.
- Errores devueltos al cliente como `{ error: string }`, mensaje en español.
- Imports absolutos con `@/` (configurado en `tsconfig.json`).
- Componentes en PascalCase, archivos en kebab-case.
- Server actions: nombre del archivo = nombre de la acción. Ej: `submit-prediction.ts`.
