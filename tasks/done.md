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
