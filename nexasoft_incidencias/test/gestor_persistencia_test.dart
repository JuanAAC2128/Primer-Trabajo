import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// BUG-001: los cambios deben sobrevivir a un reinicio (nuevo GestorIncidencias
// que vuelve a leer el almacenamiento local).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<GestorIncidencias> reiniciarApp() async {
    final g = GestorIncidencias();
    await g.iniciar();
    return g;
  }

  test('El cambio de estado se conserva tras reiniciar', () async {
    final g = await reiniciarApp();
    expect(g.porId('INC-101')!.estado, 'Pendiente');

    await g.cambiarEstado('INC-101', 'Resuelta');
    expect(g.porId('INC-101')!.estado, 'Resuelta');

    final reiniciado = await reiniciarApp();
    expect(reiniciado.porId('INC-101')!.estado, 'Resuelta');
  });

  test('Una incidencia nueva sigue existiendo tras reiniciar', () async {
    final g = await reiniciarApp();
    await g.crear('Prueba BUG-001', 'Descripción ficticia', 'Cliente demo', 'Redes');
    final id = g.incidencias.first.id;

    final reiniciado = await reiniciarApp();
    expect(reiniciado.incidencias.length, 11);
    expect(reiniciado.porId(id)?.titulo, 'Prueba BUG-001');
  });

  test('Cambiar el estado de un registro no altera los demás', () async {
    final g = await reiniciarApp();
    final antes = {for (final x in g.incidencias) x.id: x.estado};

    await g.cambiarEstado('INC-101', 'Resuelta');

    final reiniciado = await reiniciarApp();
    for (final x in reiniciado.incidencias) {
      if (x.id != 'INC-101') expect(x.estado, antes[x.id], reason: x.id);
    }
  });
}
