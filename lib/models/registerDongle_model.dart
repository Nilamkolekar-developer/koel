class RegisterDongleModel {
  dynamic macId; // C# had `object`, so using dynamic
  String? deviceType;

  RegisterDongleModel({this.macId, this.deviceType});

  Map<String, dynamic> toJson() => {
        'mac_id': macId,
        'device_type': deviceType,
      };
}

class RegDongleRespons {
  String? oem;
  String? deviceType;
  String? message;
  String? macId;
  String? user;
  bool? isActive;
  String? status;
  String? error;

  RegDongleRespons({
    this.oem,
    this.deviceType,
    this.message,
    this.macId,
    this.user,
    this.isActive,
    this.status,
    this.error,
  });

  // Factory constructor to create an instance from a JSON map
  factory RegDongleRespons.fromJson(Map<String, dynamic> json) {
    return RegDongleRespons(
      oem: json['oem'],
      deviceType: json['device_type'],
      message: json['message'],
      macId: json['mac_id'],
      user: json['user'],
      isActive: json['is_active'],
      status: json['status'],
      error: json['error'],
    );
  }

  // Method to convert an instance back into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'oem': oem,
      'device_type': deviceType,
      'message': message,
      'mac_id': macId,
      'user': user,
      'is_active': isActive,
      'status': status,
      'error': error,
    };
  }
}

class ErrorRes {
  String? error;
  bool? isActive;

  ErrorRes({this.error, this.isActive});

  factory ErrorRes.fromJson(Map<String, dynamic> json) {
    return ErrorRes(
      error: json['error'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
        'error': error,
        'is_active': isActive,
      };
}
