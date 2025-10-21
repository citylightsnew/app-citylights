import 'user_model.dart';

class LoginResponse {
  final String? token;
  final User? user;
  final bool require2FA;
  final String? message;

  LoginResponse({this.token, this.user, this.require2FA = false, this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      require2FA: json['require2FA'] ?? false,
      message: json['message'],
    );
  }
}

class TwoFactorResponse {
  final String token;
  final String accessToken;
  final User user;

  TwoFactorResponse({required this.token, required this.user})
    : accessToken = token;

  factory TwoFactorResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] ?? json['access_token'] ?? '';
    return TwoFactorResponse(token: token, user: User.fromJson(json['user']));
  }
}

class RegisterResponse {
  final String message;
  final User? user;

  RegisterResponse({required this.message, this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? 'Registro exitoso',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class VerifyEmailResponse {
  final String message;
  final String? token;
  final User? user;

  VerifyEmailResponse({required this.message, this.token, this.user});

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      message: json['message'] ?? 'Email verificado',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
