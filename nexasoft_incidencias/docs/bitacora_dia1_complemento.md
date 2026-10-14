# Bitácora — Día 1 (complemento)

> Texto listo para copiar a la plantilla de Word. Los campos entre corchetes `[ ]` los llenas tú.
> Los IDs de evidencia se renumeraron (E1–E5) para corregir el ID **E2 repetido** del Día 1.

## Encabezado

| Campo | Valor |
|---|---|
| Día | 1 |
| Fecha | [dd/mm/aaaa] |
| Tickets | Reproducción de BUG-001, BUG-002, BUG-003 |
| Rama | `main` (solo diagnóstico, sin cambios de código) |

## 1. Actividades

*(Sin cambios respecto a lo ya registrado; completar si faltó algo).*

## 2. Pasos de reproducción

**BUG-001 — El cambio de estado / la incidencia nueva no se conservan**
1. Abrir la app en Chrome, entrar al detalle de una incidencia `Pendiente` y cambiarla a `Resuelta`.
2. Registrar una incidencia nueva con "Nueva incidencia".
3. Cerrar y volver a abrir (recargar) la app.
- **Observado:** la incidencia vuelve a su estado anterior y la incidencia nueva ya no aparece.
- **Esperado:** el estado nuevo y la incidencia registrada se conservan después de recargar.

**BUG-002 — La búsqueda omite registros existentes**
1. En "Buscar incidencias" escribir `wifi` (minúsculas).
2. Borrar y escribir `WiFi` (mayúsculas exactas).
3. Buscar una palabra que solo esté en la descripción (p. ej. `túnel`).
- **Observado:** `wifi` no muestra resultados; `WiFi` sí muestra "WiFi intermitente en recepción"; las palabras de la descripción no se encuentran.
- **Esperado:** la búsqueda ignora mayúsculas/minúsculas y busca en título y descripción.

**BUG-003 — El tablero no coincide con la lista**
1. Con la lista inicial (10 registros), cambiar el estado de una incidencia desde el detalle.
2. Volver a la lista (y recargar la app).
3. Comparar la suma del tablero (Pendientes + En proceso + Resueltas) con el número de registros de la lista.
- **Observado:** el tablero sumaba **9** y la lista mostraba **10** registros.
- **Esperado:** la suma del tablero coincide con el total de registros y cada contador coincide con la lista.

## 3. Hipótesis iniciales (sin confirmar)

| Ticket | Hipótesis | Cómo comprobarla |
|---|---|---|
| BUG-001 | El cambio de estado solo se aplica en memoria y no se guarda en el almacenamiento local; o al iniciar se vuelve a cargar el JSON de `assets/` encima de lo guardado. | Revisar si `cambiarEstado()` llama a `guardar()` y en qué orden `leer()` usa almacenamiento local vs. JSON. |
| BUG-002 | La búsqueda usa una comparación exacta (`contains`) que distingue mayúsculas y solo revisa el título. | Revisar `buscar()` en el gestor de incidencias. |
| BUG-003 | Los totales se guardan en un contador aparte que no se actualiza al cambiar el estado, o se calculan sobre la lista filtrada. | Revisar `contar()` y dónde se actualiza el contador de pendientes. |

## 4. Archivos revisados

| Archivo | Motivo de la revisión |
|---|---|
| `lib/main.dart` | Punto de entrada de la app. |
| `lib/model/incidencia.dart` | Modelo `Incidencia` y serialización `desdeJson` / `toJson`. |
| `lib/data/almacen_local.dart` | Lectura de la semilla JSON y del almacenamiento local (`shared_preferences`, clave `nexasoft_incidencias_v1`). |
| `lib/services/gestor_incidencias.dart` | Búsqueda, conteo del tablero, cambio de estado, alta de incidencias. |
| `lib/ui/pantalla_principal.dart` | Tablero, buscador, lista y botón "Restablecer demostración". |
| `lib/ui/pantalla_detalle.dart` | Cambio de estado. |
| `lib/ui/pantalla_nueva.dart` | Registro de incidencias nuevas. |
| `assets/data/incidencias.json` | Datos iniciales ficticios (10 incidencias). |

- Commit con el estado original del código: `b4887f0` (repositorio inicial).
- Commit `chore: estado inicial del proyecto heredado antes de mantenimiento`: **`b49f713`**.
- Documentación generada: `docs/mapa_componentes.md` (`45d7eaa`), `docs/reproduccion_bugs.md` (`2f340ce`).

## 5. Evidencias

| Ticket | ID / escenario | Qué demuestra | Fecha |
|---|---|---|---|
| — | **E1** Primera ejecución | La app arranca y muestra las 10 incidencias de la semilla con el tablero inicial. | [dd/mm/aaaa] |
| BUG-001 | **E2** Incidencia agregada | La incidencia nueva aparece en la lista antes de recargar. | [dd/mm/aaaa] |
| BUG-001 / BUG-003 | **E3** Tras recargar | La incidencia agregada ya no aparece y el tablero suma 9 mientras la lista muestra 10. | [dd/mm/aaaa] |
| BUG-002 | **E4** Búsqueda `wifi` (minúsculas) | La búsqueda no devuelve "WiFi intermitente en recepción". | [dd/mm/aaaa] |
| BUG-002 | **E5** Búsqueda `WiFi` (mayúsculas exactas) | Con las mayúsculas exactas sí encuentra el registro: la búsqueda distingue mayúsculas. | [dd/mm/aaaa] |

## 6. Matriz de pruebas (lo observado en el Día 1)

| Escenario | Esperado | Obtenido | ¿Pasó? |
|---|---|---|---|
| Cambiar estado y recargar | Se conserva el nuevo estado | Vuelve el estado anterior | No |
| Registrar incidencia y recargar | La incidencia sigue en la lista | La incidencia desapareció | No |
| Buscar `wifi` | Aparece "WiFi intermitente en recepción" | Sin resultados | No |
| Buscar `WiFi` | Aparece "WiFi intermitente en recepción" | Aparece | Sí |
| Buscar palabra de la descripción | Aparece la incidencia | Sin resultados | No |
| Tablero vs. lista tras cambiar estado | Suma del tablero = registros de la lista | 9 vs. 10 | No |

## 7. Uso de IA

*(Día 1: sin uso de IA, o completar si se usó).*

## 8. Cierre

- **Tickets concluidos:** ninguno. El Día 1 fue de diagnóstico y reproducción.
- **Bloqueos:** ninguno técnico; faltaba documentar pasos y evidencias (completado en este complemento).
- **Siguiente paso:** corregir BUG-001 (persistencia) en la rama `fix/bug-001`, porque BUG-003 requiere verificar los totales después de reiniciar.
