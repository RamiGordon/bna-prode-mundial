# T-004 — Inicializar Next.js (App Router, latest) con TypeScript, Tailwind, ESLint y shadcn/ui base

**Sesión:** 2026-05-26
**Estado:** in-progress
**Inicio:** —

## Objetivo

Scaffold de Next.js latest con App Router, TypeScript estricto, Tailwind y ESLint sobre el repo actual, con `src/`, sin romper `docs/`, `tasks/`, `CLAUDE.md` ni `README.md`. Inicializar shadcn/ui con defaults (slate, CSS variables) sin instalar componentes. Pinear versión de Node con `.nvmrc`. Dejar el primer deploy verde en Vercel y actualizar todas las referencias en docs de "Next.js 14" a la versión latest.

## Plan

1. Instalar nvm vía Homebrew (lo corre Rami con `!`) y dejar `lts/*` como default.
2. Crear `.nvmrc` con el major LTS instalado.
3. Mergear `.gitignore` después del scaffold para no perder `.claude-workflow/` y `.env`.
4. `npx create-next-app@latest . --ts --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm`.
5. Endurecer `tsconfig.json` (`strict: true`, `noUncheckedIndexedAccess: true`).
6. `npm run build` local para verificar.
7. `npx shadcn@latest init` con slate + CSS variables + `@/components` + `@/lib/utils`, sin componentes.
8. Actualizar 9 referencias a "Next.js 14" en `CLAUDE.md`, `README.md`, `docs/01-requirements.md`, `docs/02-architecture.md` (x2), `docs/05-roadmap.md`, `docs/decisions/0001-stack-supabase-vercel-nextjs.md`, `tasks/backlog.md`, `tasks/in-progress.md`.
9. Commits atómicos: `.nvmrc`, scaffold, shadcn init, docs update.
10. Push a `main` y verificar deploy verde en Vercel.
11. Configurar versión de Node en Vercel (Project Settings).
12. Cerrar tarea: mover a `done.md` y dejar `in-progress.md` apuntando a T-005.

## Criterios de aceptación

- [ ] `.nvmrc` commiteado con LTS major.
- [ ] `npm run build` corre sin errores local.
- [ ] `tsconfig.json` con `"strict": true` y `"noUncheckedIndexedAccess": true`.
- [ ] `components.json` de shadcn creado, sin componentes instalados.
- [ ] Cero referencias a "Next.js 14" en el repo (verificado con grep).
- [ ] Deploy verde en Vercel para el último commit en `main`.
- [ ] `docs/`, `tasks/`, `CLAUDE.md`, `README.md` intactos en su contenido propio (sólo cambian las líneas de "Next.js 14").

## Fuera de scope

- Variables de entorno / conexión a Supabase → T-005.
- Componentes shadcn concretos (Button, Input, etc.) → cuando los pida la feature que los necesite.
- Auth, middleware, layout → T-006/T-007/T-008.
- Código de dominio (predicciones, partidos, ranking).

## Notas durante la ejecución

(se completa conforme avanza)
