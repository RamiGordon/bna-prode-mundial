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
