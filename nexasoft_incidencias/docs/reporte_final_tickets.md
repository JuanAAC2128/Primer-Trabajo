# Reporte final de tickets — NexaSoft Incidencias

> Estado al cierre del Día 4. Repositorio: `JuanAAC2128/Primer-Trabajo`. Los cinco tickets quedaron resueltos e integrados en `main`. Cada ticket se desarrolló en su propia rama y el historial publicado se consolidó en un commit por día: Día 1 `9c6d1fd`, Día 2 `e0bee78`, Día 3 `ff8bebc` y el commit del Día 4.

| Ticket | Estado final | Causa o decisión principal | Commit en `main` | Prueba que respalda el estado |
|---|---|---|---|---|
| **BUG-001** — El cambio de estado no se conserva | **Resuelto** | `cambiarEstado()` cambiaba el estado solo en memoria y nunca llamaba a `guardar()`. Se agregó `await datos.guardar(incidencias)`. | `e0bee78` (Día 2) | Automática: `test/gestor_persistencia_test.dart` (3; falla sin la corrección). Manual: Día 2 E1–E5; regresión Día 3 E14. |
| **BUG-002** — La búsqueda omite registros | **Resuelto** | `buscar()` usaba `titulo.contains(texto)`: distinguía mayúsculas, no aplicaba `trim` y no revisaba la descripción. Ahora normaliza con `trim().toLowerCase()` y busca en título y descripción. | `e0bee78` (Día 2) | Automática: `test/gestor_busqueda_test.dart` (4; 3 fallan sin la corrección). Manual: Día 2 E12–E16; regresión Día 3 E15. |
| **BUG-003** — El tablero no coincide con la lista | **Resuelto** | "Pendientes" salía de un contador aparte (`cantidadPendientes`) que no se actualizaba al cambiar estados (9 vs. 10). Se eliminó; `contar()` cuenta sobre la lista completa. | `e0bee78` (Día 2) | Automática: `test/gestor_totales_test.dart` (5; fallan sin la corrección) y prueba de tablero con filtros en `test/filtros_test.dart`. Manual: Día 2 E6–E11; regresión Día 3 E16. |
| **FEAT-001** — Clasificación por prioridad | **Resuelto** | `enum Prioridad` (Baja/Media/Alta) guardado como texto; registros antiguos, vacíos o inválidos → Media sin excepción; se aceptan variantes de mayúsculas; `cambiarPrioridad()` guarda de inmediato. | `ff8bebc` (Día 3) | Automática: `test/prioridad_test.dart` (10; comprobación inversa: 6 fallan). Manual: Día 3 E1–E16 aprobadas. |
| **FEAT-002** — Filtros combinables | **Resuelto** | `filtrar(texto, estado, prioridad)` en el gestor reutiliza `buscar()` y aplica Y lógico; "Todos"/"Todas" = `null`; tablero sigue con `contar()` sobre la lista completa; botón "Limpiar filtros"; mensaje ante cero resultados; filtros no persistentes (decisión aprobada). | Commit del Día 4 | Automática: `test/filtros_test.dart` (7 de lógica + 2 de widget; comprobación inversa: 3 fallan). Manual: Día 4 E1–E15 aprobadas. |

## Verificación global

| Comprobación | Resultado |
|---|---|
| `flutter test` en `main` | 32/32 pasan |
| `flutter analyze` | 3 avisos *info* preexistentes del código original; 0 nuevos |
| `flutter build web` | Compila |
| Push a GitHub (`main`) | Realizado |
