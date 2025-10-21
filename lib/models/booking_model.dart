class AreaComun {
  final int id;
  final String nombre;
  final String descripcion;
  final int capacidad;
  final double costoReserva;
  final String? imagenUrl;
  final bool requiereAprobacion;
  final bool activa;
  final DateTime createdAt;
  final DateTime updatedAt;

  AreaComun({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.capacidad,
    required this.costoReserva,
    this.imagenUrl,
    this.requiereAprobacion = false,
    this.activa = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) {
    return AreaComun(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      capacidad: json['capacidad'] ?? 0,
      costoReserva: (json['costoReserva'] ?? 0).toDouble(),
      imagenUrl: json['imagenUrl'],
      requiereAprobacion: json['requiereAprobacion'] ?? false,
      activa: json['activa'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'capacidad': capacidad,
      'costoReserva': costoReserva,
      'imagenUrl': imagenUrl,
      'requiereAprobacion': requiereAprobacion,
      'activa': activa,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Reserva {
  final int id;
  final String usuarioId;
  final int areaId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final String? notas;
  final AreaComun? area;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reserva({
    required this.id,
    required this.usuarioId,
    required this.areaId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    this.notas,
    this.area,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? '',
      areaId: json['areaId'] ?? 0,
      fechaInicio: DateTime.parse(
        json['fechaInicio'] ?? DateTime.now().toIso8601String(),
      ),
      fechaFin: DateTime.parse(
        json['fechaFin'] ?? DateTime.now().toIso8601String(),
      ),
      estado: json['estado'] ?? 'pendiente',
      notas: json['notas'],
      area: json['area'] != null ? AreaComun.fromJson(json['area']) : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'areaId': areaId,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'estado': estado,
      'notas': notas,
      'area': area?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Bloqueo {
  final int id;
  final int areaId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String motivo;
  final AreaComun? area;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bloqueo({
    required this.id,
    required this.areaId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.motivo,
    this.area,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bloqueo.fromJson(Map<String, dynamic> json) {
    return Bloqueo(
      id: json['id'] ?? 0,
      areaId: json['areaId'] ?? 0,
      fechaInicio: DateTime.parse(
        json['fechaInicio'] ?? DateTime.now().toIso8601String(),
      ),
      fechaFin: DateTime.parse(
        json['fechaFin'] ?? DateTime.now().toIso8601String(),
      ),
      motivo: json['motivo'] ?? '',
      area: json['area'] != null ? AreaComun.fromJson(json['area']) : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'areaId': areaId,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'motivo': motivo,
      'area': area?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
