# Tareas completadas

Registro append-only de tareas terminadas. Última al final. Útil para ver progreso real y para que Claude tenga contexto histórico en sesiones nuevas.

---

## Formato

```
## T-XXX — Título (YYYY-MM-DD, HH:MM-HH:MM)
- Resumen: una o dos líneas.
- Decisiones tomadas: si las hubo.
- Bugs encontrados: si los hubo.
- Commits: SHA1 SHA2 ...
```

---

## Histórico

## T-001 — Crear repo en GitHub e inicializarlo localmente (2026-05-26)
- Resumen: repo público creado en `RamiGordon/bna-prode-mundial`, conectado vía SSH como `origin`, 3 commits locales pusheados a `main`.
- Decisiones tomadas:
  - Visibilidad **Public** (por elección del owner, contra la recomendación de Private). Implica que toda la lógica de scoring/RLS será visible — la seguridad vive en el server.
  - Nombre del repo idéntico al directorio local (`bna-prode-mundial`) para evitar divergencia.
  - `gh` CLI instalado vía Homebrew como herramienta de sesiones futuras.
  - Sistema de puntajes confirmado con el grupo: `docs/04-scoring-rules.md` queda como fuente canónica; `docs/01-requirements.md` alineado.
- Bugs encontrados: ninguno.
- Commits relevantes: 08405ad (docs alignment previo a T-001).

## T-002 — Crear proyecto en Supabase y obtener credenciales (2026-05-26)
- Resumen: proyecto `bna-prode-mundial` creado en Supabase free tier, org `rami-personal`, region South America (São Paulo, `sa-east-1`). Project ref `amfinktznidqxcaoxwdf`. Credenciales (Project URL, anon key, service_role key, DB password, Direct connection string, Transaction pooler connection string) capturadas y guardadas por Rami en su password manager — nada commiteado al repo.
- Decisiones tomadas:
  - Region **São Paulo** por ser la más cercana a AR (menor latencia para los usuarios).
  - Se guardaron **dos** connection strings: **Direct** (puerto 5432, para correr migraciones desde local en T-009) y **Transaction pooler** (puerto 6543, para runtime serverless desde Vercel). La elección final entre pooler modes la decidimos cuando arranque T-009.
  - Credenciales fuera del repo. Se meten en `.env.local` recién en T-005.
- Bugs encontrados: ninguno, pero la UI de Supabase cambió respecto a guías viejas — las connection strings ahora viven detrás del botón verde **"Connect"** arriba en el dashboard, no en `Project Settings → Database` como antes. A tener en cuenta si en sesiones futuras hay que volver a buscarlas.
- Commits relevantes: solo el commit de cierre de la tarea.

## T-003 — Crear proyecto en Vercel y conectarlo al repo de GitHub (2026-05-26, 12:06-12:15)
- Resumen: proyecto `bna-prode-mundial` creado en Vercel, linkeado al repo `RamiGordon/bna-prode-mundial` con production branch = `main`. URL pública asignada: `bna-prode-mundial.vercel.app`. Framework preset = Next.js (en anticipación a T-004). Variables de entorno vacías (se cargan en T-005).
- Decisiones tomadas:
  - **Framework preset = Next.js desde el import**, aceptando que el primer deploy iba a fallar (el repo todavía no tiene `package.json`). Alternativa descartada: usar "Other" y cambiar después. Se eligió Next.js para que el primer push de T-004 deploye limpio sin tener que volver a settings.
  - **Root Directory = `/`** (default). No hay monorepo.
  - **No se tocó env vars.** Verificado explícitamente que la lista está vacía. Las vars de Supabase entran en T-005.
- Bugs encontrados: ninguno. El deploy fallado contra el commit `693497c` confirma que el webhook GitHub → Vercel está activo y reaccionando a `main`. Es el estado esperado hasta T-004.
- Commits relevantes: solo el commit de cierre de la tarea.

## T-004 — Inicializar Next.js con TypeScript, Tailwind, ESLint y shadcn/ui base (2026-05-26 → 2026-05-27)
- Resumen: scaffold de **Next.js 16.2.6** (latest stable) con App Router, React 19.2.4, TypeScript estricto, Tailwind v4, ESLint 9, layout `src/`, import alias `@/*`. shadcn/ui inicializado con preset default (`base-nova` + `lucide` + CSS variables), sin componentes. Node 24 LTS pineado en `.nvmrc`. Build local OK y deploy verde en Vercel para `d3a686e` → `https://bna-prode-mundial-c5vtus6pv-ramigordons-projects.vercel.app`. 9 referencias a "Next.js 14" actualizadas en docs/tasks/README.
- Decisiones tomadas:
  - **Subir de Next 14 a latest (16.2.6)** y rescribir CLAUDE.md, README.md, los 4 docs y el ADR 0001 para no quedar pegados a una versión obsoleta antes de escribir una línea de código. Se agregó nota de amendment en el ADR para mantener trazabilidad.
  - **Scaffold vía directorio temporal + `rsync`** (no `create-next-app .` directo). Más predecible: garantiza que no se pisen `CLAUDE.md`, `README.md` ni `.gitignore` existentes. La CLI quería generar su propio CLAUDE.md (sólo apuntaba a `AGENTS.md`) y su propio README genérico, los descartamos.
  - **Mantener `AGENTS.md`** que genera el scaffold (advertencia de Next 16 sobre breaking changes vs training data de agentes). Convive con CLAUDE.md sin conflicto: uno es framework-level, otro es project-level.
  - **`tsconfig.json` con `noUncheckedIndexedAccess: true`** además de `strict: true`. Más seguro para acceso a arrays/objetos (relevante para listas de partidos, predicciones, ranking).
  - **shadcn preset = default `base-nova`** porque el viejo sistema de "slate/zinc/neutral" como flag de CLI ya no existe — ahora son presets nombrados. El default usa oklch neutral puro (sin tinte azul de slate viejo). **Cambio pendiente:** si en alguna pantalla queremos tinte slate, se editan ~10 líneas de CSS variables en `src/app/globals.css`.
  - **Borrado del `Button` auto-instalado** por el preset shadcn (`src/components/ui/button.tsx`) para honrar "sin componentes todavía". Las deps que se instalaron quedan (se usarán cuando se agregue el primer componente real).
  - **nvm vía Homebrew**, no script curl. Estaba instalado en `/opt/homebrew/opt/nvm 0.40.4` pero sin cargar en el shell; lo cargué en cada Bash call con `source`. Rami tiene pendiente agregar las export lines a su `~/.zshrc` para que esté disponible en sesiones nuevas (`brew info nvm` las imprime).
  - **package manager = npm** (default). Vercel acepta ambos; mover a pnpm es trivial si después aparece la necesidad.
- Bugs encontrados:
  - `npm audit` reporta 2 vulns moderate en `postcss <8.5.10` (sub-dep de Next). El auto-fix querría downgradear Next a 9.3.3 (rotísimo). El vuln (XSS via `</style>` en stringify) sólo se dispara si el build procesa CSS con input de usuario, que no es nuestro caso. Se resuelve cuando Next bumpee postcss en una minor.
  - Vercel UI del proyecto no tiene Node version explícita — el deploy salió verde con el default que asume Vercel. Pendiente fijarla en `24` para alinear con `.nvmrc` (lo hace Rami via Project Settings → General → Node.js Version).
- Commits relevantes: 32dccd6 c046e3b 6fd57b3 d3a686e + commit de cierre.

## T-005 — Configurar `.env.local` y `.env.example` con variables de Supabase (2026-05-27, 13:12-13:18)
- Resumen: `.env` renombrado a `.env.local` (convención Next.js). Creado `.env.example` commiteado con la lista de variables y comentarios que explican qué hace cada una y dónde se usa (Vercel vs local-only). `.gitignore` ajustado con `!.env.example` para que la regla amplia `.env*` no lo bloquee. `.env.local` queda fuera del repo como siempre.
- Decisiones tomadas:
  - **Nomenclatura nueva de Supabase** (`sb_publishable_*` / `sb_secret_*`), descartando las viejas (anon JWT / service_role JWT). Razón: revocables individualmente sin tener que rotar el JWT signing key de todo el proyecto. Las claves nuevas ya estaban generadas en el dashboard de T-002 — en `done.md` de T-002 quedó registrado con la nomenclatura vieja porque ese era el lenguaje del momento; no se corrige el registro histórico.
  - **`SUPABASE_DATABASE_URL` queda con la Direct connection (puerto 5432)**, no pooler. No se usa desde Vercel — sólo desde local para migraciones de T-009. Si en T-009 vemos que también necesitamos el pooler, lo agregamos ahí.
  - **`SUPA_REF` se mantiene** en `.env.local`. Lo usa la Supabase CLI (`supabase link --project-ref $SUPA_REF`) cuando arranquemos T-009. No se sube a Vercel.
  - **No se crea cliente Supabase ni hay código que consuma las env vars todavía.** Eso entra en T-006 junto con el flow de magic link. Esta tarea es sólo el contrato de variables.
- Bugs encontrados: ninguno. Detalle: el `.gitignore` original tenía `.env*` como glob amplio, que también ignoraba `.env.example`. Es un default razonable de Next pero requiere el `!.env.example` explícito si querés versionar el template. A tener en cuenta si en el futuro agregamos otros `.env.*` versionables (`.env.test`, etc.).
- Pendientes off-band para Rami (no bloquean T-006): cargar las 3 vars `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `NEXT_SUPABASE_SECRET_KEY` en Vercel Project Settings → Environment Variables (production + preview + development). El resto de las vars (SUPA_REF, SUPABASE_DATABASE_URL) NO van a Vercel. **[✓ hecho por Rami el 2026-05-27]**
- Commits relevantes: ec2c289 3748f9a + commit de cierre.

## T-006 — Implementar auth con Supabase magic link — login + callback + logout (2026-05-27, 14:18-16:00)
- Resumen: flow de auth end-to-end con magic link de Supabase. `/login` (server component) + `LoginForm` (único client component, usa `useActionState` de React 19) + server action `requestMagicLink` con validación Zod. `/auth/callback` route handler que intercambia el code por sesión. `/` placeholder autenticado con email + logout. Helper `src/lib/supabase/server.ts` reutilizable en Server Components, Server Actions y Route Handlers. Build verde, test manual end-to-end OK (login → mail → click → logueado → logout → vuelta a /login).
- Decisiones tomadas:
  - **Lib `@supabase/ssr` ^0.10.3** (no el deprecado `@supabase/auth-helpers-nextjs`). Resuelve el problema de que las cookies se leen/escriben distinto según el contexto (Server Component vs Server Action vs Route Handler) — vos le pasás funciones `getAll`/`setAll` y la lib se ocupa.
  - **Un solo helper `createClient()`** que vale para los 3 contextos. El `try/catch` del `setAll` cubre el caso Server Component (donde `cookies()` no permite set). El refresh real de la sesión lo va a hacer el middleware en T-007.
  - **Browser client NO se agrega todavía.** Ningún Client Component en T-006 necesita hablar con Supabase. Se incorpora cuando aparezca el primer caso (probablemente alguna pantalla con subscriptions realtime).
  - **API keys = publishable + URL, no la secret.** El flow de auth se autoriza vía cookie del usuario; la secret key (que bypassea RLS) queda reservada para tareas admin futuras (T-024 carga de resultados, etc.).
  - **`emailRedirectTo` derivado del request, no de env var.** Se lee `host` + `x-forwarded-proto` con `headers()`. Adapta solo a localhost vs preview vs prod sin tener que mantener una `NEXT_PUBLIC_SITE_URL`. Trade-off: depende de que los headers estén bien seteados por Vercel (lo están).
  - **Mínimo client state.** Sólo `LoginForm` es `"use client"`, todo el resto es server. `useActionState` da pending + estado "te mandamos el link" sin necesidad de fetch.
  - **Rutas planas**: `/login`, `/auth/callback`, `/`. No route group `(auth)` por ahora — agregaría un nivel sin valor con sólo una página. Se refactorea cuando crezca la sección auth.
  - **Logout en `src/app/actions.ts`** (action global, único compartido por todas las páginas). Si crecen las actions globales se reorganiza después.
  - **Home `/` redirige inline a `/login` si no hay user.** Es un preview de lo que va a hacer el middleware en T-007 — pero lo dejamos ya para que el flow cierre. Cuando T-007 meta el middleware se puede simplificar.
  - **Zod 4: `z.string().email()` clásico** (no el nuevo `z.email()` de zod 4). Más portable y reconocible, sin deprecation warning.
  - **Sin tests automatizados de auth.** Fuera del criterio del proyecto ("tests donde importan: scoring, validación de cierre de predicciones, RLS").
- Bugs encontrados:
  - **Mensaje genérico tapaba el rate-limit de Supabase.** Al loguearse, desloguearse, y pedir otro link al toque, Supabase devuelve 429 (default: 1 magic link por email cada 60s). El error se atrapaba con el mensaje genérico "No pudimos mandarte el link", que confunde porque no aclara que es esperado. Fix en commit `a0b70e7`: detectar `status === 429` o `code === "over_email_send_rate_limit"` y mostrar "Pediste un link hace muy poco. Esperá un minuto." Además se loggea el error real (status/code/message) en server console para diagnosticar errores futuros desconocidos sin adivinar.
  - **2 moderate vulns en npm audit** siguen ahí — son las de postcss heredadas de Next, ya documentadas en T-004.
- Pendientes off-band para Rami: ninguno nuevo. Los previos al test ya están cumplidos: ✓ Redirect URLs configuradas en Supabase dashboard (localhost + Vercel). ✓ Test manual end-to-end verificado.
- Próximo: **T-007 (middleware de Next que protege rutas autenticadas)** abre Sesión 2 / día 2.
- Commits relevantes: 4185ead c80e6eb b219089 870689a 25ae33a a0b70e7 + commit de cierre.

## T-007 — Proxy de Next que protege rutas autenticadas (2026-05-27, 16:30-17:45)
- Resumen: agregado `src/proxy.ts` (Next 16 proxy convention, antes `middleware.ts`) + helper `src/lib/supabase/proxy.ts` con `updateSession(request)` que refresca la cookie de sesión y redirige a `/login` cuando no hay user. Lista blanca de rutas públicas: `/login`, `/auth/*`. Si un user logueado va a `/login`, lo manda a `/`. Page-level guard defensivo en `src/app/page.tsx` mantenido a propósito. Build verde, lint verde, test manual end-to-end OK (paso 1: `/` → `/login`; paso 2: magic link → home; paso 3: `/login` con sesión → `/`; paso 4: logout → `/login`).
- Decisiones tomadas:
  - **Adoptar la convención `proxy.ts` de Next 16** en vez de `middleware.ts`. El build inicial tiró el warning `The "middleware" file convention is deprecated. Please use "proxy" instead.` y aunque seguía funcionando bajo el nombre viejo, no escribir código nuevo contra una convención deprecada. Esto forzó también renombrar el helper interno (`src/lib/supabase/middleware.ts` → `src/lib/supabase/proxy.ts`) y sincronizar 4 refs en docs/tasks. Convención: la función exportada se llama `proxy`, no `middleware`. Internamente Next sigue mostrándolo como `Proxy (Middleware)` en el bundle output — `Middleware` es el concepto genérico, `proxy` es solo el nombre del archivo en Next 16.
  - **Lista blanca de rutas públicas, no lista negra.** `/login` y `/auth/*` son públicas, todo lo demás privado por default. Más seguro para el futuro (cualquier ruta nueva queda protegida sin tener que acordarse de agregarla a la lista negra).
  - **Mantener el `if (!user) redirect("/login")` en `src/app/page.tsx`** como fallback defensivo, aunque el proxy ya lo hace antes. Razón: si el `matcher` del proxy alguna vez se rompe (config drift, regex que excluye demasiado), el page sigue refusing a renderizar contenido autenticado a un anon. Sin este guard, además, TypeScript no narrowea `user` y `user.email` no compila. Comment en el código lo explica para que un lector no piense que es duplicación accidental.
  - **Patrón `updateSession` igual al de la doc oficial de Supabase**: `let supabaseResponse = NextResponse.next()`, `cookies` adapter sobre `NextRequest` y `supabaseResponse.cookies`, `setAll` que reemplaza la response para incluir las cookies actualizadas. **Nada de lógica entre `createServerClient` y `getUser()`** — cualquier await ahí desincroniza las cookies y rompe auth en silencio. Comment en el código avisa de la trampa.
  - **`matcher` excluye `_next/static`, `_next/image`, `favicon.ico` y archivos con extensión** (`.svg|.png|.jpg|.jpeg|.gif|.webp|.ico`). Si en el futuro hay archivos protegidos en `public/`, este matcher no los cubre — habría que repensarlo entonces.
  - **Logged-in user en `/login` → `/`** además del redirect anon → `/login`. Mejora la UX: si volvés al tab con sesión activa y la URL quedó en `/login`, no te ves el form, ves la app. Implementado con un check explícito de `pathname === "/login"` para no afectar `/auth/callback` (el callback necesita correr aunque haya user, para refrescar el code).
  - **No se modeló rol de admin todavía**, solo "autenticado vs anon". Cuando llegue T-023 (admin) hay que ampliar el proxy o agregar checks de rol en las pages de admin.
  - **Sin tests automatizados.** Auth queda fuera del criterio de tests del proyecto (mismo razonamiento que T-006).
- Bugs encontrados:
  - **Falso positivo de rate-limit por dev server roto.** Al testear, el form mostraba "Pediste un link hace muy poco. Esperá un minuto" aunque hubieran pasado varios minutos sin pedir links. Investigación: el dev server (PID 70351) llevaba horas corriendo y el rename `middleware.ts → proxy.ts` + cambio de import path rompió el HMR de Turbopack. Los logs mostraban `[auth] signInWithOtp failed {}` (objeto vacío para el error destructurado), inconsistente con un 429 real de Supabase (que viene con `status` + `code`). El estado roto del server hacía que `signInWithOtp` devolviera un error degenerado que falsamente caía en la rama de rate-limit. Fix: `kill <pid> && rm -rf .next && npm run dev`. **Aprendizaje**: cuando renombrás archivo + import path simultáneamente, Turbopack HMR puede quedar inconsistente sin tirar errores visibles en el browser — restart limpio del dev server (con borrar `.next`) es la respuesta. Si vuelve a aparecer "rate-limit" cuando no debería, primer sospecha = dev server stale, no Supabase.
  - **Logs del action sólo muestran `{ status, code, message }`** del error de Supabase. En el bug de arriba, los 3 venían undefined → `console.error` imprimía `{}` y no daba info para diagnosticar. Mejora deseable (no hecha en T-007 por scope): loggear el error completo, no solo 3 propiedades específicas. Si volvemos a tropezar con un error opaco, hacer esto.
  - **2 vulns moderate de postcss** siguen ahí, heredadas de Next, ya documentadas en T-004 y T-006. Sin novedades.
- Pendientes off-band para Rami: ninguno nuevo. El de `nvm` en `.zshrc` (heredado de T-004) sigue abierto.
- Próximo: **T-008 (layout base con navegación mobile-first)** cierra Sesión 2 / día 2.
- Commits relevantes: 880dd87 + commit de cierre.
