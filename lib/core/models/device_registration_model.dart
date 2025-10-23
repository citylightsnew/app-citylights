class DeviceRegistration {
  final String deviceId;
  final String fcmToken;
  final String platform;
  final String deviceModel;
  final String osVersion;

  DeviceRegistration({
    required this.deviceId,
    required this.fcmToken,
    required this.platform,
    required this.deviceModel,
    required this.osVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'fcmToken': fcmToken,
      'platform': platform,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
    };
  }

  factory DeviceRegistration.fromJson(Map<String, dynamic> json) {
    return DeviceRegistration(
      deviceId: json['deviceId'] as String,
      fcmToken: json['fcmToken'] as String,
      platform: json['platform'] as String,
      deviceModel: json['deviceModel'] as String,
      osVersion: json['osVersion'] as String,
    );
  }
}
