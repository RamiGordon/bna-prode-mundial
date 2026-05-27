# Tarea en progreso

⚠️ **Hay una sola tarea en progreso a la vez.** Si necesitás cambiar de tarea, primero terminá la actual o movela explícitamente al backlog.

---

# T-005 — Configurar `.env.local` y `.env.example` con variables de Supabase

**Sesión:** 2026-05-27
**Estado:** in-progress
**Inicio:** 13:12

## Objetivo

Dejar el contrato de variables de entorno explícito y versionado: `.env.example` commiteado con la lista de vars que necesita el proyecto (sin valores), y `.env.local` ignorado por git con los valores reales para desarrollo local. Las mismas 3 vars públicas de Supabase también se cargan en Vercel (lo hace Rami por fuera).

## Plan

1. Renombrar `.env` (que hoy hace de `.env.local` por accidente) → `.env.local` para alinearse con la convención de Next.js.
2. Ajustar `.gitignore`: la regla `.env*` actual también bloquea `.env.example`. Agregar `!.env.example` para permitir commitearlo.
3. Crear `.env.example` con las variables documentadas, placeholders, y comentarios que expliquen cuándo se usa cada una.
4. Verificar con `git status` que `.env.local` sigue ignorado y `.env.example` aparece como nuevo.
5. Commit del `.env.example` + ajuste de `.gitignore`.

## Criterios de aceptación

- [ ] `.env.local` existe localmente con valores reales y NO aparece en `git status`.
- [ ] `.env.example` está commiteado en `main` con la misma estructura que `.env.local` pero sin valores.
- [ ] `.gitignore` excluye `.env.local` pero permite `.env.example`.
- [ ] Variables documentadas (nombre + comentario corto explicando qué es y dónde se usa).
- [ ] Las 3 vars públicas (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `NEXT_SUPABASE_SECRET_KEY`) listas para que Rami las cargue en Vercel.

## Fuera de scope

- Crear el cliente Supabase (`createBrowserClient` / `createServerClient`). Eso va en T-006 junto con el flow de magic link.
- Cargar las vars en Vercel — lo hace Rami por dashboard, no podemos desde acá.
- Verificar la conexión real a Supabase. Sin código que las consuma, sólo validamos que estén bien escritas.
- Decidir entre Direct y Pooler para runtime en Vercel. Hoy no se usa `DATABASE_URL` desde Vercel, queda como decisión de T-009.

## Notas durante la ejecución

- Nomenclatura confirmada con Rami: usamos las **API keys nuevas de Supabase** (`sb_publishable_...` y `sb_secret_...`) en vez de las viejas (`anon` JWT / `service_role` JWT). Son revocables individualmente sin tirar abajo el JWT signing key del proyecto.
- `SUPA_REF` se mantiene en `.env.local`: lo usa la Supabase CLI cuando linkeamos el proyecto local para correr migraciones (T-009).
- `SUPABASE_DATABASE_URL` queda con la **Direct connection** (puerto 5432). El pooler (6543) no se documenta porque no lo usamos todavía; lo agregamos si en T-009 vemos que hace falta.
