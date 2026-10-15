# Resumen final de entrega — NexaSoft Incidencias

## Qué funcionó

- **Los tres bugs reportados quedaron corregidos** con cambios de pocas líneas en `lib/services/gestor_incidencias.dart`, cada uno en su rama (`fix/bug-001`, `fix/bug-002`, `fix/bug-003`) e integrado en `main`:
  - los cambios de estado se guardan (BUG-001);
  - la búsqueda ignora mayúsculas y espacios y revisa la descripción (BUG-002);
  - el tablero se calcula siempre desde los datos completos (BUG-003).
- **FEAT-001 (prioridad)** funciona en alta, lista y detalle, persiste al reiniciar y abre los registros antiguos como Media sin fallar. Integrada en `main` (commit del Día 3, `ff8bebc`).
- **FEAT-002 (filtros)** combina texto, estado y prioridad; tiene botón para limpiar y mensaje claro ante cero resultados, y no altera el tablero. Integrada en `main` (commit del Día 4) tras las pruebas manuales E1–E15.
- **Pruebas automáticas:** de 1 prueba original a **32**. Cada corrección se verificó también en sentido inverso: las pruebas fallan si se quita la corrección o se introduce un error.
- **Trazabilidad:** una rama por ticket, commits descriptivos, merges sin fast-forward (el historial publicado se consolidó después en un commit por día), bitácoras diarias con capturas y declaración del uso de IA.

## Qué sigue pendiente

- **Etiqueta de versión** (`v1.0-entrega`): por decidir.
- **Acentos en la búsqueda** (`tunel` ↔ `túnel`): pendiente de decisión. Se recomendó normalizar á/é/í/ó/ú/ü antes de comparar; no se implementó sin autorización.

## Riesgos conocidos

| Riesgo | Detalle | Mitigación |
|---|---|---|
| Pérdida de prioridades con una versión antigua | Si se abre una versión sin FEAT-001 (p. ej. una copia del Día 2) en el **mismo puerto/origen** y esta guarda, reescribe los datos sin el campo `prioridad`; al volver a la versión nueva, todo aparece en Media. | Usar puertos distintos para versiones distintas; no ejecutar versiones antiguas sobre los datos reales. |
| Avisos de `flutter analyze` | 3 avisos *info* que ya tenía el código original: `value` deprecado en dos Dropdown (`pantalla_detalle`, `pantalla_nueva`) y uso de `BuildContext` tras un `await` en `pantalla_principal` (Restablecer). No impiden compilar ni ejecutar. | Corregir en un ticket de mantenimiento aparte; el código nuevo no los repite. |
| Filtros no persistentes | Por decisión, al reiniciar la app los filtros vuelven a Todos / Todas y el buscador queda vacío. | Comportamiento documentado; si el cliente lo pide, se puede agregar en un ticket nuevo. |
| Búsqueda sensible a acentos | `tunel` no encuentra "túnel". | Pendiente de decisión (ver arriba). |
| Datos en el navegador | En web los datos viven en `localStorage` por origen (incluye el puerto): cambiar de puerto o borrar datos del navegador "pierde" los registros. | Ejecutar siempre con `--web-port=8080` para pruebas y demostración. |
