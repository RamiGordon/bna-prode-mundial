# 04 — Reglas de puntaje (FROZEN)

⚠️ **Una vez que arranca el Mundial (11/06/2026 19:00 ART), estas reglas no se modifican.** Acordadas con el grupo de prode previo a esa fecha.

## Predicciones de partidos

### Fase de grupos

| Acierto | Puntos |
|---|---|
| Resultado exacto (ej: predije 2-1 y salió 2-1) | **5** |
| Ganador correcto + diferencia de goles correcta (ej: predije 2-1, salió 3-2) | **3** |
| Solo ganador correcto o empate correcto | **2** |
| Nada | 0 |

### Eliminación directa

Mismos puntos base, multiplicados:

| Fase | Multiplicador |
|---|---|
| 32avos (r32) | ×1.0 |
| 16avos (r16) | ×1.5 |
| Cuartos | ×2.0 |
| Semifinales | ×2.5 |
| Tercer puesto | ×1.5 |
| Final | ×3.0 |

### Regla en partidos a definir por penales

El resultado válido para el prode es el **resultado al final del tiempo regular (90') o suplementario (120') si lo hubo**. La tanda de penales NO cuenta para el prode.

Ejemplo: empatan 1-1 en 90', se van al alargue, terminan 2-2, definen por penales. El resultado válido es 2-2.

## Predicciones de bonus

Se cargan antes del kickoff inaugural y se calculan al finalizar el torneo.

| Bonus | Puntos |
|---|---|
| Campeón acertado | **20** |
| Subcampeón acertado (finalista perdedor) | **10** |
| Goleador del torneo acertado | **15** |
| Por cada semifinalista acertado (sin orden, máx 4) | **5** (hasta 20) |

**Nota sobre el goleador:** se valida manualmente al final del torneo contra fuentes oficiales FIFA. En caso de empate en goles, se acepta cualquiera de los empatados como acierto.

## Desempates en ranking final

Si dos jugadores terminan empatados en puntos totales:

1. **Más resultados exactos acertados.** Quien acertó más resultados exactos a lo largo del torneo gana.
2. **Acertó campeón.** Si solo uno lo acertó, gana ese.
3. **Acertó goleador.** Si solo uno lo acertó, gana ese.
4. **Suma de puntos en fase eliminatoria.** Quien sumó más puntos desde octavos en adelante gana.
5. **Sorteo entre los empatados.** Único caso donde interviene azar.

## Reglas operativas

- **Cierre de predicciones:** automático al kickoff de cada partido. Si no predijiste antes, suma 0 puntos por ese partido. No hay excepciones.
- **Cierre de bonus:** al kickoff del partido inaugural (11/06/2026 19:00 ART). Después de ese momento queda frozen.
- **Cambios de resultado:** si un resultado se carga mal y se corrige, los puntajes se recalculan para todos. Queda log de la corrección.
- **Forfeits o partidos cancelados:** si la FIFA da un equipo por ganador por walkover, se toma ese resultado (típicamente 3-0). Si un partido se reprograma, las predicciones siguen vigentes hasta el nuevo kickoff.
