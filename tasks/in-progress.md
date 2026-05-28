# Tarea en progreso

⚠️ **Hay una sola tarea en progreso a la vez.** Si necesitás cambiar de tarea, primero terminá la actual o movela explícitamente al backlog.

---

## Estado actual: NINGUNA TAREA EN PROGRESO

Próximo paso: levantar **T-010 (seed de 48 selecciones del Mundial 2026)** del `backlog.md`. Sigue Sesión 3 / día 3.

### Pendientes off-band heredados (los hace Rami cuando pueda, no bloquean T-010)

- Agregar las export lines de `nvm` al `~/.zshrc` para que `nvm` esté disponible en terminales nuevas. Las imprime `brew info nvm`. (de T-004)
- **Promover a admin manualmente:** después del primer login (ya hecho en T-006), abrir el SQL editor del dashboard de Supabase y correr `update profiles set is_admin = true where id = '<tu uuid>';`. Necesario para poder cargar teams/matches/resultados desde la app cuando llegue T-024. Mientras tanto, los seeds de T-010/T-011 los aplicamos vía `psql` con `SUPABASE_DATABASE_URL` (rol `postgres` que bypassea RLS).

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
