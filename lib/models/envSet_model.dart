import 'package:autopeepal/models/liveParameter_model.dart';

class EnvSetModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<EnvSetResult>? results;
  String? message;

  EnvSetModel({
    this.count,
    this.next,
    this.previous,
    this.results,
    this.message,
  });

  // JSON -> Object
  factory EnvSetModel.fromJson(Map<String, dynamic> json) {
    return EnvSetModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => EnvSetResult.fromJson(i))
              .toList()
          : null,
      message: json['message'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((v) => v.toJson()).toList(),
      'message': message,
    };
  }
}

class EnvSetResult {
  int? id;
  String? ffSet;
  int? oem;
  int? vehicleModel;
  int? subModel;
  int? modelYear;
  int? ecu;
  bool? isActive;
  List<EnvironmentSnapshotCode>? environmentSnapshotCode;

  EnvSetResult({
    this.id,
    this.ffSet,
    this.oem,
    this.vehicleModel,
    this.subModel,
    this.modelYear,
    this.ecu,
    this.isActive,
    this.environmentSnapshotCode,
  });

  // JSON -> Object
  factory EnvSetResult.fromJson(Map<String, dynamic> json) {
    return EnvSetResult(
      id: json['id'],
      ffSet: json['ff_set'],
      oem: json['oem'],
      vehicleModel: json['vehicle_model'],
      subModel: json['sub_model'],
      modelYear: json['model_year'],
      ecu: json['ecu'],
      isActive: json['is_active'],
      environmentSnapshotCode: json['environment_snapshot_code'] != null
          ? (json['environment_snapshot_code'] as List)
              .map((i) => EnvironmentSnapshotCode.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ff_set': ffSet,
      'oem': oem,
      'vehicle_model': vehicleModel,
      'sub_model': subModel,
      'model_year': modelYear,
      'ecu': ecu,
      'is_active': isActive,
      'environment_snapshot_code':
          environmentSnapshotCode?.map((v) => v.toJson()).toList(),
    };
  }
}

class EnvironmentSnapshotCode {
  int? id;
  PidCode? pidCode;
  int? priority;

  EnvironmentSnapshotCode({
    this.id,
    this.pidCode,
    this.priority,
  });

  // JSON -> Object
  factory EnvironmentSnapshotCode.fromJson(Map<String, dynamic> json) {
    return EnvironmentSnapshotCode(
      id: json['id'],
      pidCode:
          json['pid_code'] != null ? PidCode.fromJson(json['pid_code']) : null,
      priority: json['priority'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pid_code': pidCode?.toJson(),
      'priority': priority,
    };
  }
}
