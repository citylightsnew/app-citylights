import 'package:dio/dio.dart';
import '../models/payment_model.dart';
import 'dio_client.dart';

class PaymentService {
  final DioClient _client = DioClient();

  // ============================================
  // PAGOS RESERVA
  // ============================================

  Future<List<PagoReserva>> getAllPagosReserva({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _client.get(
        '/api/payments/reservas',
        queryParameters: filters,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => PagoReserva.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoReserva> getPagoReservaById(String id) async {
    try {
      final response = await _client.get('/api/payments/reservas/$id');
      return PagoReserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<PagoReserva>> getPagosReservaByUser(String usuarioId) async {
    try {
      final response = await _client.get(
        '/api/payments/reservas/usuario/$usuarioId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => PagoReserva.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoReserva> getPagoReservaByReserva(String reservaId) async {
    try {
      final response = await _client.get(
        '/api/payments/reservas/reserva/$reservaId',
      );
      return PagoReserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoReserva> createPagoReserva({
    required String usuarioId,
    required int reservaId,
    required double monto,
    required String metodoPago,
    String? transactionId,
  }) async {
    try {
      final response = await _client.post(
        '/api/payments/reservas',
        data: {
          'usuarioId': usuarioId,
          'reservaId': reservaId,
          'monto': monto,
          'metodoPago': metodoPago,
          if (transactionId != null) 'transactionId': transactionId,
        },
      );
      return PagoReserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoReserva> confirmPagoReserva(String id) async {
    try {
      final response = await _client.post('/api/payments/reservas/$id/confirm');
      return PagoReserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PagoReserva> refundPagoReserva(String id, {double? monto}) async {
    try {
      final response = await _client.post(
        '/api/payments/reservas/$id/refund',
        data: {'monto': monto},
      );
      return PagoReserva.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ============================================
  // FACTURAS
  // ============================================

  Future<List<Factura>> getAllFacturas({Map<String, dynamic>? filters}) async {
    try {
      final response = await _client.get(
        '/api/payments/facturas',
        queryParameters: filters,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Factura.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Factura> getFacturaById(String id) async {
    try {
      final response = await _client.get('/api/payments/facturas/$id');
      return Factura.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Factura> getFacturaByNumero(int numeroFactura) async {
    try {
      final response = await _client.get(
        '/api/payments/facturas/numero/$numeroFactura',
      );
      return Factura.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Factura>> getFacturasByNit(String nit) async {
    try {
      final response = await _client.get('/api/payments/facturas/nit/$nit');
      final List<dynamic> data = response.data;
      return data.map((json) => Factura.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Factura> generateFactura({
    required String nit,
    required String razonSocial,
    String? pagoReservaId,
    String? pagoDanoId,
  }) async {
    try {
      final response = await _client.post(
        '/api/payments/facturas/generate',
        data: {
          'nit': nit,
          'razonSocial': razonSocial,
          if (pagoReservaId != null) 'pagoReservaId': pagoReservaId,
          if (pagoDanoId != null) 'pagoDanoId': pagoDanoId,
        },
      );
      return Factura.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Factura> anularFactura(String id, String motivo) async {
    try {
      final response = await _client.post(
        '/api/payments/facturas/$id/anular',
        data: {'motivo': motivo},
      );
      return Factura.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
