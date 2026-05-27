# CLAUDE.md — Contexto del proyecto Prode Mundial 2026

Leé este archivo COMPLETO antes de empezar cualquier tarea. También leé `tasks/in-progress.md` para saber qué estás haciendo ahora.

## Qué es este proyecto

PWA para que un grupo de 10–20 amigos juegue un prode híbrido (partidos + bonus) del Mundial 2026. Hay plata en juego (pozo gestionado fuera de la app). Deadline duro: **11 de junio de 2026, 19:00 ART** (kickoff inaugural). El proyecto lo construye Rami en nights/weekends mientras trabaja full-time en Mercado Libre.

## Stack (no cambiar sin discutir)

- **Frontend:** Next.js (App Router, latest stable), React, TypeScript estricto.
- **Estilos:** Tailwind CSS + shadcn/ui.
- **Backend/DB:** Supabase (Postgres + Auth con magic link + RLS).
- **Hosting:** Vercel.
- **Estado:** React Server Components + Server Actions. Mínimo client state.
- **Validación:** Zod en todos los inputs de server actions.

## Reglas de operación contigo (Claude)

1. **Antes de programar, planeá.** Si la tarea es ambigua, hacé preguntas. No asumas.
2. **Una tarea por vez.** No mezcles features. Si descubrís otro problema, anotalo en `tasks/backlog.md` y seguí con lo tuyo.
3. **No tomes decisiones de arquitectura solo.** Si dudás entre dos approaches, preguntá antes de codear.
4. **Commits chicos y atómicos.** Mensaje en imperativo en inglés: `feat: add prediction form validation`.
5. **No instales dependencias sin avisar.** Si necesitás una nueva lib, justificá por qué antes de `npm install`.
6. **Si encontrás algo que parece bug en código existente, no lo "arregles" silenciosamente.** Comentalo en el chat.
7. **No escribas tests por escribir tests.** Tests donde importan: lógica de puntajes, validación de cierre de predicciones, RLS.
8. **Errores claros, en español, para el usuario final.** Comentarios y código en inglés.

## Reglas de seguridad (no negociables)

Hay plata en juego, así que estas son inviolables:

- **Lock de predicciones al kickoff debe estar en server (RLS o function de Postgres), nunca solo en cliente.**
- **Timestamps inmutables.** Las predicciones llevan `created_at` y `updated_at`, no se borran nunca, ni siquiera al "editarlas".
- **Auditoría de cambios de resultados.** Si admin edita un resultado, queda log.
- **No exponer emails de usuarios en respuestas públicas.** Solo alias.
- **Variables de entorno nunca commiteadas.** Hay `.env.example`.

## Archivos de referencia (leelos cuando aplique)

- `docs/01-requirements.md` — requerimientos funcionales completos
- `docs/02-architecture.md` — diagrama y decisiones técnicas
- `docs/03-data-model.md` — schema Postgres con RLS
- `docs/04-scoring-rules.md` — fórmula exacta de puntajes
- `docs/05-roadmap.md` — plan día por día
- `docs/decisions/` — ADRs (consultá si vas a cambiar algo "raro")

## Flujo de cada sesión

1. Leé este archivo + `tasks/in-progress.md`.
2. Resumime en 3 líneas qué entendiste y qué vas a hacer.
3. Esperá mi OK antes de codear.
4. Ejecutá la tarea, commiteando cada paso.
5. Al terminar: actualizá `tasks/done.md` y movele a la próxima en `in-progress.md`.

## Cosas que NO hagas nunca

- Instalar React Native, Expo, Capacitor o cualquier wrapper mobile. Esto es PWA.
- Cambiar de Supabase a otra cosa.
- Implementar pagos dentro de la app (el pozo va por fuera).
- Mandar emails fuera del flow de magic link de Supabase.
- Hacer scraping de sitios de fútbol para resultados. Resultados los carga el admin a mano.
- Crear archivos de "ejemplo" o "demo" que no se usen. El repo se mantiene limpio.

## Stack mental rápido

- Argentina, La Plata. Timezone para el usuario: `America/Argentina/Buenos_Aires`.
- Todos los timestamps en DB en UTC. Conversión solo en la UI.
- Mobile-first siempre. Pantalla base de diseño: 375px de ancho.
- Idioma de la UI: español rioplatense (vos, no tú).
