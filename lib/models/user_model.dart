// ================= REQUEST MODELS =================

import 'package:autopeepal/models/jobCard_model.dart';

class UserModel {
  String username;
  String password;
  String macId;
  String deviceType;

  UserModel({
    required this.username,
    required this.password,
    required this.macId,
    required this.deviceType,
  });

  // ✅ For API / file save
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "mac_id": macId,
      "device_type": deviceType,
    };
  }

  // ✅ REQUIRED for offline login / restore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      password: json['password'],
      macId: json['mac_id'],
      deviceType: json['device_type'],
    );
  }
}

class ChangePassword {
  String newPassword1;
  String newPassword2;

  ChangePassword({
    required this.newPassword1,
    required this.newPassword2,
  });

  Map<String, dynamic> toJson() {
    return {
      "new_password1": newPassword1,
      "new_password2": newPassword2,
    };
  }

  factory ChangePassword.fromJson(Map<String, dynamic> json) {
    return ChangePassword(
      newPassword1: json['new_password1'],
      newPassword2: json['new_password2'],
    );
  }
}

class LoginRespons {
  LoginRes? loginRes;
  UserResModel? userRes;

  LoginRespons({
    this.loginRes,
    this.userRes,
  });

  factory LoginRespons.fromJson(Map<String, dynamic> json) {
    return LoginRespons(
      loginRes: json['login'] != null ? LoginRes.fromJson(json['login']) : null,
      userRes: json['userRes'] != null
          ? UserResModel.fromJson(json['userRes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "login": loginRes?.toJson(),
      "userRes": userRes?.toJson(),
    };
  }
}

class LoginRes {
  String? error;
  bool? isActive;

  LoginRes({this.error, this.isActive});

  factory LoginRes.fromJson(Map<String, dynamic> json) {
    return LoginRes(
      error: json['error'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "error": error,
      "is_active": isActive,
    };
  }
}

class Licences {
  bool allDTC;
  bool selfTest;
  bool ecuFlashing;
  bool write;
  bool liveParameter;
  bool dtc;
  bool ecuInformation;
  bool regeneration;
  bool sessionLog;

  Licences({
    required this.allDTC,
    required this.selfTest,
    required this.ecuFlashing,
    required this.write,
    required this.liveParameter,
    required this.dtc,
    required this.ecuInformation,
    required this.regeneration,
    required this.sessionLog,
  });

  factory Licences.fromJson(Map<String, dynamic> json) {
    return Licences(
      allDTC: json['All DTC'] ?? false,
      selfTest: json['Self Test'] ?? false,
      ecuFlashing: json['ECU Flashing'] ?? false,
      write: json['Write'] ?? false,
      liveParameter: json['Live Parameter'] ?? false,
      dtc: json['DTC'] ?? false,
      ecuInformation: json['ECU Information'] ?? false,
      regeneration: json['Regeneration'] ?? false,
      sessionLog: json['Session Log'] ?? false,
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'All DTC': allDTC,
      'Self Test': selfTest,
      'ECU Flashing': ecuFlashing,
      'Write': write,
      'Live Parameter': liveParameter,
      'DTC': dtc,
      'ECU Information': ecuInformation,
      'Regeneration': regeneration,
      'Session Log': sessionLog,
    };
  }
}

class UserResModel {
  int? userId;
  Licences? licences;
  String? lastName;
  String? role;
  DateTime? expires;
  Token? token;
  String? user;
  String? firstName;
  Profile? profile;
  String? message;

  UserResModel({
    this.userId,
    this.licences,
    this.lastName,
    this.role,
    this.expires,
    this.token,
    this.user,
    this.firstName,
    this.profile,
    this.message,
  });

  factory UserResModel.fromJson(Map<String, dynamic> json) {
    return UserResModel(
      userId: json['user_id'],
      licences:
          json['licences'] != null ? Licences.fromJson(json['licences']) : null,
      lastName: json['last_name'],
      role: json['role'],
      expires: json['expires'] != null ? DateTime.parse(json['expires']) : null,
      token: json['token'] != null ? Token.fromJson(json['token']) : null,
      user: json['user'],
      firstName: json['first_name'],
      profile:
          json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      message: json['message'],
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'licences': licences?.toJson(),
      'last_name': lastName,
      'role': role,
      'expires': expires?.toIso8601String(),
      'token': token?.toJson(),
      'user': user,
      'first_name': firstName,
      'profile': profile?.toJson(),
      'message': message,
    };
  }
}

class Profile {
  int? id;
  Oem1? oem;
  String? email;
  String? mobile;
  String? role;
  bool? status;
  dynamic parent;
  int? user;
  int? workshop;
  dynamic reportTo;
  List<dynamic>? runTimeLicenses;

  /// ✅ IMPORTANT: make this strongly typed
  List<VehicleModel>? workshopGroupModels;

  Profile({
    this.id,
    this.oem,
    this.email,
    this.mobile,
    this.role,
    this.status,
    this.parent,
    this.user,
    this.workshop,
    this.reportTo,
    this.runTimeLicenses,
    this.workshopGroupModels,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      oem: json['oem'] != null ? Oem1.fromJson(json['oem']) : null,
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
      status: json['status'],
      parent: json['parent'],
      user: json['user'],
      workshop: json['workshop'],
      reportTo: json['report_to'],
      runTimeLicenses: json['run_time_licenses'] ?? [],
      workshopGroupModels: json['workshop_group_models'] != null
          ? List<VehicleModel>.from(
              json['workshop_group_models']
                  .map((e) => VehicleModel.fromJson(e)),
            )
          : [],
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oem': oem?.toJson(),
      'email': email,
      'mobile': mobile,
      'role': role,
      'status': status,
      'parent': parent,
      'user': user,
      'workshop': workshop,
      'report_to': reportTo,
      'run_time_licenses': runTimeLicenses,
      'workshop_group_models':
          workshopGroupModels?.map((e) => e.toJson()).toList(),
    };
  }
}

class Oem1 {
  int? id;
  DateTime? created;
  DateTime? modified;
  String? name;
  String? slug;
  dynamic createdBy;
  bool? isActive;
  String? oemFile;
  String? color;
  String? appName;
  int? admin;
  dynamic manager;

  Oem1({
    this.id,
    this.created,
    this.modified,
    this.name,
    this.slug,
    this.createdBy,
    this.isActive,
    this.oemFile,
    this.color,
    this.appName,
    this.admin,
    this.manager,
  });

  factory Oem1.fromJson(Map<String, dynamic> json) {
    return Oem1(
      id: json['id'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      name: json['name'],
      slug: json['slug'],
      createdBy: json['created_by'],
      isActive: json['is_active'],
      oemFile: json['oem_file'],
      color: json['color'],
      appName: json['app_name'],
      admin: json['admin'],
      manager: json['manager'],
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'name': name,
      'slug': slug,
      'created_by': createdBy,
      'is_active': isActive,
      'oem_file': oemFile,
      'color': color,
      'app_name': appName,
      'admin': admin,
      'manager': manager,
    };
  }
}

class InvantabUserModel {
  String? username;
  String? password;

  InvantabUserModel({
    this.username,
    this.password,
  });

  // FROM JSON
  factory InvantabUserModel.fromJson(Map<String, dynamic> json) {
    return InvantabUserModel(
      username: json['username'],
      password: json['password'],
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class Token {
  String? refresh;
  String? access;

  Token({this.refresh, this.access});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      refresh: json['refresh'],
      access: json['access'],
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
    };
  }
}

class InvantabUserResModel {
  bool? success;
  InvantabData? data;
  String? message;
  String? status;

  InvantabUserResModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  // JSON -> Object
  factory InvantabUserResModel.fromJson(Map<String, dynamic> json) {
    return InvantabUserResModel(
      success: json['success'],
      data: json['data'] != null ? InvantabData.fromJson(json['data']) : null,
      message: json['message'],
      status: json['status'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'status': status,
    };
  }
}

class InvantabData {
  String? firstName;
  String? lastName;
  String? userId;
  String? mobile;
  String? email;
  List<Marketplace>? marketplace;
  Org? org;
  List<dynamic>? dept;
  List<dynamic>? subscription;
  bool? online;
  bool? active;
  AuthToken? authToken;

  InvantabData({
    this.firstName,
    this.lastName,
    this.userId,
    this.mobile,
    this.email,
    this.marketplace,
    this.org,
    this.dept,
    this.subscription,
    this.online,
    this.active,
    this.authToken,
  });

  factory InvantabData.fromJson(Map<String, dynamic> json) {
    return InvantabData(
      firstName: json['first_name'],
      lastName: json['last_name'],
      userId: json['user_id'],
      mobile: json['mobile'],
      email: json['email'],
      marketplace: json['marketplace'] != null
          ? (json['marketplace'] as List)
              .map((i) => Marketplace.fromJson(i))
              .toList()
          : null,
      org: json['org'] != null ? Org.fromJson(json['org']) : null,
      dept: json['dept'], // List<dynamic>
      subscription: json['subscription'], // List<dynamic>
      online: json['online'],
      active: json['active'],
      authToken: json['auth_token'] != null
          ? AuthToken.fromJson(json['auth_token'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'user_id': userId,
      'mobile': mobile,
      'email': email,
      'marketplace': marketplace?.map((i) => i.toJson()).toList(),
      'org': org?.toJson(),
      'dept': dept,
      'subscription': subscription,
      'online': online,
      'active': active,
      'auth_token': authToken?.toJson(),
    };
  }
}

class Marketplace {
  String? id;
  String? marketplaceName;
  String? color;
  dynamic logo;
  String? org;

  Marketplace({
    this.id,
    this.marketplaceName,
    this.color,
    this.logo,
    this.org,
  });

  // FROM JSON
  factory Marketplace.fromJson(Map<String, dynamic> json) {
    return Marketplace(
      id: json['id'],
      marketplaceName: json['marketplace_name'],
      color: json['color'],
      logo: json['logo'],
      org: json['org'],
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marketplace_name': marketplaceName,
      'color': color,
      'logo': logo,
      'org': org,
    };
  }
}

class Org {
  String? id;
  List<dynamic>? banks;
  Country? country;
  DateTime? created;
  DateTime? modified;
  String? orgCode;
  String? companyType;
  String? companyName;
  String? logo;
  String? address;
  String? panNo;
  dynamic panCert;
  String? pincode;
  dynamic contactPerson;
  int? paymentTerm;
  String? marketplace;
  List<dynamic>? metaTags;
  List<String>? role;

  Org({
    this.id,
    this.banks,
    this.country,
    this.created,
    this.modified,
    this.orgCode,
    this.companyType,
    this.companyName,
    this.logo,
    this.address,
    this.panNo,
    this.panCert,
    this.pincode,
    this.contactPerson,
    this.paymentTerm,
    this.marketplace,
    this.metaTags,
    this.role,
  });

  // FROM JSON
  factory Org.fromJson(Map<String, dynamic> json) {
    return Org(
      id: json['id'],
      banks: json['banks'],
      country:
          json['country'] != null ? Country.fromJson(json['country']) : null,
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      orgCode: json['org_code'],
      companyType: json['company_type'],
      companyName: json['company_name'],
      logo: json['logo'],
      address: json['address'],
      panNo: json['pan_no'],
      panCert: json['pan_cert'],
      pincode: json['pincode'],
      contactPerson: json['contact_person'],
      paymentTerm: json['payment_term'],
      marketplace: json['marketplace'],
      metaTags: json['meta_tags'],
      role: json['role'] != null ? List<String>.from(json['role']) : null,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'banks': banks,
      'country': country?.toJson(),
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'org_code': orgCode,
      'company_type': companyType,
      'company_name': companyName,
      'logo': logo,
      'address': address,
      'pan_no': panNo,
      'pan_cert': panCert,
      'pincode': pincode,
      'contact_person': contactPerson,
      'payment_term': paymentTerm,
      'marketplace': marketplace,
      'meta_tags': metaTags,
      'role': role,
    };
  }
}

class AuthToken {
  String? access;
  String? refresh;

  AuthToken({
    this.access,
    this.refresh,
  });

  // FROM JSON
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      access: json['access'],
      refresh: json['refresh'],
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }
}

class Country {
  String? id;
  DateTime? created;
  DateTime? modified;
  String? name;
  dynamic slug;
  String? region;
  String? code;
  String? currencyName;
  dynamic postalCodeFormat;
  dynamic postalCodeRegex;
  String? currency;

  Country({
    this.id,
    this.created,
    this.modified,
    this.name,
    this.slug,
    this.region,
    this.code,
    this.currencyName,
    this.postalCodeFormat,
    this.postalCodeRegex,
    this.currency,
  });

  // FROM JSON
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      name: json['name'],
      slug: json['slug'],
      region: json['region'],
      code: json['code'],
      currencyName: json['currency_name'],
      postalCodeFormat: json['postal_code_format'],
      postalCodeRegex: json['postal_code_regex'],
      currency: json['currency'],
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'name': name,
      'slug': slug,
      'region': region,
      'code': code,
      'currency_name': currencyName,
      'postal_code_format': postalCodeFormat,
      'postal_code_regex': postalCodeRegex,
      'currency': currency,
    };
  }
}
