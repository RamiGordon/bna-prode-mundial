# ADR 0001 — Stack: Next.js + Supabase + Vercel

**Estado:** Aceptada
**Fecha:** 2026-05-26

## Contexto

Hay que elegir stack para una PWA de prode con deadline duro a 16 días, construida por una sola persona en nights/weekends.

## Decisión

- **Frontend:** Next.js (latest stable, App Router), TypeScript estricto, Tailwind + shadcn/ui.
- **Backend/DB:** Supabase (Postgres + Auth + RLS).
- **Hosting:** Vercel.

## Alternativas consideradas

### Backend custom (Express + Postgres + JWT)
- Pro: control total.
- Contra: 3-5 días extra solo en auth y boilerplate. No vale la pena para 20 usuarios.
- **Descartada.**

### Firebase
- Pro: maduro, conocido.
- Contra: modelo NoSQL incómodo para ranking con joins. RLS en Firestore es menos claro que en Postgres.
- **Descartada.**

### Remix + Supabase
- Pro: Remix es excelente para data loading.
- Contra: Rami no la usa habitualmente. Curva de aprendizaje en proyecto con deadline.
- **Descartada.**

### Astro + Supabase
- Pro: muy rápido.
- Contra: menos maduro en interactividad compleja como forms con state.
- **Descartada.**

## Consecuencias

### Positivas
- Free tier de Supabase + Vercel cubre el proyecto sin costo.
- Auth con magic link sin código adicional.
- RLS de Postgres garantiza seguridad de las predicciones (lock al kickoff).
- Deploy automático en push a `main`.
- Stack que Rami ya usa, no hay curva de aprendizaje.

### Negativas
- Dependencia de servicios externos (Vercel, Supabase). Si caen, cae la app.
- Vendor lock-in moderado en Supabase Auth.
- Free tier puede tener cold starts ocasionales.

## Mitigaciones

- Backups regulares de la DB de Supabase (export semanal en SQL).
- Documentar bien las decisiones que dependen de Supabase para facilitar migración si algún día hace falta.

## Notas

- **2026-05-26 (T-004):** El scaffold se hizo con Next.js 16.2.6 (latest stable al momento), React 19.2.4, Tailwind v4. La decisión original mencionaba "Next.js 14" pero se actualizó a "latest stable" para no quedar pegados a una versión específica durante el desarrollo activo.
