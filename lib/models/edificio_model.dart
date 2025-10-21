class Edificio {
  final String id;
  final String nombre;
  final String direccion;
  final int numeroHabitaciones;
  final int numeroGarajes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Edificio({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.numeroHabitaciones,
    required this.numeroGarajes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Edificio.fromJson(Map<String, dynamic> json) {
    return Edificio(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      numeroHabitaciones: json['numeroHabitaciones'] ?? 0,
      numeroGarajes: json['numeroGarajes'] ?? 0,
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
      'direccion': direccion,
      'numeroHabitaciones': numeroHabitaciones,
      'numeroGarajes': numeroGarajes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Habitacion {
  final String id;
  final String numero;
  final String tipo;
  final double area;
  final int habitaciones;
  final int banos;
  final String estado;
  final String edificioId;
  final String? usuarioId;
  final Edificio? edificio;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habitacion({
    required this.id,
    required this.numero,
    required this.tipo,
    required this.area,
    required this.habitaciones,
    required this.banos,
    required this.estado,
    required this.edificioId,
    this.usuarioId,
    this.edificio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habitacion.fromJson(Map<String, dynamic> json) {
    return Habitacion(
      id: json['id'] ?? '',
      numero: json['numero'] ?? '',
      tipo: json['tipo'] ?? '',
      area: (json['area'] ?? 0).toDouble(),
      habitaciones: json['habitaciones'] ?? 0,
      banos: json['banos'] ?? 0,
      estado: json['estado'] ?? 'disponible',
      edificioId: json['edificioId'] ?? '',
      usuarioId: json['usuarioId'],
      edificio: json['edificio'] != null
          ? Edificio.fromJson(json['edificio'])
          : null,
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
      'numero': numero,
      'tipo': tipo,
      'area': area,
      'habitaciones': habitaciones,
      'banos': banos,
      'estado': estado,
      'edificioId': edificioId,
      'usuarioId': usuarioId,
      'edificio': edificio?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Garaje {
  final String id;
  final String numero;
  final String tipo;
  final String estado;
  final String edificioId;
  final String? usuarioId;
  final Edificio? edificio;
  final DateTime createdAt;
  final DateTime updatedAt;

  Garaje({
    required this.id,
    required this.numero,
    required this.tipo,
    required this.estado,
    required this.edificioId,
    this.usuarioId,
    this.edificio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Garaje.fromJson(Map<String, dynamic> json) {
    return Garaje(
      id: json['id'] ?? '',
      numero: json['numero'] ?? '',
      tipo: json['tipo'] ?? 'simple',
      estado: json['estado'] ?? 'disponible',
      edificioId: json['edificioId'] ?? '',
      usuarioId: json['usuarioId'],
      edificio: json['edificio'] != null
          ? Edificio.fromJson(json['edificio'])
          : null,
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
      'numero': numero,
      'tipo': tipo,
      'estado': estado,
      'edificioId': edificioId,
      'usuarioId': usuarioId,
      'edificio': edificio?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class EstadisticasEdificio {
  final int totalHabitaciones;
  final int habitacionesOcupadas;
  final int habitacionesDisponibles;
  final int totalGarajes;
  final int garajesOcupados;
  final int garajesDisponibles;
  final double tasaOcupacion;

  EstadisticasEdificio({
    required this.totalHabitaciones,
    required this.habitacionesOcupadas,
    required this.habitacionesDisponibles,
    required this.totalGarajes,
    required this.garajesOcupados,
    required this.garajesDisponibles,
    required this.tasaOcupacion,
  });

  factory EstadisticasEdificio.fromJson(Map<String, dynamic> json) {
    return EstadisticasEdificio(
      totalHabitaciones: json['totalHabitaciones'] ?? 0,
      habitacionesOcupadas: json['habitacionesOcupadas'] ?? 0,
      habitacionesDisponibles: json['habitacionesDisponibles'] ?? 0,
      totalGarajes: json['totalGarajes'] ?? 0,
      garajesOcupados: json['garajesOcupados'] ?? 0,
      garajesDisponibles: json['garajesDisponibles'] ?? 0,
      tasaOcupacion: (json['tasaOcupacion'] ?? 0).toDouble(),
    );
  }
}
