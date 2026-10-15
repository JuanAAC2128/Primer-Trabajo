enum Prioridad {
  baja('Baja'),
  media('Media'),
  alta('Alta');

  const Prioridad(this.etiqueta);
  final String etiqueta;

  // Registros antiguos sin prioridad o con un valor no reconocido usan Media.
  static Prioridad desdeTexto(Object? valor) {
    final texto = valor?.toString().trim().toLowerCase() ?? '';
    for (final p in Prioridad.values) {
      if (p.etiqueta.toLowerCase() == texto) return p;
    }
    return Prioridad.media;
  }
}

class Incidencia {
  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  Prioridad prioridad;

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    this.prioridad = Prioridad.media,
  });

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: m['estado']?.toString() ?? 'Pendiente',
      fecha: m['fecha']?.toString() ?? '',
      prioridad: Prioridad.desdeTexto(m['prioridad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      'prioridad': prioridad.etiqueta,
    };
  }
}
