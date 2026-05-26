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
