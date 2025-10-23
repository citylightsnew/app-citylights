// Request Models
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final String? telefono;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    this.telefono,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'nombre': nombre,
    'apellido': apellido,
    if (telefono != null) 'telefono': telefono,
  };
}

class VerifyEmailRequest {
  final String email;
  final String code;

  VerifyEmailRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}

class Verify2FARequest {
  final String email;
  final String code;

  Verify2FARequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}

class Check2FAStatusRequest {
  final String requestId;

  Check2FAStatusRequest({required this.requestId});

  Map<String, dynamic> toJson() => {'requestId': requestId};
}

class ResendCodeRequest {
  final String email;

  ResendCodeRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// Response Models
class LoginResponse {
  final String? token;
  final dynamic user;
  final bool requiresTwoFactor;
  final bool? usePushNotification;
  final String? requestId;
  final String? message;

  LoginResponse({
    this.token,
    this.user,
    required this.requiresTwoFactor,
    this.usePushNotification,
    this.requestId,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String?,
      user: json['user'],
      requiresTwoFactor: json['requiresTwoFactor'] as bool? ?? false,
      usePushNotification: json['usePushNotification'] as bool?,
      requestId: json['requestId'] as String?,
      message: json['message'] as String?,
    );
  }
}

class RegisterResponse {
  final String message;
  final String email;
  final bool requiresEmailVerification;

  RegisterResponse({
    required this.message,
    required this.email,
    required this.requiresEmailVerification,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String? ?? '',
      email: json['email'] as String? ?? '',
      requiresEmailVerification:
          json['requiresEmailVerification'] as bool? ?? true,
    );
  }
}

class VerifyEmailResponse {
  final String message;

  VerifyEmailResponse({required this.message});

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(message: json['message'] as String? ?? '');
  }
}

class Verify2FAResponse {
  final String token;
  final dynamic user;

  Verify2FAResponse({required this.token, required this.user});

  factory Verify2FAResponse.fromJson(Map<String, dynamic> json) {
    return Verify2FAResponse(
      token: json['token'] as String,
      user: json['user'],
    );
  }
}

class Check2FAStatusResponse {
  final String status; // 'pending' | 'approved' | 'rejected' | 'expired'
  final String? token;
  final dynamic user;
  final String? message;

  Check2FAStatusResponse({
    required this.status,
    this.token,
    this.user,
    this.message,
  });

  factory Check2FAStatusResponse.fromJson(Map<String, dynamic> json) {
    return Check2FAStatusResponse(
      status: json['status'] as String,
      token: json['token'] as String?,
      user: json['user'],
      message: json['message'] as String?,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';
}

class ResendCodeResponse {
  final String message;

  ResendCodeResponse({required this.message});

  factory ResendCodeResponse.fromJson(Map<String, dynamic> json) {
    return ResendCodeResponse(message: json['message'] as String? ?? '');
  }
}

// Error Response
class ApiErrorResponse {
  final String message;
  final int? statusCode;
  final String? error;

  ApiErrorResponse({required this.message, this.statusCode, this.error});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      message: json['message'] as String? ?? 'Error desconocido',
      statusCode: json['statusCode'] as int?,
      error: json['error'] as String?,
    );
  }
}
