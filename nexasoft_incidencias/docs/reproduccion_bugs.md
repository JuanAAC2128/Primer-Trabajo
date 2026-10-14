# Reproducción de bugs — Práctica 01 (estado heredado, sin corregir)

> Pasos redactados con base en el código del commit inicial y en lo observado en el Día 1.
> Datos de partida: semilla `assets/data/incidencias.json` → 10 incidencias: **5 Pendientes** (INC-101, 103, 105, 108, 110), **2 En proceso** (INC-102, 106), **3 Resueltas** (INC-104, 107, 109).

## Preparación común (antes de cada bug)

1. Ejecutar la app en Chrome con **puerto fijo**: `flutter run -d chrome --web-port=8080`.
   (Sin `--web-port`, cada `flutter run` puede usar otro puerto y el navegador trata los datos guardados como de otro sitio; eso también hace "desaparecer" registros y confundiría la prueba).
2. Pulsar **Restablecer demostración** (ícono de flecha circular) → **Restablecer**, para partir de la semilla.
3. Verificar tablero: Pendientes **5**, En proceso **2**, Resueltas **3**; texto "10 registros".

"**Recargar**" en este documento = recargar la pestaña de Chrome (F5) o hot restart (`R` en la terminal de `flutter run`). Ambos vuelven a ejecutar `iniciar()` y leen el almacenamiento local.

---

## BUG-001 — El cambio de estado no se conserva tras recargar

**Pasos (caso A: cambio de estado):**
1. Preparación común.
2. Abrir **INC-101** "Impresora del almacén no responde" (estado `Pendiente`).
3. En "Estado actual" elegir **Resuelta**.
4. Volver a la lista: INC-101 aparece como `Resuelta`.
5. **No registrar ninguna incidencia nueva** (ver nota) y recargar la app.
6. Buscar/abrir de nuevo INC-101.

- **Observado:** INC-101 vuelve a `Pendiente`.
- **Esperado:** INC-101 sigue `Resuelta` después de recargar.

**Pasos (caso B: incidencia nueva):**
1. Preparación común.
2. Pulsar **Nueva incidencia**, llenar Título `Prueba BUG-001`, Descripción, Cliente (datos ficticios) y **Registrar**.
3. Verificar que aparece arriba en la lista ("11 registros").
4. Recargar la app **en el mismo puerto**.

- **Observado en Día 1:** la incidencia nueva desapareció.
- **Esperado:** la incidencia nueva sigue en la lista tras recargar.
- **Nota técnica:** según el código, `crear()` **sí** guarda (`await datos.guardar(incidencias)`), así que con el mismo puerto el registro nuevo debería conservarse. La causa más probable de lo observado en el Día 1 es haber relanzado con `flutter run` (puerto distinto → `localStorage` distinto → se vuelve a cargar la semilla) o haber pulsado "Restablecer demostración". **Pendiente de confirmar** repitiendo el caso B con `--web-port=8080`.
- **Nota 2:** como `crear()` guarda la lista completa, si después de cambiar un estado se registra una incidencia, ese cambio de estado *sí* queda guardado "por accidente". Por eso el caso A no debe crear registros.

**Capturas que debes tomar (BUG-001):**

| ID | Qué debe verse |
|---|---|
| E-001-a | Lista con INC-101 en `Pendiente` (antes del cambio). |
| E-001-b | Detalle de INC-101 con el Dropdown en `Resuelta` y la lista mostrando `Resuelta`. |
| E-001-c | Tras recargar: INC-101 otra vez en `Pendiente` (falla). |
| E-001-d | Caso B: incidencia nueva en la lista y "11 registros". |
| E-001-e | Caso B tras recargar en el mismo puerto (mostrar la URL con `:8080`). |

---

## BUG-002 — La búsqueda omite registros existentes

**Pasos:**
1. Preparación común.
2. En "Buscar incidencias" escribir `wifi` (minúsculas).
3. Borrar y escribir `WiFi` (mayúsculas exactas).
4. Borrar y escribir `  WiFi  ` (con espacios al inicio y al final).
5. Borrar y escribir `túnel` (palabra que solo está en la descripción de INC-106 "Configuración de VPN").

| Búsqueda | Observado | Esperado |
|---|---|---|
| `wifi` | 0 registros ("No se encontraron incidencias") | INC-102 |
| `WiFi` | INC-102 | INC-102 |
| `  WiFi  ` | 0 registros | INC-102 |
| `túnel` | 0 registros | INC-106 |
| *(vacío)* | 10 registros | 10 registros |

**Capturas que debes tomar (BUG-002):**

| ID | Qué debe verse |
|---|---|
| E-002-a | Búsqueda `wifi` → "0 registros / No se encontraron incidencias". |
| E-002-b | Búsqueda `WiFi` → aparece INC-102. |
| E-002-c | Búsqueda `túnel` → sin resultados. |

---

## BUG-003 — El tablero no coincide con la lista

**Pasos (caso 9 vs 10):**
1. Preparación común (tablero 5 / 2 / 3 = 10; "10 registros").
2. Abrir **INC-104** "No llegan correos de confirmación" (`Resuelta`) y cambiarla a **Pendiente**.
3. Volver a la lista y contar a mano los `Pendiente` (deben ser 6).

- **Observado:** Pendientes **5**, En proceso 2, Resueltas **2** → suma **9**, mientras la lista dice **10 registros**.
- **Esperado:** Pendientes **6**, En proceso 2, Resueltas 2 → suma **10** = "10 registros".

**Pasos (caso inverso, 11 vs 10):**
1. Preparación común.
2. Cambiar **INC-101** de `Pendiente` a `Resuelta`.
- **Observado:** Pendientes **5** (no baja), Resueltas 4 → suma **11** con "10 registros".
- **Esperado:** Pendientes 4, Resueltas 4 → suma 10.

**Nota:** el desfase aparece **sin necesidad de recargar**; al recargar, `iniciar()` recalcula el contador desde los datos guardados. En el Día 1 se vio 9 vs 10 "después de recargar"; con el código actual el valor 9 se obtiene cuando una incidencia pasa **a** `Pendiente` desde otro estado.

**Capturas que debes tomar (BUG-003):**

| ID | Qué debe verse |
|---|---|
| E-003-a | Tablero inicial 5 / 2 / 3 y "10 registros". |
| E-003-b | Tras pasar INC-104 a Pendiente: tablero 5 / 2 / 2 (suma 9) vs "10 registros" y 6 tarjetas `Pendiente` visibles. |
| E-003-c | Caso inverso: tablero 5 / 2 / 4 (suma 11) vs "10 registros". |
