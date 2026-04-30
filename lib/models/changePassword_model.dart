class ChangePasswordModel {
  String? email;

  ChangePasswordModel({
    this.email,
  });

  // JSON -> Object
  factory ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordModel(
      email: json['email'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordModel {
  String? email;
  String? otp;
  String? newPassword;

  ResetPasswordModel({
    this.email,
    this.otp,
    this.newPassword,
  });

  // JSON -> Object
  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(
      email: json['email'],
      otp: json['otp'],
      newPassword: json['new_password'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'new_password': newPassword,
    };
  }
}

class OTPResponseModel {
  String? detail;
  String? status;
  bool? success;

  OTPResponseModel({
    this.detail,
    this.status,
    this.success,
  });

  // JSON -> Object
  factory OTPResponseModel.fromJson(Map<String, dynamic> json) {
    return OTPResponseModel(
      detail: json['detail'],
      status: json['status'],
      success: json['success'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'detail': detail,
      'status': status,
      'success': success,
    };
  }
}

class VerifyOTPResponseModel {
  String? status;
  bool? success;

  VerifyOTPResponseModel({
    this.status,
    this.success,
  });

  // JSON -> Object
  factory VerifyOTPResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponseModel(
      status: json['status'],
      success: json['success'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'success': success,
    };
  }
}

class VerifyOTPRequestModel {
  String? email;
  String? otp;

  VerifyOTPRequestModel({
    this.email,
    this.otp,
  });

  // JSON -> Object
  factory VerifyOTPRequestModel.fromJson(Map<String, dynamic> json) {
    return VerifyOTPRequestModel(
      email: json['email'],
      otp: json['otp'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
