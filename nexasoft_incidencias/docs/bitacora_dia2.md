# Bitácora — Día 2

> Texto listo para copiar a la plantilla de Word. Los campos entre corchetes `[ ]` los llenas tú.

## Encabezado

| Campo | Valor |
|---|---|
| Día | 2 |
| Fecha | [dd/mm/aaaa] |
| Tickets | BUG-001, BUG-002, BUG-003 |
| Ramas | `fix/bug-001`, `fix/bug-003`, `fix/bug-002` (creadas desde `main`) |

## 1. Actividades

| Hora | Actividad | Resultado |
|---|---|---|
| [hh:mm-hh:mm] | Completar documentación del Día 1: `.gitignore`, mapa de componentes, pasos de reproducción. | Commits `b49f713`, `45d7eaa`, `2f340ce`. |
| [hh:mm-hh:mm] | Desbloquear `flutter test` (Smart App Control de Windows bloqueaba `flutter_tester.exe`). | Ajuste hecho por mí en Seguridad de Windows; `flutter test` vuelve a ejecutarse. |
| [hh:mm-hh:mm] | BUG-001: investigar, corregir y probar persistencia del cambio de estado. | Commit `d82aaff` en `fix/bug-001`. |
| [hh:mm-hh:mm] | BUG-003: investigar, corregir y probar totales del tablero. | Commit `8320d3c` en `fix/bug-003`. |
| [hh:mm-hh:mm] | BUG-002: investigar, corregir y probar búsqueda. | Commit `a957339` en `fix/bug-002`. |
| [hh:mm-hh:mm] | Pruebas manuales en Chrome de cada rama. | [completar] |
| [hh:mm-hh:mm] | Integración (merge) de las tres ramas a `main` y regresión final. | [completar] |

## 2. Pasos de reproducción

*(Detalle completo en `docs/reproduccion_bugs.md`. Ejecutar siempre con `flutter run -d chrome --web-port=8080` y partir de "Restablecer demostración").*

**BUG-001**
1. Abrir INC-101 (`Pendiente`) y cambiarla a `Resuelta`.
2. Volver a la lista (se ve `Resuelta`), sin registrar incidencias nuevas.
3. Recargar la app (F5 o `R` en la terminal).
- **Observado:** INC-101 vuelve a `Pendiente`.
- **Esperado:** INC-101 sigue `Resuelta`.

**BUG-002**
1. Buscar `wifi`.
2. Buscar `  wifi  ` (con espacios).
3. Buscar `túnel`.
- **Observado:** sin resultados en los tres casos (solo `WiFi` exacto encuentra INC-102).
- **Esperado:** `wifi` y `  wifi  ` → INC-102; `túnel` → INC-106.

**BUG-003**
1. Partir del tablero 5 / 2 / 3 (10 registros).
2. Cambiar INC-104 de `Resuelta` a `Pendiente`.
3. Volver a la lista.
- **Observado:** tablero 5 / 2 / 2 (suma 9) contra 10 registros.
- **Esperado:** tablero 6 / 2 / 2 (suma 10).

## 3. Hipótesis, comprobación y causa real

**BUG-001**
- **Hipótesis:** el cambio solo se hace en memoria y no se guarda.
- **Comprobación:** revisión de `gestor_incidencias.dart` y `almacen_local.dart`. Se descartó: (a) que el JSON de `assets/` se cargue encima de lo guardado (`leer()` usa la semilla solo si no hay nada guardado); (b) que la clave no coincida (leer, guardar y borrar usan `nexasoft_incidencias_v1`); (c) que `toJson`/`desdeJson` pierdan el estado; (d) que se modifique una copia (se modifica `incidencias[i]`).
- **Causa real:** `GestorIncidencias.cambiarEstado()` actualiza `estado` en memoria pero **nunca llama a `datos.guardar()`**. Solo `crear()` guardaba. Al reiniciar, `leer()` devuelve la última lista guardada, sin el cambio.
- **Sobre la incidencia nueva que "desapareció" en el Día 1:** `crear()` sí guarda, así que la causa más probable fue relanzar con `flutter run` en otro puerto (en web, `localStorage` es por origen y el puerto cambia en cada ejecución si no se fija), o haber usado "Restablecer demostración". **Pendiente de confirmar** con la prueba manual usando `--web-port=8080`.
- **Prueba automática:** `test/gestor_persistencia_test.dart`. Sin la corrección falla (`Expected: 'Resuelta'`, `Actual: 'Pendiente'`); con la corrección pasa.

**BUG-003**
- **Hipótesis:** el total de pendientes es un contador aparte que no se actualiza.
- **Comprobación:** `contar('Pendiente')` devolvía `cantidadPendientes`, calculado una vez en `iniciar()` e incrementado en `crear()`, pero no modificado en `cambiarEstado()`. Se descartó que el conteo se haga sobre la lista filtrada (usa la lista completa) y que haya diferencias de texto en los estados (el JSON y el Dropdown usan los mismos valores).
- **Causa real:** contador `cantidadPendientes` desincronizado. Al pasar una incidencia **a** `Pendiente`, el contador no sube pero el otro estado sí baja (suma 9 de 10); al pasar **de** `Pendiente` a otro estado, la suma da 11.
- **Criterio adoptado:** cada total se calcula en el momento contando la lista completa de incidencias: `incidencias.where((x) => x.estado == estado).length`. No se usan contadores guardados y no depende de la búsqueda.
- **Prueba automática:** `test/gestor_totales_test.dart`. Sin la corrección falla (`Expected: <6>`, `Actual: <5>`); con la corrección pasa.

**BUG-002**
- **Hipótesis:** la comparación distingue mayúsculas y solo revisa el título.
- **Comprobación:** `buscar()` hacía `x.titulo.contains(texto)`.
- **Causa real:** tres defectos en la misma línea: (1) `contains` distingue mayúsculas; (2) no se revisa `descripcion`; (3) el `trim()` solo se usaba para detectar texto vacío, y luego se buscaba el texto con espacios.
- **Prueba automática:** `test/gestor_busqueda_test.dart`. Sin la corrección fallan 3 de 4 pruebas; con la corrección pasan todas.
- **Acentos (`tunel` vs `túnel`):** no implementado. Recomendación: sí conviene, porque los usuarios suelen escribir sin acentos. Se haría con una función pequeña que reemplace á/é/í/ó/ú/ü por su vocal sin acento antes de comparar. Queda **pendiente de decisión**.

**Intentos que no funcionaron**
- `flutter test` falló al inicio con "Una directiva de Control de aplicaciones bloqueó este archivo" (`flutter_tester.exe`). No era un problema del código: lo bloqueaba Smart App Control de Windows. Lo resolví ajustando la configuración de seguridad yo mismo; después las pruebas se ejecutaron con normalidad.
- Las correcciones funcionaron al primer intento.

## 4. Cambios por ticket

| Ticket | Archivo | Motivo | Commit | Estado |
|---|---|---|---|---|
| BUG-001 | `lib/services/gestor_incidencias.dart` | `cambiarEstado()` ahora hace `await datos.guardar(incidencias)`. | `d82aaff` | Corregido en rama; [pendiente de prueba manual / integrado] |
| BUG-001 | `test/gestor_persistencia_test.dart` | Prueba nueva: estado y alta conservados tras reiniciar; otros registros no cambian. | `d82aaff` | |
| BUG-001 | `pubspec.yaml`, `pubspec.lock` | Dependencia de desarrollo `shared_preferences_platform_interface` (almacén en memoria para pruebas). | `d82aaff` | |
| BUG-003 | `lib/services/gestor_incidencias.dart` | Se elimina `cantidadPendientes`; `contar()` cuenta todos los estados sobre la lista completa. | `8320d3c` | Corregido en rama; [pendiente de prueba manual / integrado] |
| BUG-003 | `test/gestor_totales_test.dart` | Prueba nueva: totales en semilla, Pendiente→Resuelta, Resuelta→Pendiente, caso nuevo, independencia de la búsqueda. | `8320d3c` | |
| BUG-002 | `lib/services/gestor_incidencias.dart` | `buscar()` normaliza con `trim().toLowerCase()` y compara título y descripción. | `a957339` | Corregido en rama; [pendiente de prueba manual / integrado] |
| BUG-002 | `test/gestor_busqueda_test.dart` | Prueba nueva: mayúsculas, espacios, descripción, texto vacío. | `a957339` | |

Verificación automática: `flutter analyze` sin avisos nuevos (persisten 3 avisos *info* que ya tenía el código original). `flutter test`: 4 pruebas pasan en `fix/bug-001`, 6 en `fix/bug-003`, 5 en `fix/bug-002` y 13 con las tres ramas integradas en una rama temporal (sin conflictos).

Merges a `main` (sin conflictos; 13/13 pruebas pasan en `main` integrada): BUG-001 `6c59073`, BUG-003 `21ca3b3`, BUG-002 `ad25387`.

## 5. Evidencias (capturas a tomar)

| Ticket | ID | Momento | Qué debe verse |
|---|---|---|---|
| BUG-001 | **E1** | Antes | INC-101 en `Pendiente` en la lista (URL con `:8080` visible). |
| BUG-001 | **E2** | Después | Detalle de INC-101 en `Resuelta` y la lista mostrando `Resuelta`. |
| BUG-001 | **E3** | Tras reiniciar | INC-101 sigue `Resuelta` después de recargar. |
| BUG-001 | **E4** | Después | Incidencia nueva "Prueba BUG-001" en la lista (11 registros). |
| BUG-001 | **E5** | Tras reiniciar | La incidencia nueva sigue en la lista tras recargar. |
| BUG-003 | **E6** | Antes | Tablero 5 / 2 / 3 y "10 registros". |
| BUG-003 | **E7** | Después | INC-104 → Pendiente: tablero 6 / 2 / 2 y "10 registros". |
| BUG-003 | **E8** | Después | INC-104 → Resuelta de nuevo: tablero 5 / 2 / 3. |
| BUG-003 | **E9** | Después | Tras registrar un caso nuevo: Pendientes +1 y la suma igual a los registros. |
| BUG-003 | **E10** | Tras reiniciar | Mismos totales que antes de recargar. |
| BUG-003 | **E11** | Con búsqueda | Búsqueda `impresora` (1 registro) y el tablero sin cambios. |
| BUG-002 | **E12** | Antes | (Del Día 1 o en `main`) `wifi` sin resultados. |
| BUG-002 | **E13** | Después | `wifi` → INC-102. |
| BUG-002 | **E14** | Después | `  wifi  ` (con espacios) → INC-102. |
| BUG-002 | **E15** | Después | `túnel` → INC-106 "Configuración de VPN". |
| BUG-002 | **E16** | Tras reiniciar | Búsqueda vacía → todos los registros. |
| Regresión | **E17** | Integrado | Prueba combinada en `main` (ver sección 6). |

## 6. Matriz de pruebas

| Ticket | Escenario | Esperado | Obtenido | ¿Pasó? |
|---|---|---|---|---|
| BUG-001 | Cambiar estado en el detalle y ver la lista | La lista muestra el nuevo estado | [ ] | [ ] |
| BUG-001 | Cerrar y abrir la app (mismo puerto) | El nuevo estado se conserva | [ ] | [ ] |
| BUG-001 | Registrar incidencia nueva y reiniciar | Sigue existiendo | [ ] | [ ] |
| BUG-001 | Cambiar un registro | Los demás no cambian | [ ] | [ ] |
| BUG-001 | Prueba automática `gestor_persistencia_test.dart` | Pasa | Pasa (3/3) | Sí |
| BUG-003 | Totales = conteo manual de la lista | Coinciden | [ ] | [ ] |
| BUG-003 | Pendiente → Resuelta | Pendientes −1, Resueltas +1 | [ ] | [ ] |
| BUG-003 | Resuelta → Pendiente | Pendientes +1, Resueltas −1 | [ ] | [ ] |
| BUG-003 | Registrar caso nuevo | Pendientes +1 | [ ] | [ ] |
| BUG-003 | Reiniciar | Totales iguales a los datos | [ ] | [ ] |
| BUG-003 | Con texto en la búsqueda | Los totales no cambian | [ ] | [ ] |
| BUG-003 | Prueba automática `gestor_totales_test.dart` | Pasa | Pasa (5/5) | Sí |
| BUG-002 | Buscar `wifi` | INC-102 | [ ] | [ ] |
| BUG-002 | Buscar `WiFi` | INC-102 | [ ] | [ ] |
| BUG-002 | Buscar `  wifi  ` | INC-102 | [ ] | [ ] |
| BUG-002 | Buscar `túnel` | INC-106 | [ ] | [ ] |
| BUG-002 | Búsqueda vacía | Todos los registros | [ ] | [ ] |
| BUG-002 | Prueba automática `gestor_busqueda_test.dart` | Pasa | Pasa (4/4) | Sí |
| Regresión | Los 3 bugs corregidos juntos en `main` | Todo lo anterior se cumple | [ ] | [ ] |
| Regresión | Crear, abrir detalle, cambiar estado, buscar | Funcionan | [ ] | [ ] |
| Regresión | Restablecer demostración | Vuelve a 10 registros, tablero 5 / 2 / 3 | [ ] | [ ] |
| Regresión | Pruebas automáticas integradas | 13/13 pasan | Pasa (13/13, rama temporal) | Sí |

## 7. Uso de IA

| Aspecto | Detalle |
|---|---|
| Herramienta | Claude Code (asistente de programación en la app de escritorio de Claude). |
| Objetivo | Completar la documentación del Día 1, encontrar la causa raíz de BUG-001/002/003, aplicar correcciones mínimas con pruebas unitarias y preparar el material de la bitácora. |
| Resumen del prompt | Instrucciones de la práctica: no rehacer la app, no tocar `lib/` ni `assets/` salvo cambios mínimos, una rama por ticket, commits descriptivos, explicar la causa raíz antes de cambiar código, no inventar resultados y no tocar FEAT-001/FEAT-002. |
| Contenido compartido | Código fuente del proyecto de entrenamiento y el JSON de datos **ficticios**. |
| Confidencialidad | Datos 100 % ficticios; no se compartieron secretos, contraseñas, credenciales ni datos personales. La IA trabajó sobre el repositorio local. |
| Sugerencias aceptadas | [Revisar] Correcciones de los tres bugs; pruebas unitarias con almacén en memoria; uso de `--web-port` fijo para pruebas de persistencia; commits separados para los cambios automáticos de Flutter. |
| Sugerencias rechazadas / modificadas | Rechacé ejecutar las pruebas en Chrome (`flutter test --platform chrome`) y preferí ajustar yo mismo Smart App Control para usar `flutter test` normal. Tolerancia a acentos en la búsqueda: [aceptada / rechazada / pendiente]. |
| Verificación propia | Pruebas automáticas ejecutadas localmente (incluida la comprobación de que fallaban sin la corrección) y pruebas manuales en Chrome de la sección 6, con capturas E1–E17. |

## 8. Cierre

- **Tickets concluidos:** [BUG-001, BUG-002, BUG-003, una vez pasadas las pruebas manuales e integrados en `main`].
- **Bloqueos:** `flutter test` estaba bloqueado por Smart App Control de Windows (resuelto). [Otros, si los hubo].
- **Pendiente de decisión:** tolerancia a acentos en la búsqueda (`tunel` ↔ `túnel`).
- **Primer paso del Día 3:** crear la rama `feat/prioridades` desde `main` e iniciar FEAT-001 (prioridad de incidencias).
