import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// BUG-002: la búsqueda ignora mayúsculas, espacios sobrantes y revisa
// título y descripción.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GestorIncidencias g;

  List<String> ids(String texto) => g.buscar(texto).map((x) => x.id).toList();

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    g = GestorIncidencias();
    await g.iniciar();
  });

  test('Ignora mayúsculas y minúsculas', () {
    expect(ids('wifi'), ['INC-102']);
    expect(ids('WiFi'), ['INC-102']);
    expect(ids('WIFI'), ['INC-102']);
  });

  test('Ignora espacios al inicio y al final', () {
    expect(ids('  wifi  '), ['INC-102']);
  });

  test('Busca también en la descripción', () {
    expect(ids('túnel'), ['INC-106']);
  });

  test('Texto vacío o solo espacios devuelve todos los registros', () {
    expect(g.buscar('').length, 10);
    expect(g.buscar('   ').length, 10);
  });
}
