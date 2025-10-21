class Empleado {
  final String id;
  final String nombre;
  final String apellido;
  final String ci;
  final String email;
  final String telefono;
  final String departamento;
  final String cargo;
  final double salarioBase;
  final String estado;
  final DateTime fechaContratacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Empleado({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.ci,
    required this.email,
    required this.telefono,
    required this.departamento,
    required this.cargo,
    required this.salarioBase,
    required this.estado,
    required this.fechaContratacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      ci: json['ci'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      departamento: json['departamento'] ?? '',
      cargo: json['cargo'] ?? '',
      salarioBase: (json['salarioBase'] ?? 0).toDouble(),
      estado: json['estado'] ?? 'activo',
      fechaContratacion: DateTime.parse(
        json['fechaContratacion'] ?? DateTime.now().toIso8601String(),
      ),
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
      'apellido': apellido,
      'ci': ci,
      'email': email,
      'telefono': telefono,
      'departamento': departamento,
      'cargo': cargo,
      'salarioBase': salarioBase,
      'estado': estado,
      'fechaContratacion': fechaContratacion.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get nombreCompleto => '$nombre $apellido';
}

class PagoNomina {
  final String id;
  final String empleadoId;
  final String periodo;
  final double salarioBase;
  final double bonos;
  final double deducciones;
  final double horasExtras;
  final double totalPagar;
  final String estado;
  final DateTime? fechaPago;
  final String? metodoPago;
  final String? comprobantePago;
  final Empleado? empleado;
  final DateTime createdAt;
  final DateTime updatedAt;

  PagoNomina({
    required this.id,
    required this.empleadoId,
    required this.periodo,
    required this.salarioBase,
    this.bonos = 0,
    this.deducciones = 0,
    this.horasExtras = 0,
    required this.totalPagar,
    required this.estado,
    this.fechaPago,
    this.metodoPago,
    this.comprobantePago,
    this.empleado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PagoNomina.fromJson(Map<String, dynamic> json) {
    return PagoNomina(
      id: json['id'] ?? '',
      empleadoId: json['empleadoId'] ?? '',
      periodo: json['periodo'] ?? '',
      salarioBase: (json['salarioBase'] ?? 0).toDouble(),
      bonos: (json['bonos'] ?? 0).toDouble(),
      deducciones: (json['deducciones'] ?? 0).toDouble(),
      horasExtras: (json['horasExtras'] ?? 0).toDouble(),
      totalPagar: (json['totalPagar'] ?? 0).toDouble(),
      estado: json['estado'] ?? 'pendiente',
      fechaPago: json['fechaPago'] != null
          ? DateTime.parse(json['fechaPago'])
          : null,
      metodoPago: json['metodoPago'],
      comprobantePago: json['comprobantePago'],
      empleado: json['empleado'] != null
          ? Empleado.fromJson(json['empleado'])
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
      'empleadoId': empleadoId,
      'periodo': periodo,
      'salarioBase': salarioBase,
      'bonos': bonos,
      'deducciones': deducciones,
      'horasExtras': horasExtras,
      'totalPagar': totalPagar,
      'estado': estado,
      'fechaPago': fechaPago?.toIso8601String(),
      'metodoPago': metodoPago,
      'comprobantePago': comprobantePago,
      'empleado': empleado?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Asistencia {
  final String id;
  final String empleadoId;
  final DateTime fecha;
  final String? horaEntrada;
  final String? horaSalida;
  final String estado;
  final String? observaciones;
  final Empleado? empleado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Asistencia({
    required this.id,
    required this.empleadoId,
    required this.fecha,
    this.horaEntrada,
    this.horaSalida,
    required this.estado,
    this.observaciones,
    this.empleado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'] ?? '',
      empleadoId: json['empleadoId'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      horaEntrada: json['horaEntrada'],
      horaSalida: json['horaSalida'],
      estado: json['estado'] ?? 'presente',
      observaciones: json['observaciones'],
      empleado: json['empleado'] != null
          ? Empleado.fromJson(json['empleado'])
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
      'empleadoId': empleadoId,
      'fecha': fecha.toIso8601String(),
      'horaEntrada': horaEntrada,
      'horaSalida': horaSalida,
      'estado': estado,
      'observaciones': observaciones,
      'empleado': empleado?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
