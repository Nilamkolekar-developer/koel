import 'package:autopeepal/models/user_info_model.dart';

class CreateUserReqModel {
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? password;
  String? password2;
  String? deviceType;
  int? workshop; // Maps to C# long
  String? macId;
  String? serialNumber;
  String? uid;
  String? imei;

  CreateUserReqModel({
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.password,
    this.password2,
    this.deviceType,
    this.workshop,
    this.macId,
    this.serialNumber,
    this.uid,
    this.imei,
  });

  // JSON -> Object
  factory CreateUserReqModel.fromJson(Map<String, dynamic> json) {
    return CreateUserReqModel(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      mobile: json['mobile'],
      password: json['password'],
      password2: json['password2'],
      deviceType: json['device_type'],
      workshop: json['workshop'],
      macId: json['mac_id'],
      serialNumber: json['serial_number'],
      uid: json['uid'],
      imei: json['imei'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'password': password,
      'password2': password2,
      'device_type': deviceType,
      'workshop': workshop,
      'mac_id': macId,
      'serial_number': serialNumber,
      'uid': uid,
      'imei': imei,
    };
  }
}

class InvantabCreateUserReqModel {
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? password;
  String? org;
  String? marketPlace;

  InvantabCreateUserReqModel({
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.password,
    this.org,
    this.marketPlace,
  });

  // JSON Map -> Object
  factory InvantabCreateUserReqModel.fromJson(Map<String, dynamic> json) {
    return InvantabCreateUserReqModel(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      mobile: json['mobile'],
      password: json['password'],
      org: json['org'],
      marketPlace: json['market_place'],
    );
  }

  // Object -> JSON Map
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'password': password,
      'org': org,
      'market_place': marketPlace,
    };
  }
}

class InvantabCreateUserResModel {
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? message;
  String? status;
  Token? token;

  InvantabCreateUserResModel({
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.message,
    this.status,
    this.token,
  });

  // JSON -> Object
  factory InvantabCreateUserResModel.fromJson(Map<String, dynamic> json) {
    return InvantabCreateUserResModel(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      mobile: json['mobile'],
      message: json['message'],
      status: json['status'],
      token: json['token'] != null ? Token.fromJson(json['token']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'message': message,
      'status': status,
      'token': token?.toJson(),
    };
  }
}

class TokenInvantab {
  String? refresh;
  String? access;
  int? expire;

  TokenInvantab({
    this.refresh,
    this.access,
    this.expire,
  });

  // JSON -> Object
  factory TokenInvantab.fromJson(Map<String, dynamic> json) {
    return TokenInvantab(
      refresh: json['refresh'],
      access: json['access'],
      expire: json['expire'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
      'expire': expire,
    };
  }
}

class CreateUserResModel {
  String? status;
  String? apiStatus;
  CreateUserRes? createUserRes;
  CreateUserError? createUserError;

  CreateUserResModel({
    this.status,
    this.apiStatus,
    this.createUserRes,
    this.createUserError,
  });

  // JSON -> Object
  factory CreateUserResModel.fromJson(Map<String, dynamic> json) {
    return CreateUserResModel(
      status: json['status'],
      apiStatus: json['api_status'],
      createUserRes: json['CreateUserRes'] != null
          ? CreateUserRes.fromJson(json['CreateUserRes'])
          : null,
      createUserError: json['CreateUserError'] != null
          ? CreateUserError.fromJson(json['CreateUserError'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'api_status': apiStatus,
      'CreateUserRes': createUserRes?.toJson(),
      'CreateUserError': createUserError?.toJson(),
    };
  }
}

class CreateUserRes {
  String? firstName;
  String? lastName;
  dynamic email;
  dynamic mobile;
  String? workshop;
  String? token;
  DateTime? expires;
  String? message;
  String? uid;

  CreateUserRes({
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.workshop,
    this.token,
    this.expires,
    this.message,
    this.uid,
  });

  // JSON -> Object
  factory CreateUserRes.fromJson(Map<String, dynamic> json) {
    return CreateUserRes(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'], // Maps to dynamic to handle 'object'
      mobile: json['mobile'], // Maps to dynamic to handle 'object'
      workshop: json['workshop'],
      token: json['token'],
      expires: json['expires'] != null ? DateTime.parse(json['expires']) : null,
      message: json['message'],
      uid: json['uid'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'workshop': workshop,
      'token': token,
      'expires': expires?.toIso8601String(),
      'message': message,
      'uid': uid,
    };
  }
}

class CreateUserError {
  List<String>? email;
  List<String>? mobile;

  CreateUserError({
    this.email,
    this.mobile,
  });

  // JSON -> Object
  factory CreateUserError.fromJson(Map<String, dynamic> json) {
    return CreateUserError(
      // Safely casting to List<String>
      email: json['email'] != null ? List<String>.from(json['email']) : null,
      mobile: json['mobile'] != null ? List<String>.from(json['mobile']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'mobile': mobile,
    };
  }
}
