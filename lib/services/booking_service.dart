import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import 'dio_client.dart';

class BookingService {
  final DioClient _client = DioClient();

  // ============================================
  // ÁREAS COMUNES
  // ============================================

  Future<List<AreaComun>> getAllAreas({Map<String, dynamic>? filters}) async {
    try {
      final response = await _client.get(
        '/api/booking/areas',
        queryParameters: filters,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => AreaComun.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AreaComun> getAreaById(int id) async {
    try {
      final response = await _client.get('/api/booking/areas/$id');
      return AreaComun.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AreaComun> createArea({
    required String nombre,
    required String descripcion,
    required int capacidad,
    required double costoReserva,
    String? imagenUrl,
    bool requiereAprobacion = false,
    bool activa = true,
  }) async {
    try {
      final response = await _client.post(
        '/api/booking/areas',
        data: {
          'nombre': nombre,
          'descripcion': descripcion,
          'capacidad': capacidad,
          'costoReserva': costoReserva,
          if (imagenUrl != null) 'imagenUrl': imagenUrl,
          'requiereAprobacion': requiereAprobacion,
          'activa': activa,
        },
      );
      return AreaComun.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AreaComun> updateArea({
    required int id,
    String? nombre,
    String? descripcion,
    int? capacidad,
    double? costoReserva,
    String? imagenUrl,
    bool? requiereAprobacion,
    bool? activa,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (descripcion != null) data['descripcion'] = descripcion;
      if (capacidad != null) data['capacidad'] = capacidad;
      if (costoReserva != null) data['costoReserva'] = costoReserva;
      if (imagenUrl != null) data['imagenUrl'] = imagenUrl;
      if (requiereAprobacion != null)
        data['requiereAprobacion'] = requiereAprobacion;
      if (activa != null) data['activa'] = activa;

      final response = await _client.patch(
        '/api/booking/areas/$id',
        data: data,
      );
      return AreaComun.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteArea(int id) async {
    try {
      await _client.delete('/api/booking/areas/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AreaComun> toggleActiveArea(int id) async {
    try {
      final response = await _client.patch(
        '/api/booking/areas/$id/toggle-active',
      );
      return AreaComun.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ============================================
  // RESERVAS
  // ============================================

  Future<List<Reserva>> getAllReservas({Map<String, dynamic>? filters}) async {
    try {
      final response = await _client.get(
        '/api/booking/reservas',
        queryParameters: filters,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Reserva.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Reserva> getReservaById(int id) async {
    try {
      final response = await _client.get('/api/booking/reservas/$id');
      return Reserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Reserva>> getReservasByUser(String usuarioId) async {
    try {
      final response = await _client.get(
        '/api/booking/reservas/usuario/$usuarioId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Reserva.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Reserva>> getReservasByArea(int areaId) async {
    try {
      final response = await _client.get('/api/booking/reservas/area/$areaId');
      final List<dynamic> data = response.data;
      return data.map((json) => Reserva.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Reserva> createReserva({
    required String usuarioId,
    required int areaId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? notas,
  }) async {
    try {
      final response = await _client.post(
        '/api/booking/reservas',
        data: {
          'usuarioId': usuarioId,
          'areaId': areaId,
          'fechaInicio': fechaInicio.toIso8601String(),
          'fechaFin': fechaFin.toIso8601String(),
          if (notas != null) 'notas': notas,
        },
      );
      return Reserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Reserva> updateReserva({
    required int id,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    String? notas,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fechaInicio != null)
        data['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) data['fechaFin'] = fechaFin.toIso8601String();
      if (estado != null) data['estado'] = estado;
      if (notas != null) data['notas'] = notas;

      final response = await _client.patch(
        '/api/booking/reservas/$id',
        data: data,
      );
      return Reserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Reserva> confirmReserva(int id) async {
    try {
      final response = await _client.post(
        '/api/booking/reservas/$id/confirmar',
      );
      return Reserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Reserva> cancelReserva(int id, {String? motivo}) async {
    try {
      final response = await _client.post(
        '/api/booking/reservas/$id/cancelar',
        data: {'motivo': motivo},
      );
      return Reserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Reserva> completeReserva(int id) async {
    try {
      final response = await _client.post(
        '/api/booking/reservas/$id/completar',
      );
      return Reserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteReserva(int id) async {
    try {
      await _client.delete('/api/booking/reservas/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> checkDisponibilidad({
    required int areaId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final response = await _client.post(
        '/api/booking/reservas/check-disponibilidad',
        data: {
          'areaId': areaId,
          'fechaInicio': fechaInicio.toIso8601String(),
          'fechaFin': fechaFin.toIso8601String(),
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ============================================
  // BLOQUEOS
  // ============================================

  Future<List<Bloqueo>> getAllBloqueos() async {
    try {
      final response = await _client.get('/api/booking/bloqueos');
      final List<dynamic> data = response.data;
      return data.map((json) => Bloqueo.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Bloqueo> getBloqueoById(int id) async {
    try {
      final response = await _client.get('/api/booking/bloqueos/$id');
      return Bloqueo.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Bloqueo>> getBloqueosByArea(int areaId) async {
    try {
      final response = await _client.get('/api/booking/bloqueos/area/$areaId');
      final List<dynamic> data = response.data;
      return data.map((json) => Bloqueo.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Bloqueo> createBloqueo({
    required int areaId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String motivo,
  }) async {
    try {
      final response = await _client.post(
        '/api/booking/bloqueos',
        data: {
          'areaId': areaId,
          'fechaInicio': fechaInicio.toIso8601String(),
          'fechaFin': fechaFin.toIso8601String(),
          'motivo': motivo,
        },
      );
      return Bloqueo.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Bloqueo> updateBloqueo({
    required int id,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? motivo,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fechaInicio != null)
        data['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) data['fechaFin'] = fechaFin.toIso8601String();
      if (motivo != null) data['motivo'] = motivo;

      final response = await _client.patch(
        '/api/booking/bloqueos/$id',
        data: data,
      );
      return Bloqueo.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteBloqueo(int id) async {
    try {
      await _client.delete('/api/booking/bloqueos/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
