import 'package:dio/dio.dart';
import '../models/edificio_model.dart';
import 'dio_client.dart';

class EdificioService {
  final DioClient _client = DioClient();

  // ============================================
  // EDIFICIOS
  // ============================================

  Future<List<Edificio>> getAllEdificios() async {
    try {
      final response = await _client.get('/api/edificios');
      final List<dynamic> data = response.data;
      return data.map((json) => Edificio.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Edificio> getEdificioById(String id) async {
    try {
      final response = await _client.get('/api/edificios/$id');
      return Edificio.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Edificio> createEdificio({
    required String nombre,
    required String direccion,
    required int numeroHabitaciones,
    required int numeroGarajes,
  }) async {
    try {
      final response = await _client.post(
        '/api/edificios',
        data: {
          'nombre': nombre,
          'direccion': direccion,
          'numeroHabitaciones': numeroHabitaciones,
          'numeroGarajes': numeroGarajes,
        },
      );
      return Edificio.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Edificio> updateEdificio({
    required String id,
    String? nombre,
    String? direccion,
    int? numeroHabitaciones,
    int? numeroGarajes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (direccion != null) data['direccion'] = direccion;
      if (numeroHabitaciones != null)
        data['numeroHabitaciones'] = numeroHabitaciones;
      if (numeroGarajes != null) data['numeroGarajes'] = numeroGarajes;

      final response = await _client.put('/api/edificios/$id', data: data);
      return Edificio.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteEdificio(String id) async {
    try {
      await _client.delete('/api/edificios/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<EstadisticasEdificio> getEstadisticasEdificio(String id) async {
    try {
      final response = await _client.get('/api/edificios/$id/estadisticas');
      return EstadisticasEdificio.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ============================================
  // HABITACIONES
  // ============================================

  Future<List<Habitacion>> getAllHabitaciones() async {
    try {
      final response = await _client.get('/api/habitaciones');
      final List<dynamic> data = response.data;
      return data.map((json) => Habitacion.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Habitacion> getHabitacionById(String id) async {
    try {
      final response = await _client.get('/api/habitaciones/$id');
      return Habitacion.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Habitacion>> getHabitacionesByEdificio(String edificioId) async {
    try {
      final response = await _client.get(
        '/api/habitaciones/edificio/$edificioId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Habitacion.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Habitacion>> getHabitacionesByEstado(String estado) async {
    try {
      final response = await _client.get('/api/habitaciones/estado/$estado');
      final List<dynamic> data = response.data;
      return data.map((json) => Habitacion.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Habitacion> createHabitacion({
    required String numero,
    required String tipo,
    required double area,
    required int habitaciones,
    required int banos,
    required String estado,
    required String edificioId,
  }) async {
    try {
      final response = await _client.post(
        '/api/habitaciones',
        data: {
          'numero': numero,
          'tipo': tipo,
          'area': area,
          'habitaciones': habitaciones,
          'banos': banos,
          'estado': estado,
          'edificioId': edificioId,
        },
      );
      return Habitacion.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Habitacion> updateHabitacion({
    required String id,
    String? numero,
    String? tipo,
    double? area,
    int? habitaciones,
    int? banos,
    String? estado,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (numero != null) data['numero'] = numero;
      if (tipo != null) data['tipo'] = tipo;
      if (area != null) data['area'] = area;
      if (habitaciones != null) data['habitaciones'] = habitaciones;
      if (banos != null) data['banos'] = banos;
      if (estado != null) data['estado'] = estado;

      final response = await _client.put('/api/habitaciones/$id', data: data);
      return Habitacion.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteHabitacion(String id) async {
    try {
      await _client.delete('/api/habitaciones/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Habitacion> asignarUsuarioHabitacion({
    required String habitacionId,
    required String usuarioId,
  }) async {
    try {
      final response = await _client.post(
        '/api/habitaciones/asignar-usuario',
        data: {'habitacionId': habitacionId, 'usuarioId': usuarioId},
      );
      return Habitacion.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Habitacion> desasignarUsuarioHabitacion(String habitacionId) async {
    try {
      final response = await _client.post(
        '/api/habitaciones/$habitacionId/desasignar-usuario',
      );
      return Habitacion.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ============================================
  // GARAJES
  // ============================================

  Future<List<Garaje>> getAllGarajes() async {
    try {
      final response = await _client.get('/api/garajes');
      final List<dynamic> data = response.data;
      return data.map((json) => Garaje.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Garaje> getGarajeById(String id) async {
    try {
      final response = await _client.get('/api/garajes/$id');
      return Garaje.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Garaje>> getGarajesByEdificio(String edificioId) async {
    try {
      final response = await _client.get('/api/garajes/edificio/$edificioId');
      final List<dynamic> data = response.data;
      return data.map((json) => Garaje.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Garaje>> getGarajesByEstado(String estado) async {
    try {
      final response = await _client.get('/api/garajes/estado/$estado');
      final List<dynamic> data = response.data;
      return data.map((json) => Garaje.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Garaje> createGaraje({
    required String numero,
    required String tipo,
    required String estado,
    required String edificioId,
  }) async {
    try {
      final response = await _client.post(
        '/api/garajes',
        data: {
          'numero': numero,
          'tipo': tipo,
          'estado': estado,
          'edificioId': edificioId,
        },
      );
      return Garaje.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Garaje> updateGaraje({
    required String id,
    String? numero,
    String? tipo,
    String? estado,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (numero != null) data['numero'] = numero;
      if (tipo != null) data['tipo'] = tipo;
      if (estado != null) data['estado'] = estado;

      final response = await _client.put('/api/garajes/$id', data: data);
      return Garaje.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteGaraje(String id) async {
    try {
      await _client.delete('/api/garajes/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Garaje> asignarGaraje({
    required String garajeId,
    required String usuarioId,
  }) async {
    try {
      final response = await _client.post(
        '/api/garajes/asignar',
        data: {'garajeId': garajeId, 'usuarioId': usuarioId},
      );
      return Garaje.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Garaje> desasignarGaraje(String garajeId) async {
    try {
      final response = await _client.post('/api/garajes/$garajeId/desasignar');
      return Garaje.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
