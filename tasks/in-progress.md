# Tarea en progreso

⚠️ **Hay una sola tarea en progreso a la vez.** Si necesitás cambiar de tarea, primero terminá la actual o movela explícitamente al backlog.

---

## Estado actual: NINGUNA TAREA EN PROGRESO

Próximo paso: levantar **T-006 (Implementar auth con Supabase magic link — login + callback + logout)** del `backlog.md`. Arranca la Sesión 2 del roadmap.

### Pendientes off-band heredados (los hace Rami cuando pueda, no bloquean T-006)

- Agregar las export lines de `nvm` al `~/.zshrc` para que `nvm` esté disponible en terminales nuevas. Las imprime `brew info nvm`. (de T-004)
- Fijar Node version `24` en Vercel Project Settings → General → Node.js Version, para alinear con `.nvmrc`. (de T-004)
- Cargar las 3 vars públicas de Supabase en Vercel (Project Settings → Environment Variables, production + preview + development): `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `NEXT_SUPABASE_SECRET_KEY`. El resto NO va a Vercel. (de T-005)

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
