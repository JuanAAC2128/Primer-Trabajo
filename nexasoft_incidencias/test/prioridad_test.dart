import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// FEAT-001: prioridad Baja/Media/Alta, persistencia y compatibilidad con
// registros antiguos sin prioridad.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> registroAntiguo() => {
        'id': 'INC-OLD',
        'titulo': 'Registro antiguo',
        'descripcion': 'Sin prioridad',
        'cliente': 'Cliente ficticio',
        'categoria': 'Redes',
        'estado': 'En proceso',
        'fecha': '2026-10-01',
      };

  Future<GestorIncidencias> reiniciarApp() async {
    final g = GestorIncidencias();
    await g.iniciar();
    return g;
  }

  group('Modelo (desdeJson / toJson)', () {
    test('Sin clave prioridad → Media', () {
      expect(Incidencia.desdeJson(registroAntiguo()).prioridad, Prioridad.media);
    });

    test('prioridad null o vacía → Media', () {
      for (final valor in [null, '', '   ']) {
        final m = registroAntiguo()..['prioridad'] = valor;
        expect(Incidencia.desdeJson(m).prioridad, Prioridad.media, reason: '$valor');
      }
    });

    test('Valor inválido ("Urgente") → Media, sin excepción', () {
      final m = registroAntiguo()..['prioridad'] = 'Urgente';
      expect(Incidencia.desdeJson(m).prioridad, Prioridad.media);
    });

    test('Variantes de mayúsculas y espacios se reconocen', () {
      for (final valor in ['alta', 'ALTA', ' Alta ']) {
        final m = registroAntiguo()..['prioridad'] = valor;
        expect(Incidencia.desdeJson(m).prioridad, Prioridad.alta, reason: valor);
      }
    });

    test('Ida y vuelta toJson → desdeJson conserva Alta', () {
      final original = Incidencia.desdeJson(registroAntiguo())
        ..prioridad = Prioridad.alta;
      final json = original.toJson();
      expect(json['prioridad'], 'Alta');
      expect(Incidencia.desdeJson(json).prioridad, Prioridad.alta);
    });
  });

  group('Gestor y persistencia', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('Crear con Alta y reiniciar → sigue en Alta', () async {
      final g = await reiniciarApp();
      await g.crear('Prueba FEAT-001', 'Descripción ficticia', 'Cliente demo',
          'Software', Prioridad.alta);
      final id = g.incidencias.first.id;

      final reiniciado = await reiniciarApp();
      expect(reiniciado.porId(id)!.prioridad, Prioridad.alta);
    });

    test('Cambiar prioridad de INC-101 y reiniciar → se conserva', () async {
      final g = await reiniciarApp();
      expect(g.porId('INC-101')!.prioridad, Prioridad.media);

      await g.cambiarPrioridad('INC-101', Prioridad.baja);

      final reiniciado = await reiniciarApp();
      expect(reiniciado.porId('INC-101')!.prioridad, Prioridad.baja);
    });

    test('Cambiar prioridad no altera otros registros ni el estado', () async {
      final g = await reiniciarApp();
      final antes = {
        for (final x in g.incidencias) x.id: (x.estado, x.prioridad),
      };

      await g.cambiarPrioridad('INC-101', Prioridad.alta);

      final reiniciado = await reiniciarApp();
      for (final x in reiniciado.incidencias) {
        if (x.id == 'INC-101') {
          expect(x.estado, antes[x.id]!.$1);
          expect(x.prioridad, Prioridad.alta);
        } else {
          expect((x.estado, x.prioridad), antes[x.id], reason: x.id);
        }
      }
    });

    test('Almacén con formato antiguo carga en Media y conserva el estado',
        () async {
      final antiguos = [
        registroAntiguo(),
        {...registroAntiguo(), 'id': 'INC-OLD-2', 'estado': 'Resuelta'},
      ];
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(
              {'nexasoft_incidencias_v1': jsonEncode(antiguos)});

      final g = await reiniciarApp();
      expect(g.incidencias.length, 2);
      expect(g.incidencias.every((x) => x.prioridad == Prioridad.media), isTrue);
      expect(g.porId('INC-OLD')!.estado, 'En proceso');
      expect(g.porId('INC-OLD-2')!.estado, 'Resuelta');
    });

    test('La semilla (sin prioridad) carga todas en Media', () async {
      final g = await reiniciarApp();
      expect(g.incidencias.length, 10);
      expect(g.incidencias.every((x) => x.prioridad == Prioridad.media), isTrue);
    });
  });
}
