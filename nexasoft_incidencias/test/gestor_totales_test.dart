import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// BUG-003: los totales del tablero deben calcularse siempre desde la lista
// completa de incidencias.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GestorIncidencias g;

  int contarAMano(String estado) =>
      g.incidencias.where((x) => x.estado == estado).length;

  void expectTotalesCoinciden() {
    for (final estado in ['Pendiente', 'En proceso', 'Resuelta']) {
      expect(g.contar(estado), contarAMano(estado), reason: estado);
    }
    expect(
      g.contar('Pendiente') + g.contar('En proceso') + g.contar('Resuelta'),
      g.incidencias.length,
    );
  }

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    g = GestorIncidencias();
    await g.iniciar();
  });

  test('Totales iniciales de la semilla: 5 / 2 / 3', () {
    expect(g.contar('Pendiente'), 5);
    expect(g.contar('En proceso'), 2);
    expect(g.contar('Resuelta'), 3);
    expectTotalesCoinciden();
  });

  test('Pendiente → Resuelta actualiza los totales', () async {
    await g.cambiarEstado('INC-101', 'Resuelta');
    expect(g.contar('Pendiente'), 4);
    expect(g.contar('Resuelta'), 4);
    expectTotalesCoinciden();
  });

  test('Resuelta → Pendiente actualiza los totales (caso 9 vs 10)', () async {
    await g.cambiarEstado('INC-104', 'Pendiente');
    expect(g.contar('Pendiente'), 6);
    expect(g.contar('Resuelta'), 2);
    expectTotalesCoinciden();
  });

  test('Registrar un caso nuevo suma un Pendiente', () async {
    await g.crear('Prueba BUG-003', 'Descripción ficticia', 'Cliente demo', 'Software');
    expect(g.contar('Pendiente'), 6);
    expectTotalesCoinciden();
  });

  test('Los totales no dependen de la búsqueda', () {
    final antes = g.contar('Pendiente');
    expect(g.buscar('Impresora').length, lessThan(g.incidencias.length));
    expect(g.contar('Pendiente'), antes);
    expectTotalesCoinciden();
  });
}
