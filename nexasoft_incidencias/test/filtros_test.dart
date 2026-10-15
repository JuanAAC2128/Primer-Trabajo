import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/main.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// FEAT-002: filtros combinables por texto, estado y prioridad.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GestorIncidencias.filtrar', () {
    late GestorIncidencias g;

    List<String> ids(List<Incidencia> lista) => lista.map((x) => x.id).toList();

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      g = GestorIncidencias();
      await g.iniciar();
    });

    test('Sin texto, Todos y Todas → los 10 registros', () {
      expect(g.filtrar('').length, 10);
    });

    test('Solo estado Pendiente → las 5 Pendientes', () {
      final r = g.filtrar('', estado: 'Pendiente');
      expect(r.length, 5);
      expect(r.every((x) => x.estado == 'Pendiente'), isTrue);
    });

    test('Solo prioridad Alta → solo las de prioridad Alta', () async {
      await g.cambiarPrioridad('INC-102', Prioridad.alta);
      expect(ids(g.filtrar('', prioridad: Prioridad.alta)), ['INC-102']);
    });

    test('Texto + estado + prioridad combinados', () async {
      await g.cambiarPrioridad('INC-101', Prioridad.alta); // Impresora, Pendiente
      await g.cambiarPrioridad('INC-103', Prioridad.alta); // Pantalla azul, Pendiente
      await g.cambiarPrioridad('INC-102', Prioridad.alta); // WiFi, En proceso

      expect(ids(g.filtrar('impresora', estado: 'Pendiente', prioridad: Prioridad.alta)),
          ['INC-101']);
      expect(ids(g.filtrar('', estado: 'Pendiente', prioridad: Prioridad.alta)),
          ['INC-101', 'INC-103']);
    });

    test('Combinación sin coincidencias → lista vacía, sin excepción', () {
      // INC-102 (WiFi) está En proceso, no Pendiente.
      expect(g.filtrar('wifi', estado: 'Pendiente'), isEmpty);
      expect(g.filtrar('', prioridad: Prioridad.alta), isEmpty);
    });

    test('Con filtros activos, contar() da los mismos totales', () async {
      final antes = [for (final e in ['Pendiente', 'En proceso', 'Resuelta']) g.contar(e)];
      final filtrada = g.filtrar('impresora', estado: 'Pendiente', prioridad: Prioridad.media);
      expect(filtrada.length, lessThan(g.incidencias.length));
      final despues = [for (final e in ['Pendiente', 'En proceso', 'Resuelta']) g.contar(e)];
      expect(despues, antes);
      expect(despues, [5, 2, 3]);
    });

    test('Texto con mayúsculas y espacios + filtro (BUG-002 sigue corregido)', () {
      expect(ids(g.filtrar('  WIFI ', estado: 'En proceso')), ['INC-102']);
      expect(ids(g.filtrar('TÚNEL', prioridad: Prioridad.media)), ['INC-106']);
    });
  });

  group('Pantalla principal', () {
    setUp(() {
      // Datos ya guardados (la semilla) para no depender de la carga de assets.
      final semilla = File('assets/data/incidencias.json').readAsStringSync();
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({'nexasoft_incidencias_v1': semilla});
    });

    testWidgets('Cero resultados muestra mensaje y "Limpiar filtros" restablece',
        (tester) async {
      await tester.pumpWidget(const NexaSoftApp());
      await tester.pumpAndSettle();
      expect(find.text('10 registros'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(find.text('0 registros'), findsOneWidget);
      expect(find.text('No hay incidencias que coincidan con la búsqueda y los filtros'),
          findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Limpiar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('10 registros'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
    });

    testWidgets('Filtro de estado y limpiar regresa a Todos', (tester) async {
      await tester.pumpWidget(const NexaSoftApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pendiente').last);
      await tester.pumpAndSettle();
      expect(find.text('5 registros'), findsOneWidget);
      // El tablero no cambia con el filtro.
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Limpiar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('10 registros'), findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
    });
  });
}
