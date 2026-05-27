# Tarea en progreso

⚠️ **Hay una sola tarea en progreso a la vez.** Si necesitás cambiar de tarea, primero terminá la actual o movela explícitamente al backlog.

---

# T-006 — Implementar auth con Supabase magic link (login + callback + logout)

**Sesión:** 2026-05-27
**Estado:** in-progress
**Inicio:** 14:18

## Objetivo

Que un usuario pueda pedir un magic link con su email, abrir el link, y quedar logueado en la app. Y poder desloguearse. Primera tarea que efectivamente consume las env vars cargadas en T-005.

## Plan

1. Instalar deps: `@supabase/ssr`, `@supabase/supabase-js`, `zod`.
2. Helper de cliente Supabase server-side en `src/lib/supabase/server.ts` (envuelve `cookies()` de `next/headers`, válido para Server Components, Server Actions y Route Handlers).
3. Página `/login`:
   - `src/app/login/page.tsx` (server component, layout/estructura).
   - `src/app/login/login-form.tsx` (client component, usa `useActionState` de React 19 para pending state + mensaje "te mandamos el link").
   - `src/app/login/actions.ts` (server action `requestMagicLink`, valida email con Zod, llama `signInWithOtp`, deriva el `emailRedirectTo` del host del request).
4. Route handler `src/app/auth/callback/route.ts` que recibe `?code=...`, llama `exchangeCodeForSession`, redirige a `/` (éxito) o `/login?error=...` (falla).
5. Server action de logout en `src/app/(actions)/logout.ts` (o ubicación equivalente). Llama `signOut()` y redirige a `/login`.
6. Reemplazar el `src/app/page.tsx` default por home autenticado mínimo:
   - Si no hay user → `redirect('/login')` (preview de lo que va a hacer middleware en T-007).
   - Si hay user → muestra el email + form con botón "Cerrar sesión".
7. Update de `layout.tsx`: cambiar `lang="en"` a `lang="es-AR"` y la metadata default a algo del proyecto.
8. Verificar build (`npm run build`) y test manual end-to-end con `npm run dev` (lo hace Rami con su email real).

## Criterios de aceptación

- [ ] `/login` renderiza form con input email + botón "Enviar link".
- [ ] Submit con email válido dispara magic link y la UI muestra "Te mandamos un link a tu email".
- [ ] Submit con email inválido muestra mensaje de error en español rioplatense.
- [ ] Click en el link del email loguea al usuario y lo redirige a `/`.
- [ ] `/` muestra el email del usuario logueado y un botón "Cerrar sesión".
- [ ] Logout limpia la sesión y redirige a `/login`.
- [ ] Entrar a `/` sin sesión redirige a `/login`.
- [ ] `npm run build` pasa sin errores de TS ni de ESLint.

## Fuera de scope

- Middleware de protección de rutas a nivel framework (T-007).
- Layout / bottom-nav mobile-first (T-008).
- Allowlist de emails (qué pasa si entra alguien que no es del grupo). Mecanismo a definir; se agrega a `backlog.md` al cerrar T-006.
- Tests automatizados de auth (la guía del proyecto es: tests donde importan — scoring, RLS, lock de predicciones).

## Pendientes off-band para Rami (manuales en Supabase dashboard)

Necesarios para que el flow ande end-to-end **antes** del test manual:

- En Supabase dashboard → **Authentication → URL Configuration**:
  - **Site URL**: `http://localhost:3000` (para dev).
  - **Redirect URLs**: agregar `http://localhost:3000/auth/callback` y `https://bna-prode-mundial.vercel.app/auth/callback` a la lista de URLs permitidas.
- Verificar que el email template del magic link (Authentication → Email Templates → Magic Link) usa la variable `{{ .ConfirmationURL }}` con `redirect_to` (default suele ser correcto, pero confirmamos).

## Notas durante la ejecución

[Se llena conforme avanza la tarea.]

---

## Template para cuando se arranca una tarea

```markdown
# T-XXX — [Título]

**Sesión:** YYYY-MM-DD
**Estado:** in-progress
**Inicio:** HH:MM

## Objetivo
[Qué se logra al terminar]

## Plan
1. [Paso 1]
2. [Paso 2]
...

## Criterios de aceptación
- [ ] [Criterio 1]
- [ ] [Criterio 2]

## Fuera de scope
- [Cosa que NO se hace en esta tarea]

## Notas durante la ejecución
[Llenar conforme avanza la tarea]
```
