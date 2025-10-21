class PagoReserva {
  final String id;
  final String usuarioId;
  final int reservaId;
  final double monto;
  final String metodoPago;
  final String estado;
  final String? transactionId;
  final DateTime? fechaPago;
  final DateTime createdAt;
  final DateTime updatedAt;

  PagoReserva({
    required this.id,
    required this.usuarioId,
    required this.reservaId,
    required this.monto,
    required this.metodoPago,
    required this.estado,
    this.transactionId,
    this.fechaPago,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PagoReserva.fromJson(Map<String, dynamic> json) {
    return PagoReserva(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      reservaId: json['reservaId'] ?? 0,
      monto: (json['monto'] ?? 0).toDouble(),
      metodoPago: json['metodoPago'] ?? 'efectivo',
      estado: json['estado'] ?? 'pendiente',
      transactionId: json['transactionId'],
      fechaPago: json['fechaPago'] != null
          ? DateTime.parse(json['fechaPago'])
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
      'usuarioId': usuarioId,
      'reservaId': reservaId,
      'monto': monto,
      'metodoPago': metodoPago,
      'estado': estado,
      'transactionId': transactionId,
      'fechaPago': fechaPago?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PagoDano {
  final String id;
  final String usuarioId;
  final int reservaId;
  final double monto;
  final String descripcion;
  final String metodoPago;
  final String estado;
  final String? transactionId;
  final DateTime? fechaPago;
  final DateTime createdAt;
  final DateTime updatedAt;

  PagoDano({
    required this.id,
    required this.usuarioId,
    required this.reservaId,
    required this.monto,
    required this.descripcion,
    required this.metodoPago,
    required this.estado,
    this.transactionId,
    this.fechaPago,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PagoDano.fromJson(Map<String, dynamic> json) {
    return PagoDano(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      reservaId: json['reservaId'] ?? 0,
      monto: (json['monto'] ?? 0).toDouble(),
      descripcion: json['descripcion'] ?? '',
      metodoPago: json['metodoPago'] ?? 'efectivo',
      estado: json['estado'] ?? 'pendiente',
      transactionId: json['transactionId'],
      fechaPago: json['fechaPago'] != null
          ? DateTime.parse(json['fechaPago'])
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
      'usuarioId': usuarioId,
      'reservaId': reservaId,
      'monto': monto,
      'descripcion': descripcion,
      'metodoPago': metodoPago,
      'estado': estado,
      'transactionId': transactionId,
      'fechaPago': fechaPago?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Factura {
  final String id;
  final int numeroFactura;
  final String nit;
  final String razonSocial;
  final double montoTotal;
  final String estado;
  final String? pagoReservaId;
  final String? pagoDanoId;
  final DateTime fechaEmision;
  final DateTime? fechaAnulacion;
  final String? motivoAnulacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Factura({
    required this.id,
    required this.numeroFactura,
    required this.nit,
    required this.razonSocial,
    required this.montoTotal,
    required this.estado,
    this.pagoReservaId,
    this.pagoDanoId,
    required this.fechaEmision,
    this.fechaAnulacion,
    this.motivoAnulacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json['id'] ?? '',
      numeroFactura: json['numeroFactura'] ?? 0,
      nit: json['nit'] ?? '',
      razonSocial: json['razonSocial'] ?? '',
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      estado: json['estado'] ?? 'emitida',
      pagoReservaId: json['pagoReservaId'],
      pagoDanoId: json['pagoDanoId'],
      fechaEmision: DateTime.parse(
        json['fechaEmision'] ?? DateTime.now().toIso8601String(),
      ),
      fechaAnulacion: json['fechaAnulacion'] != null
          ? DateTime.parse(json['fechaAnulacion'])
          : null,
      motivoAnulacion: json['motivoAnulacion'],
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
      'numeroFactura': numeroFactura,
      'nit': nit,
      'razonSocial': razonSocial,
      'montoTotal': montoTotal,
      'estado': estado,
      'pagoReservaId': pagoReservaId,
      'pagoDanoId': pagoDanoId,
      'fechaEmision': fechaEmision.toIso8601String(),
      'fechaAnulacion': fechaAnulacion?.toIso8601String(),
      'motivoAnulacion': motivoAnulacion,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
