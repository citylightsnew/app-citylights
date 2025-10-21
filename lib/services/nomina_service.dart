import 'package:dio/dio.dart';
import '../models/nomina_model.dart';
import 'dio_client.dart';

class NominaService {
  final DioClient _client = DioClient();

  // ============================================
  // EMPLEADOS
  // ============================================

  Future<List<Empleado>> getAllEmpleados({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _client.get(
        '/api/nomina/empleados',
        queryParameters: filters,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Empleado.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Empleado> getEmpleadoById(String id) async {
    try {
      final response = await _client.get('/api/nomina/empleados/$id');
      return Empleado.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Empleado>> getEmpleadosByDepartamento(String departamento) async {
    try {
      final response = await _client.get(
        '/api/nomina/empleados/departamento/$departamento',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Empleado.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Empleado>> getEmpleadosActivos() async {
    try {
      final response = await _client.get('/api/nomina/empleados/activos');
      final List<dynamic> data = response.data;
      return data.map((json) => Empleado.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Empleado> createEmpleado({
    required String nombre,
    required String apellido,
    required String ci,
    required String email,
    required String telefono,
    required String departamento,
    required String cargo,
    required double salarioBase,
    required DateTime fechaContratacion,
  }) async {
    try {
      final response = await _client.post(
        '/api/nomina/empleados',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'ci': ci,
          'email': email,
          'telefono': telefono,
          'departamento': departamento,
          'cargo': cargo,
          'salarioBase': salarioBase,
          'fechaContratacion': fechaContratacion.toIso8601String(),
        },
      );
      return Empleado.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Empleado> updateEmpleado({
    required String id,
    String? nombre,
    String? apellido,
    String? ci,
    String? email,
    String? telefono,
    String? departamento,
    String? cargo,
    double? salarioBase,
    String? estado,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (apellido != null) data['apellido'] = apellido;
      if (ci != null) data['ci'] = ci;
      if (email != null) data['email'] = email;
      if (telefono != null) data['telefono'] = telefono;
      if (departamento != null) data['departamento'] = departamento;
      if (cargo != null) data['cargo'] = cargo;
      if (salarioBase != null) data['salarioBase'] = salarioBase;
      if (estado != null) data['estado'] = estado;

      final response = await _client.patch(
        '/api/nomina/empleados/$id',
        data: data,
      );
      return Empleado.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Empleado> changeEstadoEmpleado(String id, String estado) async {
    try {
      final response = await _client.patch(
        '/api/nomina/empleados/$id/estado',
        data: {'estado': estado},
      );
      return Empleado.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteEmpleado(String id) async {
    try {
      await _client.delete('/api/nomina/empleados/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ============================================
  // PAGOS NÓMINA
  // ============================================

  Future<List<PagoNomina>> getAllPagosNomina({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _client.get(
        '/api/nomina/pagos',
        queryParameters: filters,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => PagoNomina.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoNomina> getPagoNominaById(String id) async {
    try {
      final response = await _client.get('/api/nomina/pagos/$id');
      return PagoNomina.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<PagoNomina>> getPagosNominaByEmpleado(String empleadoId) async {
    try {
      final response = await _client.get(
        '/api/nomina/pagos/empleado/$empleadoId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => PagoNomina.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<PagoNomina>> getPagosNominaByPeriodo(String periodo) async {
    try {
      final response = await _client.get('/api/nomina/pagos/periodo/$periodo');
      final List<dynamic> data = response.data;
      return data.map((json) => PagoNomina.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<PagoNomina>> getPagosNominaPendientes() async {
    try {
      final response = await _client.get('/api/nomina/pagos/pendientes');
      final List<dynamic> data = response.data;
      return data.map((json) => PagoNomina.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoNomina> createPagoNomina({
    required String empleadoId,
    required String periodo,
    required double salarioBase,
    double bonos = 0,
    double deducciones = 0,
    double horasExtras = 0,
  }) async {
    try {
      final response = await _client.post(
        '/api/nomina/pagos',
        data: {
          'empleadoId': empleadoId,
          'periodo': periodo,
          'salarioBase': salarioBase,
          'bonos': bonos,
          'deducciones': deducciones,
          'horasExtras': horasExtras,
        },
      );
      return PagoNomina.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoNomina> procesarPagoNomina({
    required String id,
    required String metodoPago,
    String? comprobantePago,
  }) async {
    try {
      final response = await _client.post(
        '/api/nomina/pagos/procesar',
        data: {
          'id': id,
          'metodoPago': metodoPago,
          if (comprobantePago != null) 'comprobantePago': comprobantePago,
        },
      );
      return PagoNomina.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoNomina> rechazarPagoNomina(String id, String motivo) async {
    try {
      final response = await _client.post(
        '/api/nomina/pagos/$id/rechazar',
        data: {'motivo': motivo},
      );
      return PagoNomina.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<PagoNomina>> generarPlanilla(String periodo) async {
    try {
      final response = await _client.post(
        '/api/nomina/pagos/generar-planilla',
        data: {'periodo': periodo},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => PagoNomina.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ============================================
  // ASISTENCIA
  // ============================================

  Future<List<Asistencia>> getAllAsistencias({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _client.get(
        '/api/nomina/asistencias',
        queryParameters: filters,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Asistencia.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Asistencia> getAsistenciaById(String id) async {
    try {
      final response = await _client.get('/api/nomina/asistencias/$id');
      return Asistencia.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Asistencia>> getAsistenciasByEmpleado(String empleadoId) async {
    try {
      final response = await _client.get(
        '/api/nomina/asistencias/empleado/$empleadoId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Asistencia.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Asistencia> registrarEntrada(String empleadoId) async {
    try {
      final response = await _client.post(
        '/api/nomina/asistencias/entrada',
        data: {'empleadoId': empleadoId},
      );
      return Asistencia.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Asistencia> registrarSalida(String empleadoId) async {
    try {
      final response = await _client.post(
        '/api/nomina/asistencias/salida',
        data: {'empleadoId': empleadoId},
      );
      return Asistencia.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
