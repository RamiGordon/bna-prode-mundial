# Tarea en progreso

⚠️ **Hay una sola tarea en progreso a la vez.** Si necesitás cambiar de tarea, primero terminá la actual o movela explícitamente al backlog.

---

## Estado actual: NINGUNA TAREA EN PROGRESO

Próximo paso: levantar **T-005 (Configurar `.env.local` y `.env.example` con variables de Supabase)** del `backlog.md`.

### Pendientes off-band heredados de T-004 (los hace Rami cuando pueda, no bloquean T-005)

- Configurar Vercel → Project Settings → General → **Node.js Version = 24** para alinear con `.nvmrc`.
- Agregar las export lines de `nvm` al `~/.zshrc` para que `nvm` esté disponible en terminales nuevas. Las imprime `brew info nvm`.

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
