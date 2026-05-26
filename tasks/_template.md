# T-XXX — [Título corto en imperativo]

**Estado:** todo | in-progress | done
**Estimación:** XX min
**Depende de:** T-YYY, T-ZZZ (o "ninguna")
**Sesión:** YYYY-MM-DD

## Objetivo

Una frase clara de qué se logra al terminar esta tarea.

## Contexto necesario

Qué archivos y docs leer antes de empezar. Por ejemplo:
- `docs/03-data-model.md` (tabla `predictions`)
- `src/lib/supabase/server.ts`

## Criterios de aceptación

Checklist verificable. Si no se puede chequear, no es un criterio.

- [ ] El usuario puede cargar predicción para un partido futuro.
- [ ] Si el partido ya empezó, el server rechaza con error 403.
- [ ] La predicción queda guardada con timestamp en `created_at`.
- [ ] Tests unitarios de la server action pasan.

## Fuera de alcance

Cosas que parecen relacionadas pero NO se hacen en esta tarea. Esto es clave para que Claude no se vaya por las ramas.

- No incluye edición de predicciones (eso es T-015).
- No incluye UI de listado de predicciones (eso es T-016).

## Notas / decisiones tomadas durante la tarea

(Llenar al final, antes de mover a done.md)
